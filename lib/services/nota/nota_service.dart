import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/Nota.dart';

/// Access to remote notes in Firestore. Local persistence is handled by
/// NotaRepository through NotasLocalService.
class NotaService {
  // Si Firestore no responde en este tiempo, se considera que falló.
  // (Sin internet, Firestore no lanza error: se queda esperando.)
  static const Duration _tiempoMaximo = Duration(seconds: 10);

  CollectionReference<Map<String, dynamic>> get _coleccion =>
      FirebaseFirestore.instance.collection('notas');

  Future<List<Nota>> listar() async {
    final snapshot = await _coleccion.orderBy('id').get();
    return snapshot.docs.map((d) => Nota.fromJson(d.data())).toList();
  }

  Future<List<Nota>> listarPorProducto(int idProducto) async {
    final snapshot = await _coleccion
        .where('id_producto', isEqualTo: idProducto)
        .get();
    return snapshot.docs.map((d) => Nota.fromJson(d.data())).toList();
  }

  Future<Nota?> obtenerPorId(int id) async {
    final doc = await _coleccion.doc(id.toString()).get();
    final data = doc.data();
    return data == null ? null : Nota.fromJson(data);
  }

  /// Guarda una nota en Firestore. La persistencia local y el estado de
  /// sincronización son responsabilidad de NotaRepository.
  Future<void> guardar(Nota nota) async {
    await _coleccion
        .doc(nota.id.toString())
        .set(nota.toJson())
        .timeout(_tiempoMaximo);
  }

  Future<void> eliminar(int id) {
    return _coleccion.doc(id.toString()).delete();
  }
}
