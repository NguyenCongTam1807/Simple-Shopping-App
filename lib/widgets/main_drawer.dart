import 'package:flutter/material.dart';
import 'package:shop_app/providers/auth_provider.dart';
import 'package:shop_app/screens/product_management_screen.dart';

import '../screens/orders_screen.dart';
import 'package:provider/provider.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  Widget _buildListTile(
      IconData icon, String title, String? routeName, BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            icon,
            size: 26,
          ),
          title: Text(
            title,
            style: const TextStyle(
                fontFamily: "RobotoCondensed",
                fontSize: 24,
                fontWeight: FontWeight.w600),
          ),
          onTap: () {
            if (routeName != null) {
              Navigator.pushReplacementNamed(context, routeName);
            } else {
              Provider.of<AuthProvider>(context, listen: false).logout();
            }
          },
        ),
        Divider(
          color: Theme.of(context).accentColor,
          thickness: 2,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 120,
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 30),
            alignment: Alignment.centerLeft,
            color: Theme.of(context).accentColor.withOpacity(0.7),
            child: Text(
              "Shopping For Fun",
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 30,
                  color: Theme.of(context).primaryColor),
            ),
          ),
          _buildListTile(Icons.grid_on, "Products Overview", '/', context),
          _buildListTile(
              Icons.history, "Order History", OrdersScreen.routeName, context),
          _buildListTile(Icons.settings, "Product Management",
              ProductManagementScreen.routeName, context),
          _buildListTile(Icons.logout, "Logout", null, context),
        ],
      ),
    );
  }
}
