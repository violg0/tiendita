import 'package:tiendatech/models/Nota.dart' show Nota;
import 'package:tiendatech/services/nota/NotaLocalService.dart'
    show NotasLocalService;
import 'package:tiendatech/services/nota/nota_service.dart' show NotaService;

class NotaRepository {
  final NotasLocalService _local;
  final NotaService _remoto;

  NotaRepository({NotasLocalService? local, NotaService? remoto})
    : _local = local ?? NotasLocalService(),
      _remoto = remoto ?? NotaService();

  Future<Nota?> obtenerPorProducto(int idProducto) {
    return _local.obtenerPorProducto(idProducto);
  }

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

  Future<({int enviados, int fallidos})> sincronizarPendientes() async {
    final pendientes = await _local.listarPendientes();

    var enviados = 0;
    for (final nota in pendientes) {
      final ok = await _enviar(nota);
      if (!ok) break;
      enviados++;
    }

    return (enviados: enviados, fallidos: pendientes.length - enviados);
  }

  Future<bool> _enviar(Nota nota) async {
    try {
      await _remoto.guardar(nota);
      await _local.marcarSincronizada(nota.id);
      return true;
    } catch (_) {
      return false;
    }
  }
}
