import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth_provider.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/order_provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/product_edit_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/product_details_screen.dart';
import 'package:shop_app/screens/product_management_screen.dart';
import 'package:shop_app/screens/product_overview_screen.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ProductsProvider>(
          update: (ctx, authProvider, previousProduct) => ProductsProvider(
              authProvider.token,
              authProvider.userId,
              previousProduct?.products ?? []),
          create: (_) => ProductsProvider(null, null, []),
        ),
        ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
        ChangeNotifierProxyProvider<AuthProvider, OrdersProvider>(
            update: (ctx, authProvider, previousOrder) => OrdersProvider(
                authProvider.token,
                previousOrder?.orders ?? [],
                authProvider.userId),
            create: (_) => OrdersProvider(null, [], "")),
      ],
      child: Consumer<AuthProvider>(
        builder: (ctx, provider, child) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              primarySwatch: Colors.green,
              accentColor: Colors.amber,
              fontFamily: "Lato",
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
              useMaterial3: true,
            ),
            routes: {
              ProductDetailsScreen.routeName: (ctx) =>
                  const ProductDetailsScreen(),
              CartScreen.routeName: (ctx) => const CartScreen(),
              OrdersScreen.routeName: (ctx) => const OrdersScreen(),
              ProductManagementScreen.routeName: (ctx) =>
                  const ProductManagementScreen(),
              ProductEditScreen.routeName: (ctx) => const ProductEditScreen(),
              AuthScreen.routeName: (ctx) => const AuthScreen(),
            },
            home: provider.authenticated
                ? const ProductOverviewScreen()
                : FutureBuilder(
                    future: provider.autoLogin(),
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      // if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                      //   if (snapshot.data) {
                      //     return const ProductOverviewScreen();
                      //   } return const AuthScreen();
                      // }
                      // return const Center(child: CircularProgressIndicator(),);
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return const AuthScreen();
                    },
                  ),
          );
        },
      ),
    );
  }
}
