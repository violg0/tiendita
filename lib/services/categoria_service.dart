import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/Categoria.dart';

class CategoriaService {
  final CollectionReference<Map<String, dynamic>> _coleccion =
      FirebaseFirestore.instance.collection('categorias');

  Future<List<Categoria>> listar() async {
    final snapshot = await _coleccion.orderBy('id').get();
    return snapshot.docs.map((d) => Categoria.fromJson(d.data())).toList();
  }

  Future<Categoria?> obtenerPorId(int id) async {
    final doc = await _coleccion.doc(id.toString()).get();
    final data = doc.data();
    return data == null ? null : Categoria.fromJson(data);
  }

  Future<void> guardar(Categoria categoria) {
    return _coleccion.doc(categoria.id.toString()).set(categoria.toJson());
  }

  Future<void> eliminar(int id) {
    return _coleccion.doc(id.toString()).delete();
  }
}
