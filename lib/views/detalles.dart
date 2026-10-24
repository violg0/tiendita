import 'package:flutter/material.dart';
import 'package:tiendatech/models/producto.dart';
import 'package:tiendatech/services/product_note_storage.dart';
import 'package:tiendatech/services/product_note.dart';

class ProductDetailPage extends StatefulWidget {
  final Producto product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}


class _ProductDetailPageState extends State<ProductDetailPage>{
  final _storage = ProductNoteStorage();
  final _noteController = TextEditingController();
  int _rating = 0;
 
  

  @override
  void initState(){
    _loadLocalNote();
    super.initState();
  }

  @override
  void dispose(){
    _noteController.dispose();
    super.dispose();
  }

  Future <void> _saveLocalNote() async{
    final note = ProductNote(
    productoId: widget.product.id,
    note: _noteController.text.trim(),
    rating: _rating,
    updateAT: DateTime.now()
  );

  await _storage.saveNote(note);
  if(!mounted)return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('the note was saved'))
  );

  }


  Future<void> _loadLocalNote() async{
    final saved = await _storage.getNoteForProduct(widget.product.id);
    if(!mounted || saved == null) return;

    setState((){
      _noteController.text = saved.note;
      _rating= saved.rating;
    });
  }
   

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
  

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.nombre),
        centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: double.infinity,
              height: 220, color: Colors.indigo ),
              const SizedBox(height: 16),
              Text("Titulo"),
              Text(
                widget.product.nombre,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text("categoria"),
              Text(widget.product.categoria),
              const SizedBox(height: 16),
              Text("Descripcion"),
              Text(widget.product.descripcion),
  
            const Text(
              'product feedback',
              style:TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold

              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Comment'
              ),
            ),
            const SizedBox(height: 12),
            Wrap(spacing: 8,
            children: List.generate(5, (index){
              final value = index;
              return ChoiceChip(label: Text('$value'), selected: _rating == value,
              onSelected: (_) { setState(() {
                _rating = value;
              });
              },
              );
            })
            
        ),
        const SizedBox(height : 12),
        ElevatedButton(onPressed: _saveLocalNote, child: Text('Save note'))
        ]
      ),
    ),
  );
  }
}
