import 'package:flutter/material.dart';
import 'package:shop_app/providers/order_provider.dart';

import 'package:provider/provider.dart';

import '../widgets/main_drawer.dart';
import '../widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  static const routeName = 'orders_screen';

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrdersProvider>(context, listen: false);

    return Scaffold(
        drawer: const MainDrawer(),
        appBar: AppBar(
          title: const Text("Your Orders"),
        ),
        body: FutureBuilder(
          future: orderProvider.fetchOrders(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.dangerous_outlined,
                      color: Colors.red,
                      size: 40,
                    ),
                    Text("Something is wrong, unable to fetch data"),
                  ],
                ),
              );
            } else {
              return RefreshIndicator(
                onRefresh: () async {
                  return await orderProvider.fetchOrders();
                },
                child: Consumer<OrdersProvider>(
                  builder: (ctx, provider, widget) {
                    return ListView.builder(
                      itemBuilder: (ctx, index) {
                        return OrderItem(provider.orders[index]);
                      },
                      itemCount: provider.orders.length,
                    );
                  },
                ),
              );
            }
          },
        ));
  }
}
