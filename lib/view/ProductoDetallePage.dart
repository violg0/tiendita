import 'package:flutter/material.dart';
import 'package:tiendatech/models/Nota.dart' show Nota;
import 'package:tiendatech/models/Producto.dart' show Producto;
import 'package:tiendatech/services/categoria/categoria_service.dart'
    show CategoriaService;
import 'package:tiendatech/services/producto/ProductoLocalService.dart'
    show NotaLocalService;

/// Pantalla con toda la información de un [Producto].
/// Permite elegir una prioridad (1 a 5 estrellas) y guardar notas personales
/// en la base local (Drift). Las notas se pueden ver (con scroll) y eliminar.
///
/// Los servicios llegan por el constructor (inyección de dependencias).
class ProductoDetallePage extends StatefulWidget {
  final Producto producto;
  final NotaLocalService notaService;
  final CategoriaService categoriaService;

  ProductoDetallePage({
    super.key,
    required this.producto,
    NotaLocalService? notaService,
    CategoriaService? categoriaService,
  }) : notaService = notaService ?? NotaLocalService(),
       categoriaService = categoriaService ?? CategoriaService();

  @override
  State<ProductoDetallePage> createState() => _ProductoDetallePageState();
}

class _ProductoDetallePageState extends State<ProductoDetallePage> {
  static const int _prioridadMaxima = 5;

  final TextEditingController _textoController = TextEditingController();
  late final Stream<List<Nota>> _notasStream;

  int _prioridad = 1;
  String? _nombreCategoria;

  @override
  void initState() {
    super.initState();
    // Se crea una sola vez para que la lista no parpadee al redibujar.
    _notasStream = widget.notaService.observarPorProducto(widget.producto.id);
    _cargarCategoria();
  }

  @override
  void dispose() {
    _textoController.dispose();
    super.dispose();
  }

  // ---------- LÓGICA ----------

  Future<void> _cargarCategoria() async {
    try {
      final categoria = await widget.categoriaService.obtenerPorId(
        widget.producto.idCategoria,
      );
      if (!mounted) return;
      setState(() => _nombreCategoria = categoria?.nombre);
    } catch (_) {
      // Si falla, se muestra el id de la categoría como respaldo.
    }
  }

  Future<void> _guardarNota() async {
    final texto = _textoController.text.trim();

    if (texto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe una nota antes de guardar')),
      );
      return;
    }

    final id = await widget.notaService.siguienteId();
    await widget.notaService.guardar(
      Nota(
        id: id,
        idProducto: widget.producto.id,
        texto: texto,
        fecha: DateTime.now(),
      ),
    );

    if (!mounted) return;
    FocusScope.of(context).unfocus();
    _textoController.clear();
    setState(() => _prioridad = 1);
  }

  Future<void> _eliminarNota(int id) {
    return widget.notaService.eliminar(id);
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  // ---------- INTERFAZ ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.producto.nombre)),
      // Todo vive dentro de un ListView, así la pantalla completa
      // hace scroll aunque haya muchas notas.
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _construirImagen(),
          const SizedBox(height: 16),
          _construirInformacion(),
          const Divider(height: 32),
          _construirSeccionNueva(),
          const Divider(height: 32),
          _construirSeccionNotas(),
        ],
      ),
    );
  }

  Widget _construirImagen() {
    final url = widget.producto.imagen;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: (url == null || url.isEmpty)
            ? _construirPlaceholder()
            : Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) =>
                    _construirPlaceholder(),
              ),
      ),
    );
  }

  Widget _construirPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported, size: 60),
    );
  }

  Widget _construirInformacion() {
    final textos = Theme.of(context).textTheme;
    final categoria =
        _nombreCategoria ?? 'Categoría #${widget.producto.idCategoria}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.producto.nombre, style: textos.headlineSmall),
        const SizedBox(height: 8),
        Text('Precio: \$${widget.producto.precio}', style: textos.titleMedium),
        const SizedBox(height: 4),
        Text('Categoría: $categoria', style: textos.bodyMedium),
        const SizedBox(height: 4),
        Text('Código: ${widget.producto.id}', style: textos.bodySmall),
      ],
    );
  }

  Widget _construirSeccionNueva() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Prioridad', style: Theme.of(context).textTheme.titleMedium),
        _construirSelectorPrioridad(),
        const SizedBox(height: 8),
        TextField(
          controller: _textoController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Nota personal',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _guardarNota,
            child: const Text('Guardar nota'),
          ),
        ),
      ],
    );
  }

  Widget _construirSelectorPrioridad() {
    return Row(
      children: List.generate(_prioridadMaxima, (index) {
        final nivel = index + 1;
        final seleccionada = nivel <= _prioridad;

        return IconButton(
          color: Colors.amber,
          icon: Icon(seleccionada ? Icons.star : Icons.star_border),
          onPressed: () => setState(() => _prioridad = nivel),
        );
      }),
    );
  }

  Widget _construirSeccionNotas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mis notas', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _construirListaNotas(),
      ],
    );
  }

  Widget _construirListaNotas() {
    return StreamBuilder<List<Nota>>(
      stream: _notasStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final notas = snapshot.data!;
        if (notas.isEmpty) {
          return const Text('Aún no tienes notas para este producto');
        }

        return Column(children: notas.map(_construirNota).toList());
      },
    );
  }

  Widget _construirNota(Nota nota) {
    return Card(
      child: ListTile(
        title: Text(nota.texto),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _eliminarNota(nota.id),
        ),
      ),
    );
  }
}
