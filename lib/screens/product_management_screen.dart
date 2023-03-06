import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/product_edit_screen.dart';
import 'package:shop_app/widgets/products_grid.dart';

import '../widgets/main_drawer.dart';

class ProductManagementScreen extends StatelessWidget {
  const ProductManagementScreen({Key? key}) : super(key: key);

  static const routeName = 'product_management_screen';

  @override
  Widget build(BuildContext context) {
    final productsProvider =
        Provider.of<ProductsProvider>(context, listen: false);
    print("BUILD");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
        actions: [
          IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        const ProductEditScreen()));
              })
        ],
      ),
      drawer: const MainDrawer(),
      body: FutureBuilder(
        future: productsProvider.fetchProducts(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState != ConnectionState.waiting) {
            return RefreshIndicator(
                onRefresh: productsProvider.fetchProducts,
                child: ProductsGrid(productsProvider.showFavoriteOnly,
                    userPage: false));
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
