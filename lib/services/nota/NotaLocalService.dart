import 'package:drift/drift.dart';

import '../../models/Nota.dart';
import '../../repository/database.dart';

class NotaLocalService {
  final AppDatabase _db;
  NotaLocalService([AppDatabase? database]) : _db = database ?? db;

  Future<List<Nota>> listar() {
    return (_db.select(
      _db.notas,
    )..orderBy([(n) => OrderingTerm.desc(n.fecha)])).get();
  }

  Future<Nota?> obtenerPorId(String id) {
    return (_db.select(
      _db.notas,
    )..where((n) => n.id.equals(id))).getSingleOrNull();
  }

  Future<List<Nota>> listarPorProducto(String idProducto) {
    return (_db.select(_db.notas)
          ..where((n) => n.idProducto.equals(idProducto))
          ..orderBy([(n) => OrderingTerm.desc(n.fecha)]))
        .get();
  }

  Stream<List<Nota>> observarPorProducto(String idProducto) {
    return (_db.select(_db.notas)
          ..where((n) => n.idProducto.equals(idProducto))
          ..orderBy([(n) => OrderingTerm.desc(n.fecha)]))
        .watch();
  }

  Future<void> guardar(Nota n) {
    return _db
        .into(_db.notas)
        .insertOnConflictUpdate(
          NotasCompanion(
            id: Value(n.id),
            idProducto: Value(n.idProducto),
            texto: Value(n.texto),
            fecha: Value(n.fecha),
          ),
        );
  }

  Future<void> eliminar(String id) {
    return (_db.delete(_db.notas)..where((n) => n.id.equals(id))).go();
  }
}