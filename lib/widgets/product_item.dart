import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/product.dart';
import 'package:shop_app/providers/auth_provider.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/product_details_screen.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({super.key});

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context);
    final cart = Provider.of<CartProvider>(context, listen: false);
    final products = Provider.of<ProductsProvider>(context, listen: false);
    return Card(
      elevation: 5,
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.pushNamed(context, ProductDetailsScreen.routeName,
                    arguments: product);
              },
              child: Hero(
                tag: product.id,
                child: FadeInImage(
                  placeholder: const AssetImage(
                      'assets/images/006 product-placeholder.png'),
                  fadeInDuration: const Duration(milliseconds: 300),
                  fadeOutDuration: const Duration(milliseconds: 300),
                  image: NetworkImage(product.imageUrl),
                  fit: BoxFit.contain,
                  placeholderFit: BoxFit.contain,
                  imageErrorBuilder: (context, object, stackTrace) {
                    return Container(color: Colors.red.withOpacity(0.2),);
                  },
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                  Colors.black,
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ])),
                child: Text(
                  product.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).primaryColorLight),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                      child: Consumer<Product>(
                        builder: (context, value, widget) => Icon(
                          product.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.red,
                        ),
                      ),
                      onTap: () {
                        try {
                          product.toogleFavorite(
                              products.userId, product.id, products.token);
                        } catch (err) {
                          showDialog(
                              context: context,
                              builder: (ctx) {
                                return AlertDialog(
                                  title: const Text("Oops"),
                                  content: Text(err.toString()),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("OK"),
                                    )
                                  ],
                                );
                              });
                        }
                      }),
                  Row(
                    children: [
                      InkWell(
                        child: Icon(
                          Icons.remove_circle_outline,
                          color: Theme.of(context).primaryColorDark,
                          size: 17,
                        ),
                        onTap: () {
                          cart.remove1FromCart(product);
                          product.removeFromCart();
                        },
                      ),
                      CircleAvatar(
                        radius: 8,
                        child: Text(
                          "${product.itemAdded}",
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      InkWell(
                        child: Icon(
                          Icons.add_circle_outline,
                          color: Theme.of(context).primaryColorDark,
                          size: 17,
                        ),
                        onTap: () {
                          cart.addToCart(product);
                          product.addToCart();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
