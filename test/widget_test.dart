import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiendatech/models/product.dart';
import 'package:tiendatech/repository/database.dart';
import 'package:tiendatech/repository/product_note_repository.dart';
import 'package:tiendatech/screens/product_detail_page.dart';

/// Repository falso: no usa Drift ni Firestore, solo recuerda si se guardó.
class FakeRepository implements ProductNoteRepository {
  bool saved = false;

  @override
  Future<ProductNote?> getNote(int productId) async => null;

  @override
  Future<bool> saveNote({
    required int productId,
    required String note,
    required int priority,
  }) async {
    saved = true;
    return true;
  }

  @override
  Future<({int sent, int total})> syncPending() async =>
      (sent: 0, total: 0);
}

void main() {
  const product = Product(
    id: 1,
    nombre: 'Binoculares',
    categoria: 'aire libre',
    precio: 180000,
    imagePath: 'assets/image/binoculares.jpg',
    descripcion: 'Binoculares 10x42',
  );

  testWidgets('prioridad menor a 2 no guarda y muestra mensaje', (tester) async {
    final repo = FakeRepository();
    await tester.pumpWidget(
      MaterialApp(home: ProductDetailPage(product: product, repository: repo)),
    );
    await tester.pump();

    await tester.ensureVisible(find.text('Guardar'));
    await tester.pump();
    await tester.tap(find.text('Guardar'));
    await tester.pump();

    expect(find.text('La prioridad debe ser 2 o mayor para guardar'),
        findsOneWidget);
    expect(repo.saved, isFalse);
  });

  testWidgets('prioridad 2 o mayor guarda con el repository', (tester) async {
    final repo = FakeRepository();
    await tester.pumpWidget(
      MaterialApp(home: ProductDetailPage(product: product, repository: repo)),
    );
    await tester.pump();

    await tester.tap(find.text('3'));
    await tester.pump();
    await tester.ensureVisible(find.text('Guardar'));
    await tester.pump();
    await tester.tap(find.text('Guardar'));
    await tester.pump();

    expect(repo.saved, isTrue);
  });
}
