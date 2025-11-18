import 'package:flutter/material.dart';
import '../pages/auth/signin_page.dart';
import '../pages/auth/signup_page.dart';
import '../home/Home.dart';

class AppRoutes {
  static const String signIn = '/signin';
  static const String signUp = '/signup';
  static const String home = '/home';

  static Map<String, WidgetBuilder> routes = {
    signIn: (context) => const SignInScreen(),
    signUp: (context) => const SignUpScreen(),
  };
}
