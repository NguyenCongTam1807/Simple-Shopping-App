import 'package:flutter/material.dart';
import 'package:shop_app/models/product.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({Key? key}) : super(key: key);

  static const routeName = 'product_details_screen';

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)?.settings.arguments as Product;
    const textStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 20);
    return Scaffold(
        // appBar: AppBar(
        //   title: Text("${product.title} Details" ""),
        // ),
        body: CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text("${product.title} Details" ""),
            background: Column(
              children: [
                Hero(
                  tag: product.id,
                  child: Container(
                    height: 200,
                      alignment: Alignment.topCenter,
                      child: Image.network(product.imageUrl)),
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            Text(
              "\$${product.price}",
              style: textStyle,
            ),
            Text(
              product.description,
              style: textStyle,
            ),
            Icon(
              product.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            Container(
              color: Colors.red.withOpacity(0.5),
              height: 800,
            )
          ]),
        )
      ],
    ));
  }
}
