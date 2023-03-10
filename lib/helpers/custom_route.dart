import 'package:flutter/material.dart';

class CustomRoute<T> extends MaterialPageRoute<T> {
  CustomRoute({required super.builder});

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    if (settings.name == '/') {
      return super.buildTransitions(context, animation, secondaryAnimation, child);
    } else {
      return FadeTransition(opacity: animation, child: child,);
    }
  }
}