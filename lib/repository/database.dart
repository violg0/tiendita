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

@DriftDatabase(tables: [Productos, Notas])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'tienda'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

final db = AppDatabase();