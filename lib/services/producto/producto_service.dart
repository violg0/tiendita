import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/Producto.dart';

class ProductoService {
  final CollectionReference<Map<String, dynamic>> _coleccion = FirebaseFirestore
      .instance
      .collection('productos');

  Producto _desdeDoc(DocumentSnapshot<Map<String, dynamic>> d) =>
      Producto.fromJson(d.data()!, d.id);

  Future<List<Producto>> listar() async {
    final snapshot = await _coleccion.get();
    return snapshot.docs.map(_desdeDoc).toList();
  }

  Stream<List<Producto>> observar() {
    return _coleccion.snapshots().map(
      (s) => s.docs.map(_desdeDoc).toList(),
    );
  }

  Future<Producto?> obtenerPorId(String id) async {
    final doc = await _coleccion.doc(id).get();
    return doc.exists ? _desdeDoc(doc) : null;
  }

  Future<List<Producto>> listarPorCategoria(String categoria) async {
    final snapshot = await _coleccion
        .where('categoria', isEqualTo: categoria)
        .get();
    return snapshot.docs.map(_desdeDoc).toList();
  }

  /// Si [producto.id] esta vacio crea un documento con id automatico;
  /// si no, lo reemplaza. Devuelve el id del documento.
  Future<String> guardar(Producto producto) async {
    if (producto.id.isEmpty) {
      final ref = await _coleccion.add(producto.toJson());
      return ref.id;
    }
    await _coleccion.doc(producto.id).set(producto.toJson());
    return producto.id;
  }

  Future<void> eliminar(String id) {
    return _coleccion.doc(id).delete();
  }
}