import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/Producto.dart';

class ProductoService {
  final CollectionReference<Map<String, dynamic>> _coleccion = FirebaseFirestore
      .instance
      .collection('productos');

  Future<List<Producto>> listar() async {
    final snapshot = await _coleccion.orderBy('id').get();
    return snapshot.docs.map((d) => Producto.fromJson(d.data())).toList();
  }

  Future<Producto?> obtenerPorId(int id) async {
    final doc = await _coleccion.doc(id.toString()).get();
    final data = doc.data();
    return data == null ? null : Producto.fromJson(data);
  }

  Future<List<Producto>> listarPorCategoria(int idCategoria) async {
    final snapshot = await _coleccion
        .where('id_categoria', isEqualTo: idCategoria)
        .get();
    return snapshot.docs.map((d) => Producto.fromJson(d.data())).toList();
  }

  Future<void> guardar(Producto producto) {
    return _coleccion.doc(producto.id.toString()).set(producto.toJson());
  }

  Future<void> eliminar(int id) {
    return _coleccion.doc(id.toString()).delete();
  }
}
