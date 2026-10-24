import 'package:flutter/material.dart';
import 'package:tiendatech/models/producto.dart';


class ProductCard extends StatelessWidget{

  final Producto producto;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  const ProductCard({
    super.key,
    required this.producto,
    required this.onTap,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context){
    return Card(
          margin: const EdgeInsets.only(
            bottom: 12, 
          ),
          child: InkWell(
            onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row (
              children: [
                ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(10),
                  child: Image.asset(producto.imagePath,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,)
                ),
                const SizedBox(width: 4),
                Expanded(

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto.nombre,
                        style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(producto.categoria),
                      const SizedBox(height: 6),
                      Icon(
                        Icons.check_circle
                      ),
                      IconButton(onPressed: onFavoriteTap, 
                      icon: Icon(isFavorite ? Icons.star : Icons.star_border))
                    ],
                  )
                  )
              ]
            )
          )
          )
          );
  
  }
}

