import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/Nota.dart';

class NotaService {
  final CollectionReference<Map<String, dynamic>> _coleccion = FirebaseFirestore
      .instance
      .collection('notas');

  Nota _desdeDoc(DocumentSnapshot<Map<String, dynamic>> d) =>
      Nota.fromJson(d.data()!, d.id);

  Future<List<Nota>> listar() async {
    final snapshot = await _coleccion.get();
    return snapshot.docs.map(_desdeDoc).toList();
  }

  Future<List<Nota>> listarPorProducto(String idProducto) async {
    final snapshot = await _coleccion
        .where('id_producto', isEqualTo: idProducto)
        .get();
    return snapshot.docs.map(_desdeDoc).toList();
  }

  Future<Nota?> obtenerPorId(String id) async {
    final doc = await _coleccion.doc(id).get();
    return doc.exists ? _desdeDoc(doc) : null;
  }

  /// Si [nota.id] esta vacio crea un documento con id automatico.
  Future<String> guardar(Nota nota) async {
    if (nota.id.isEmpty) {
      final ref = await _coleccion.add(nota.toJson());
      return ref.id;
    }
    await _coleccion.doc(nota.id).set(nota.toJson());
    return nota.id;
  }

  Future<void> eliminar(String id) {
    return _coleccion.doc(id).delete();
  }
}