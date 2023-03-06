import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/common/urls.dart';
import 'package:shop_app/models/http_exception.dart';

import '../models/product.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _products = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  String? token;
  String? userId;

  ProductsProvider(
      String? passedToken, String? passedUserId, List<Product> passedProducts) {
    token = passedToken;
    _products = passedProducts;
    userId = passedUserId;
  }

  var showFavoriteOnly = false;
  List<Product> get products {
    if (showFavoriteOnly) {
      return _products.where((element) => element.isFavorite == true).toList();
    } else {
      return _products;
    }
  }

  List<Product> get favoriteProducts {
    return _products.where((element) => element.isFavorite == true).toList();
  }

  void showFavorite() {
    showFavoriteOnly = true;
    notifyListeners();
  }

  void showAll() {
    showFavoriteOnly = false;
    notifyListeners();
  }

  List<Product> _cart = [];
  List<Product> get cart => _cart;

  Future<void> fetchProducts([bool filterByUser = true]) async {
    try {
      final filterString = filterByUser?'&orderBy="creatorId"&equalTo="$userId"':"";
      final productsResponse =
          await http.get(Uri.parse("$getProducts?auth=$token$filterString"));
      Map<String, dynamic> fetchedProducts = json.decode(productsResponse.body);

      final favoriteResponse = await http
          .get(Uri.parse("$baseUrl/userFavorites/$userId.json?auth=$token"));
      Map<String, dynamic>? fetchedFavorites =
          json.decode(favoriteResponse.body);

      final List<Product> productList = [];
      fetchedProducts.entries.map((e) {
        productList.add(Product(
          id: e.key,
          description: e.value['description'],
          price: e.value['price'],
          title: e.value['title'],
          imageUrl: e.value['imageUrl'] ?? "",
          isFavorite: fetchedFavorites == null
              ? false
              : fetchedFavorites[e.key] ?? false,
        ));
      }).toList();
      _products = productList;
      notifyListeners();
    } catch (err) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.tryParse("$getProducts?auth=$token");
    if (url != null) {
      try {
        await Future.delayed(const Duration(seconds: 3));
        final response = await http.post(url,
            body: json.encode({
              'id': product.id,
              'title': product.title,
              'price': product.price,
              'description': product.description,
              'imageUrl': product.imageUrl,
              'creatorId': userId,
            }));
        if (response.statusCode == 200) {
          _products.add(product);
          notifyListeners();
        }
      } catch (err) {
        rethrow;
      }
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final url = '${baseUrl}/products/$id.json?auth=$token';
    try {
      final response = await http.patch(Uri.parse(url),
          body: json.encode({
            'title': newProduct.title,
            'price': newProduct.price,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'isFavorite': newProduct.isFavorite,
          }));
      if (response.statusCode == 200) {
        final product = _products.firstWhere((element) => element.id == id);
        product.title = newProduct.title;
        product.description = newProduct.description;
        product.price = newProduct.price;
        product.imageUrl = newProduct.imageUrl;
        notifyListeners();
      }
    } catch (err) {
      rethrow;
    }
  }

  void removeProductAt(int index) {
    _products.removeAt(index);
    notifyListeners();
  }

  Future<void> removeProduct(Product product) async {
    final index = _products.indexWhere((element) => element.id == product.id);
    final url = '$baseUrl/products/${product.id}.json?auth=$token';
    final response = await http.delete(Uri.parse(url));
    try {
      if (response.statusCode >= 400) {
        throw const HttpException('Something is wrong, cannot delete product');
      } else {
        _products.removeAt(index);
        notifyListeners();
      }
    } catch (err) {
      rethrow;
    }
  }

  void addToCart(Product product) {
    _products.add(product);
    notifyListeners();
  }

  void removeFromCartAt(int index) {
    _products.removeAt(index);
    notifyListeners();
  }

  void removeFromCart(Product product) {
    _products.remove(product);
    notifyListeners();
  }
}
