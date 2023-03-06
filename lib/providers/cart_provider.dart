import 'package:flutter/material.dart';

import '../models/product.dart';

class CartProduct {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartProduct({
    required this.id, required this.title, required this.quantity, required this.price
  });
}

class CartProvider with ChangeNotifier {
  Map<String, CartProduct> _cart = {};

  Map<String, CartProduct> get cart => _cart;

  double get totalCost {
    var sum = 0.0;
    _cart.forEach((key, value) {
      sum+= value.price*value.quantity;
    });

    return sum;
  }

  addToCart(Product product) {
    if (_cart.containsKey(product.id)) {
      _cart.update(product.id, (oldCartItem) => CartProduct(
        id: oldCartItem.id,
        title: oldCartItem.title,
        quantity: oldCartItem.quantity+1,
        price: oldCartItem.price,
      ));
    } else {
      _cart.putIfAbsent(product.id, () => CartProduct(
      id: DateTime.now().toString(),
      title: product.title,
      quantity: 1,
      price: product.price,
    ));
    }
    notifyListeners();
  }

  remove1FromCart(Product product) {
    if (_cart.containsKey(product.id)) {
      if (_cart[product.id]?.quantity == 1) {
        _cart.remove(product.id);
      } else {
        _cart.update(product.id, (oldCartItem) => CartProduct(
          id: oldCartItem.id,
          title: oldCartItem.title,
          quantity: oldCartItem.quantity-1,
          price: oldCartItem.price,
        ));
      }
    }
    notifyListeners();
  }

  MapEntry<String, CartProduct>? removeAllFromCart(Product product) {
    if (_cart.containsKey(product.id)) {
      final mapEntry = MapEntry(product.id, _cart[product.id]!);
      _cart.remove(product.id);
      notifyListeners();
      return mapEntry;
    }
    return null;
  }

  undoRemoveAllFromCart(MapEntry<String, CartProduct> mapEntry) {
    _cart.putIfAbsent(mapEntry.key, () => mapEntry.value);
    notifyListeners();
  }

  clearCart() {
    _cart.clear();
    notifyListeners();
  }
}