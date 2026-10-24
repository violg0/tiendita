import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/Nota.dart';

class NotaService {
  final CollectionReference<Map<String, dynamic>> _coleccion = FirebaseFirestore
      .instance
      .collection('notas');

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

  Future<void> guardar(Nota nota) {
    return _coleccion.doc(nota.id.toString()).set(nota.toJson());
  }

  Future<void> eliminar(int id) {
    return _coleccion.doc(id.toString()).delete();
  }
}
