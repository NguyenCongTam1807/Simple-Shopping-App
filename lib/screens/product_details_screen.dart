import 'package:flutter/material.dart';
import 'package:shop_app/models/product.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({Key? key}) : super(key: key);

  static const routeName = 'product_details_screen';

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)?.settings.arguments as Product;
    final textStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 20
    );
    return Scaffold(
        appBar: AppBar(
          title: Text("${product.title} Details" ""),
        ),
        body: Column(
          children: [
            Image.network(product.imageUrl),
            Text("\$${product.price}", style: textStyle,),
            Text(product.description, style: textStyle,),
            Icon(
              product.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
          ],
        ));
  }
}
