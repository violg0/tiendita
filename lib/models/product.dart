/// Producto del catálogo remoto (respuesta de GET /products).
class Product {
  final int id;
  final String nombre;
  final String categoria;
  final int precio;
  final String imagePath;
  final String descripcion;

  const Product({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.precio,
    required this.imagePath,
    this.descripcion = '',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      nombre: json['nombre'],
      categoria: json['categoria'],
      precio: (json['precio'] as num).toInt(),
      imagePath: json['imagePath'],
      descripcion: json['descripcion'] ?? '',
    );
  }
}
