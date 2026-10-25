import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/Nota.dart';
import '../models/Producto.dart';

part 'database.g.dart';

// Los ids son los ids de documento de Firestore.
@UseRowClass(Producto)
class Productos extends Table {
  TextColumn get id => text()();
  TextColumn get nombre => text()();
  TextColumn get categoria => text()();
  IntColumn get precio => integer()();
  IntColumn get stock => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@UseRowClass(Nota)
class Notas extends Table {
  TextColumn get id => text()();
  TextColumn get idProducto => text().references(Productos, #id)();
  TextColumn get texto => text()();
  DateTimeColumn get fecha => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ProductNotes extends Table {
  TextColumn get productId => text()();
  TextColumn get note => text()();
  IntColumn get priority => integer()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get pendingSync => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {productId};
}

@DriftDatabase(tables: [Productos, Notas, ProductNotes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'tienda'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(productNotes);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

final db = AppDatabase();