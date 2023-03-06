import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/order_provider.dart';
import 'package:shop_app/providers/products_provider.dart';

import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  static const routeName = 'cart_screen';

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final totalCost = cartProvider.totalCost;
    final cart = cartProvider.cart.entries.toList();

    final orderProvider = Provider.of<OrdersProvider>(context);
    final orderList = orderProvider.orders;

    final productsProvider = Provider.of<ProductsProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Your Cart"),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return CartItem(cart[index]);
                },
                itemCount: cart.length,
              ),
            ),
            Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  const Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Spacer(),
                  Chip(label: Text('\$$totalCost')),
                  const SizedBox(
                    width: 10,
                  ),
                  FilledButton(
                    onPressed: cart.isEmpty
                        ? null
                        : () async {
                            bool ordered = await showDialog(
                                context: context,
                                builder: (ctx) {
                                  return AlertDialog(
                                    title: const Text("Order confirmation"),
                                    content: const Text(
                                      "Do you really want to proceed the order?",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context, false);
                                        },
                                        child: const Text("Cancel"),
                                      ),
                                      FilledButton(
                                        onPressed: () {
                                          Navigator.pop(context, true);
                                        },
                                        child: const Text("OK"),
                                      ),
                                    ],
                                    actionsAlignment: MainAxisAlignment.end,
                                  );
                                });
                            if (ordered) {
                              try {
                                await orderProvider.addOrder(
                                    cart, cartProvider.totalCost);

                                cartProvider.cart.keys
                                    .map((key) => productsProvider.products
                                        .firstWhere(
                                            (element) => key == element.id))
                                    .toList()
                                    .forEach((element) {
                                  element.clearAmountAddedToCart();
                                });

                                cartProvider.clearCart();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text("Ordered successfully")));
                                }
                              } catch (err) {
                                if (context.mounted) {
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
                              }
                            }
                          },
                    child: const Text("ORDER NOW"),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
