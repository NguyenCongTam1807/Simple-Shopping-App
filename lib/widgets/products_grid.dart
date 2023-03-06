import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/widgets/product_item.dart';
import 'package:shop_app/widgets/product_management_item.dart';


class ProductsGrid extends StatelessWidget {
  final bool showFavorite;
  final bool userPage;

  const ProductsGrid(this.showFavorite, {this.userPage = true, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductsProvider>(context);
    final products = showFavorite? provider.favoriteProducts: provider.products;

    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        return ChangeNotifierProvider.value(
            value: products[index],
        child: userPage?const ProductItem(): const ProductManagementItem());
      }, itemCount: products.length,);
  }
}
