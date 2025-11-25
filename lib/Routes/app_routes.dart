import 'package:flutter/material.dart';
import 'package:supabase_app/Gerant/pages/Dashboard.dart';

import '../Auth/signin_page.dart';
import '../Auth/signup_page.dart';
import '../Gerant/pages/menu.dart';






class AppRoutes {
  static const String signIn = '/signin';
  static const String signUp = '/signup';
  static const String dashboard = '/dashboard';


  static const String menu = '/menu';






  static Map<String, WidgetBuilder> routes = {
    signIn: (context) => const SignInScreen(),
    signUp: (context) => const SignUpScreen(),
    dashboard: (context) =>  DashboardPage(),

    menu: (context) => const MainProductsPage(),


  };
}
