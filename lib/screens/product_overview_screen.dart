import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/widgets/main_drawer.dart';

import 'package:shop_app/widgets/products_grid.dart';

import '../models/product.dart';

class ProductOverviewScreen extends StatefulWidget {
  const ProductOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  final List<Product> products = [
    Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),
  ];

  var _showFav = false;
  var isInit = false;
  var remoteProducts = [];
  var isLoading = false;
  @override
  Future<void> didChangeDependencies() async {
    if (!isInit) {
      isInit = true;
      isLoading = true;
      await Provider.of<ProductsProvider>(context, listen: false)
          .fetchProducts(false);
      isLoading = false;
      if (mounted) {
        setState(() {});
      }
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainDrawer(),
      appBar: AppBar(
        title: const Text("Product List"),
        actions: [
          SizedBox(
            height: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.local_grocery_store),
                  onPressed: () {
                    Navigator.of(context).pushNamed(CartScreen.routeName);
                  },
                ),
                Positioned(
                  right: 0,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(0.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).accentColor,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child:
                        Consumer<CartProvider>(builder: (_, cartProvider, __) {
                      final numberOfItems = cartProvider.cart.length;
                      return Text(
                        numberOfItems.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton(
              onSelected: (filterOptions) {
                setState(() {
                  _showFav =
                      filterOptions == FilterOptions.favorites ? true : false;
                });
              },
              itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: FilterOptions.favorites,
                      child: Text("Favorite Products"),
                    ),
                    const PopupMenuItem(
                      value: FilterOptions.all,
                      child: Text("All Products"),
                    ),
                  ])
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Provider.of<ProductsProvider>(context, listen: false)
                  .products
                  .isEmpty
              ? const Center(
                  child: Text(
                    "There's no products to display",
                    style: TextStyle(fontSize: 20),
                  ),
                )
              : ProductsGrid(_showFav),
    );
  }
}

enum FilterOptions { all, favorites }
