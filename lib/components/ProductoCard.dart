import 'package:flutter/material.dart';
import 'package:tiendatech/models/Producto.dart' show Producto;

class ProductoCard extends StatelessWidget {
  final Producto producto;
  final VoidCallback onTap;

  const ProductoCard({super.key, required this.producto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _construirImagen()),
            Padding(
              padding: const EdgeInsets.all(8),
              child: _construirTextos(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirImagen() {
    final url = producto.imagen;

    if (url.isEmpty) {
      return _construirPlaceholder();
    }

    return Image.network(
      url,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) => _construirPlaceholder(),
    );
  }

  Widget _construirPlaceholder() {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported, size: 40),
    );
  }

  Widget _construirTextos(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          producto.nombre,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        Text(
          '\$${producto.precio.toStringAsFixed(2)}',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
