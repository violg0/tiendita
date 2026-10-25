import 'package:flutter/material.dart';
import '../models/product.dart';
import '../repository/database.dart';
import '../repository/product_note_repository.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  /// Callback de guardado (ya no se usa; se deja para no romper product_screen).
  final Future<void> Function(Product product, int priority, String note)?
      onSave;

  /// Repository a usar. Si es null se crea el real (Drift + Firestore).
  /// Las pruebas pasan uno falso.
  final ProductNoteRepository? repository;

  const ProductDetailPage({
    super.key,
    required this.product,
    this.onSave,
    this.repository,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final _noteController = TextEditingController();
  int _priority = 1;
  late final ProductNoteRepository _repository;
  ProductNote? _saved;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ProductNoteRepository();
    _loadNote();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadNote() async {
    final saved = await _repository.getNote(widget.product.id);
    if (!mounted) return;
    setState(() {
      _saved = saved;
      _noteController.text = saved?.note ?? '';
      _priority = saved?.priority ?? 1;
    });
  }

  Future<void> _save() async {
    if (_priority < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La prioridad debe ser 2 o mayor para guardar'),
        ),
      );
      return;
    }
    final synced = await _repository.saveNote(
      productId: widget.product.id,
      note: _noteController.text.trim(),
      priority: _priority,
    );
    final saved = await _repository.getNote(widget.product.id);
    if (!mounted) return;
    setState(() => _saved = saved);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(synced
            ? 'Nota guardada y sincronizada'
            : 'Nota guardada en el dispositivo. Pendiente de sincronizar'),
      ),
    );
  }

  Future<void> _syncPending() async {
    final result = await _repository.syncPending();
    final saved = await _repository.getNote(widget.product.id);
    if (!mounted) return;
    setState(() => _saved = saved);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.total == 0
            ? 'No hay registros pendientes'
            : 'Sincronizados ${result.sent} de ${result.total}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      appBar: AppBar(title: Text(product.nombre)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(
            height: 200,
            child: Image.asset(
              product.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.image_not_supported, size: 64),
            ),
          ),
          const SizedBox(height: 16),
          Text(product.nombre, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(product.descripcion),
          const SizedBox(height: 16),
          const Text('Prioridad'),
          Wrap(
            spacing: 8,
            children: [
              for (var p = 1; p <= 5; p++)
                ChoiceChip(
                  label: Text('$p'),
                  selected: _priority == p,
                  onSelected: (_) => setState(() => _priority = p),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Nota',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _saved == null
                ? 'No hay información guardada'
                : _saved!.pendingSync
                    ? 'Pendiente'
                    : 'Sincronizado',
          ),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _save, child: const Text('Guardar')),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _syncPending,
            child: const Text('Sincronizar pendientes'),
          ),
        ],
      ),
    );
  }
}