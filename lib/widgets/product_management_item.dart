import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';

import '../models/product.dart';
import '../screens/product_details_screen.dart';
import '../screens/product_edit_screen.dart';

class ProductManagementItem extends StatelessWidget {
  const ProductManagementItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<Product>(context);
    final productsProvider = Provider.of<ProductsProvider>(context);

    return Card(
      elevation: 5,
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, ProductDetailsScreen.routeName,
                    arguments: productProvider);
              },
              child: Image.network(
                productProvider.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, exception, stackTrace) {
                  return const SizedBox();
                },
              ),
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.8),
                  Colors.black,
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                ])),
                child: Text(
                  productProvider.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).primaryColorLight),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                      child: Consumer<Product>(
                        builder: (context, value, widget) => const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                      onTap: () async {
                        try {
                          await productsProvider
                              .removeProduct(productProvider.thisProduct);
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
                  InkWell(
                    child: Icon(
                      Icons.edit,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) => ProductEditScreen(
                              product: productProvider.thisProduct),
                        ),
                      );
                    },
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
