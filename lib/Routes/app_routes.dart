import 'package:flutter/material.dart';

import '../Auth/signin_page.dart';
import '../Auth/signup_page.dart';
import '../Gerant/pages/menu.dart';







class ApRoutes {
  static const String signIn = '/signin';
  static const String signUp = '/signup';
  static const String menu = '/menu';


  static Map<String, WidgetBuilder> routes = {
    signIn: (context) => const SignInScreen(),
    signUp: (context) => const SignUpScreen(),
    menu: (context) => const MainProductsPage(),

  };
}
