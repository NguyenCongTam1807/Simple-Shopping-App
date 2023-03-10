import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/helpers/custom_route.dart';
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin{
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    _slideController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500)
    );
    _slideAnimation = Tween(begin: const Offset(0, 0), end: const Offset(1, 0)).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeInOut));
    super.initState();
  }
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
              pageTransitionsTheme: PageTransitionsTheme(builders: {
                  TargetPlatform.android: CustomPageTransitionBuilder(),
                TargetPlatform.iOS: CustomPageTransitionBuilder(),
              }),
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
            home: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              child: provider.authenticated
                  ? const ProductOverviewScreen()
                  : FutureBuilder(
                    future: provider.autoLogin(),
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return const AuthScreen();
                    },
                  ),
            ),
          );
        },
      ),
    );
  }
}
