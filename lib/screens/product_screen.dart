import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/api_exception.dart';
import '../services/product_service.dart';
import 'product_detail_page.dart';

String _defaultBaseUrl() {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:3000';
  }
  return 'http://localhost:3000';
}

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late final ProductService _service;
  late Future<List<Product>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _service = ProductService(_defaultBaseUrl());
    _futureProducts = _service.getProducts();
  }

  void _retry() {
    setState(() {
      _futureProducts = _service.getProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TiendaTech')),
      body: FutureBuilder<List<Product>>(
        future: _futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final error = snapshot.error;
            final message = error is ApiException
                ? error.toString()
                : 'Ocurrió un error inesperado';
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    Text(message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _retry,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }
          final products = snapshot.data ?? const <Product>[];
          if (products.isEmpty) {
            return const Center(child: Text('No hay productos disponibles'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                child: ListTile(
                  leading: SizedBox(
                    width: 56,
                    height: 56,
                    child: Image.asset(
                      product.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.image_not_supported),
                    ),
                  ),
                  title: Text(product.nombre),
                  subtitle: Text(product.categoria),
                  trailing: Text('\$${product.precio}'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailPage(product: product),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
