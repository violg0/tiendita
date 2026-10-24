import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiendatech/components/product_card.dart';
import 'package:tiendatech/services/prodcut_service.dart' show ProductService;
import 'package:tiendatech/views/detalles.dart';
import '../models/producto.dart';

class productoscreen extends StatefulWidget {
  const productoscreen({super.key});

  @override
  State<productoscreen> createState() => _productoscreenState();
}

class _productoscreenState extends State<productoscreen> {
  // Estado de la pantalla.
  // Durante la clase analizaremos qué representa cada variable
  // y cuándo debe cambiar.
  bool isLoading = false;
  List<Producto> productos = [];
  String errorMessage = '';
  int? favoriteId;

  late final ProductService _service;
  late Future<List<Producto>> _futureProducts;
  
  void toggleFavorite(int productoId){
    setState(() {
      if(favoriteId == productoId){
        favoriteId=null;
      }else{
        favoriteId = productoId;
      }

      });
      saveFavorite();
  }

Future<void> saveFavorite() async{
  final prefs= await SharedPreferences.getInstance();

  if (favoriteId == null){
    await prefs.remove('favoriteId');
  }
  else{
    await prefs.setInt('favoriteId', favoriteId!);
  }

}

  Future<void> loadFavorite() async {
    final prefs = await SharedPreferences.getInstance();

    setState((){
      favoriteId = prefs.getInt('favoriteId');
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _service = ProductService('http://localhost:3000/products');
    _futureProducts = _service.getProducts();
  }

  void openProductDetail(Producto producto){
    Navigator.push(context, 
    MaterialPageRoute(builder: (_) => ProductDetailPage(product: producto
    ) 
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Películas'),
      ),
      body: _buildBody(),
    );
  }




  Widget _buildBody() {
    // Empezamos con una interfaz mínima que ya funciona.
    // Este método evolucionará durante los checkpoints.
    
    return FutureBuilder(
      future: _futureProducts,
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Center();
        }

      final productos = snapshot.data ?? [];

      if(errorMessage.isNotEmpty){
        return Center(
          child: Text(errorMessage),
        );
      }

      if (productos.isEmpty){
        return Column(
          children: [ 
          Text("No hay productos disponibles")
          ],
        );
      }

      return ListView.builder(
      itemCount: productos.length,
      itemBuilder: (_, index){
        final producto = productos[index];
        final bool isFavorite = producto.id == favoriteId;
        return ProductCard(producto: producto,
         onTap:(){
          openProductDetail(producto);
        },
        isFavorite: isFavorite,
        onFavoriteTap: (){
          toggleFavorite(producto.id);
        },);
      },
      );

      },
      );

  }
}
