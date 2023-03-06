import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../common/urls.dart';

class Product with ChangeNotifier {
  final String id;
  String title;
  String description;
  double price;
  String imageUrl;
  bool isFavorite;
  int itemAdded;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
    this.itemAdded = 0,
  });

  Product get thisProduct {
    return this;
  }

  void toogleFavorite(String? userId, String productId, String? token) {
    try {
      isFavorite = !isFavorite;
      notifyListeners();
      final response = http.put(
          Uri.parse("$baseUrl/userFavorites/$userId/$productId.json?auth=$token"), body: json.encode(
          isFavorite
      ));
    } catch (err, stacktrace) {
      print(stacktrace);
      rethrow;
    }
  }

  void addToCart() {
    itemAdded++;
    notifyListeners();
  }

  void removeFromCart() {
    if (itemAdded > 0) {
      itemAdded--;
      notifyListeners();
    }
  }

  void clearAmountAddedToCart() {
    itemAdded = 0;
    notifyListeners();
  }

  void updateProduct(
    String title,
    String description,
    double price,
  ) {
    this.title = title;
    this.description = description;
    this.price = price;
    notifyListeners();
  }
}
