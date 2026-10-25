import 'package:tiendatech/models/Nota.dart' show Nota;
import 'package:tiendatech/services/nota/NotaLocalService.dart'
    show NotasLocalService;
import 'package:tiendatech/services/nota/nota_service.dart' show NotaService;

/// Único punto de acceso de la UI a la información personal del producto
/// (prioridad y nota). La UI no sabe que existen Drift ni Firestore.
///
/// Regla de diseño: hay UN registro por producto. Por eso el `id` de la
/// nota es igual al `idProducto`: en Drift, guardar otra vez actualiza el
/// mismo registro, y en Firestore el documento se llama como el producto.
class NotaRepository {
  final NotasLocalService _local;
  final NotaService _remoto;

  NotaRepository({NotasLocalService? local, NotaService? remoto})
    : _local = local ?? NotasLocalService(),
      _remoto = remoto ?? NotaService();

  /// Lee SIEMPRE desde Drift (funciona sin internet).
  /// Devuelve null si el producto todavía no tiene información guardada.
  Future<Nota?> obtenerPorProducto(int idProducto) {
    return _local.obtenerPorProducto(idProducto);
  }

  /// Offline-first:
  /// 1. Guarda en Drift con pendingSync = true (nunca depende de Firebase).
  /// 2. Intenta enviar a Firestore.
  /// 3. Si Firestore responde bien, marca pendingSync = false.
  ///
  /// Si Firebase falla NO lanza error: el registro queda pendiente.
  /// Solo lanza si falla el guardado local.
  /// Devuelve el registro tal como quedó en Drift.
  Future<Nota> guardar({
    required int idProducto,
    required String texto,
    required int priority,
  }) async {
    final nota = Nota(
      id: idProducto,
      idProducto: idProducto,
      texto: texto,
      priority: priority,
    );

    await _local.guardar(nota, pendingSync: true);
    await _enviar(nota);

    final guardada = await _local.obtenerPorProducto(idProducto);
    if (guardada == null) {
      throw StateError('La nota guardada no se encontró en el almacenamiento local');
    }
    return guardada;
  }

  /// Envía a Firestore SOLO los registros con pendingSync == true.
  /// Como el documento se llama igual que el producto, repetir el envío
  /// sobrescribe el mismo documento y no crea duplicados.
  Future<({int enviados, int fallidos})> sincronizarPendientes() async {
    final pendientes = await _local.listarPendientes();

    var enviados = 0;
    for (final nota in pendientes) {
      final ok = await _enviar(nota);
      if (!ok) break; // sin conexión: no esperar el timeout de cada registro
      enviados++;
    }

    return (enviados: enviados, fallidos: pendientes.length - enviados);
  }

  /// Intenta enviar una nota. Devuelve true si Firestore la aceptó.
  Future<bool> _enviar(Nota nota) async {
    try {
      await _remoto.guardar(nota);
      await _local.marcarSincronizada(nota.id);
      return true;
    } catch (_) {
      // Si falla la red, la nota permanece pendiente en Drift.
      return false;
    }
  }
}
