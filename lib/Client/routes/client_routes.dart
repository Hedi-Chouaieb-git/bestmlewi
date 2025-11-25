import 'package:flutter/material.dart';
import '../pages/cart.dart';
import '../pages/menu.dart';


class AppRoutes {
  static const String home = '/home';
  static const String cart = '/cart';
  static const String menu = '/menu';



  static Map<String, WidgetBuilder> routes = {
    cart: (context) => const CartScreen(),
    menu: (context) => const MainProductsPage(),

  };
}
