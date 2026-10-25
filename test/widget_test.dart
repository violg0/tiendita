import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiendatech/models/product.dart';
import 'package:tiendatech/screens/product_detail_page.dart';

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
    var saved = false;
    await tester.pumpWidget(
      MaterialApp(
        home: ProductDetailPage(
          product: product,
          onSave: (_, _, _) async => saved = true,
        ),
      ),
    );

    await tester.tap(find.text('Guardar'));
    await tester.pump();

    expect(find.text('La prioridad debe ser 2 o mayor para guardar'),
        findsOneWidget);
    expect(saved, isFalse);
  });

  testWidgets('prioridad 2 o mayor llama a guardar', (tester) async {
    var saved = false;
    await tester.pumpWidget(
      MaterialApp(
        home: ProductDetailPage(
          product: product,
          onSave: (_, _, _) async => saved = true,
        ),
      ),
    );

    await tester.tap(find.text('3'));
    await tester.pump();
    await tester.tap(find.text('Guardar'));
    await tester.pump();

    expect(saved, isTrue);
  });
}
