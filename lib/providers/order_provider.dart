import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

import '../common/urls.dart';
import 'cart_provider.dart';

class Order {
  final String id;
  final double totalPrice;
  final List<MapEntry<String, CartProduct>> cartProducts;
  final DateTime dateTime;

  Order(
      {required this.id,
      required this.totalPrice,
      required this.cartProducts,
      required this.dateTime});
}

class OrdersProvider with ChangeNotifier {
  List<Order> _orders = [];

  List<Order> get orders {
    return _orders;
  }

  String? get userId {
    return _userId;
  }

  String? _token;
  String? _userId;

  OrdersProvider(String? passedToken, List<Order> passedOrders, String? passedUserId) {
   _token = passedToken;
   _orders = passedOrders;
   _userId = passedUserId;
  }

  Future<void> fetchOrders() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/orders/$_userId.json?auth=$_token"));
      Map<String, dynamic>? fetchedData = json.decode(response.body);
      if (fetchedData!=null) {
        final orderList = fetchedData.entries.map((e) {
          return Order(
            id: e.key,
            totalPrice: e.value['totalPrice'],
            cartProducts: (e.value['cartProducts'] as List<dynamic>)
                .map((e) => MapEntry(
                e['productId'] as String,
                CartProduct(
                    id: e['id'],
                    title: e['title'],
                    quantity: e['quantity'],
                    price: e['price'])))
                .toList(),
            dateTime: DateTime.parse(e.value['dateTime']),
          );
        }).toList();
        _orders = orderList.reversed.toList();
        notifyListeners();
      }
    } catch (err) {
      rethrow;
    }
  }

  Future<void> addOrder(List<MapEntry<String, CartProduct>> cartProducts,
      double totalPrice) async {
    try {
      final now = DateTime.now();
      final response = await http.post(Uri.parse("$baseUrl/orders/$_userId.json?auth=$_token"),
          body: json.encode({
            'totalPrice': totalPrice,
            'cartProducts': cartProducts
                .map((e) => {
                      'productId': e.key,
                      'id': e.value.id,
                      'price': e.value.price,
                      'quantity': e.value.quantity,
                      'title': e.value.title,
                    })
                .toList(),
            'dateTime': now.toString(),
          }));
      if (response.statusCode / 100 == 2) {
        Order order = Order(
            id: "",
            totalPrice: totalPrice,
            cartProducts: cartProducts,
            dateTime: now);
        _orders.insert(0, order);
        notifyListeners();
      }
    } catch (err) {
      throw HttpException(err.toString());
    }
  }
}
