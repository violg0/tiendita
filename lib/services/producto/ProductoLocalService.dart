import 'package:drift/drift.dart';

import '../../models/Producto.dart';
import '../../repository/database.dart';

class ProductoLocalService {
  final AppDatabase _db;
  ProductoLocalService([AppDatabase? database]) : _db = database ?? db;

  Future<List<Producto>> listar() {
    return (_db.select(
      _db.productos,
    )..orderBy([(p) => OrderingTerm.asc(p.nombre)])).get();
  }

  Stream<List<Producto>> observar({String? categoria}) {
    final consulta = _db.select(_db.productos)
      ..orderBy([(p) => OrderingTerm.asc(p.nombre)]);
    if (categoria != null) {
      consulta.where((p) => p.categoria.equals(categoria));
    }
    return consulta.watch();
  }

  Future<Producto?> obtenerPorId(String id) {
    return (_db.select(
      _db.productos,
    )..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  Future<List<Producto>> listarPorCategoria(String categoria) {
    return (_db.select(
      _db.productos,
    )..where((p) => p.categoria.equals(categoria))).get();
  }

  Future<void> guardar(Producto p) {
    return _db
        .into(_db.productos)
        .insertOnConflictUpdate(
          ProductosCompanion(
            id: Value(p.id),
            nombre: Value(p.nombre),
            categoria: Value(p.categoria),
            precio: Value(p.precio),
            stock: Value(p.stock),
          ),
        );
  }

  Future<void> eliminar(String id) {
    return (_db.delete(_db.productos)..where((p) => p.id.equals(id))).go();
  }
}