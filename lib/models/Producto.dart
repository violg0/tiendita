class Producto {
  final String id;
  final String nombre;
  final String categoria;
  final int precio;
  final int stock;

  Producto({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.precio,
    required this.stock,
  });

  /// [id] es el id del documento en Firestore (no va dentro de los campos).
  factory Producto.fromJson(Map<String, dynamic> json, String id) {
    return Producto(
      id: id,
      nombre: json["nombre"],
      categoria: json["categoria"],
      precio: (json["precio"] as num).toInt(),
      stock: (json["stock"] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    "nombre": nombre,
    "categoria": categoria,
    "precio": precio,
    "stock": stock,
  };
}