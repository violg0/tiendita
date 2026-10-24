import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:tiendatech/services/product_note.dart';

class ProductNoteStorage {
  static const _filename = 'producto_notes.json';

  Future<File> _getFile() async{
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_filename');
  }

  Future<List<ProductNote>> _readAll() async {
    final file = await _getFile();
    if(!await file.exists()) return [];

    final content = await file.readAsString();
    if (content.isEmpty) return [];

    
    final List<dynamic> data = jsonDecode(content);
    return data.map((item) => ProductNote.fromJson(item as Map<String,dynamic>)).toList();
  }

  Future<void> _writeAll(List<ProductNote> notes)async{
    final file = await _getFile();
    final data = notes.map((note) => note.tojson()).toList();
    await file.writeAsString(jsonEncode(data));
  }

  Future<ProductNote?> getNoteForProduct(int product_id) async {
    final notes = await _readAll();

    for (final note in notes) {
      if (note.productoId == product_id) {
        return note;
      }
    }

    return null;
  }

  Future<void> saveNote(ProductNote nota) async{
    final notes = await _readAll();

    notes.removeWhere((item) => item.productoId == nota.productoId);
    notes.add(nota); 

    await _writeAll(notes);
  }
}