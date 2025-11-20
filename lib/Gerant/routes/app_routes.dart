import 'package:flutter/material.dart';
import '../pages/order.dart';
import '../pages/auth/signin_page.dart';
import '../pages/auth/signup_page.dart';
import '../home/Home.dart';
import '../pages/cart.dart';
import '../pages/menu.dart';
import '../pages/traking.dart';


class AppRoutes {
  static const String signIn = '/signin';
  static const String signUp = '/signup';
  static const String home = '/home';
  static const String cart = '/cart';
  static const String menu = '/menu';
  static const String order = '/order';
  static const String traking = '/traking';


  static Map<String, WidgetBuilder> routes = {
    signIn: (context) => const SignInScreen(),
    signUp: (context) => const SignUpScreen(),
    cart: (context) => const CartScreen(),
    menu: (context) => const MainProductsPage(),
    order: (context) => const OrderDetailsPage(),
    traking: (context) => const OrderTrackingPage(),
  };
}
