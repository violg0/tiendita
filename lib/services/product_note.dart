class ProductNote {
  final int productoId;
  final String note;
  final int rating;
  final DateTime updateAT;

  const ProductNote({
    required this.productoId,
    required this.note,
    required this.rating,
    required this.updateAT,
  });

  factory ProductNote.fromJson(Map<String, dynamic> json){
    return ProductNote(
      productoId: json['productoId'],
      note: json['note'],
      rating: json['rating'],
      updateAT: DateTime.parse(json['updated_at'] as String));
  }

  Map <String, dynamic> tojson() =>{
    'product_id': productoId,
    'note': note,
    'rating': rating,
    'updated_at': updateAT.toIso8601String()
  };
}