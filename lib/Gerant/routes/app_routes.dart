import 'package:flutter/material.dart';

import '../pages/AffecterRole.dart';
import '../pages/Commande.dart';
import '../pages/collaborateur.dart';
import '../pages/order.dart';
import '../pages/auth/signin_page.dart';
import '../pages/auth/signup_page.dart';
import '../pages/cart.dart';
import '../pages/collaborateur.dart';
import '../pages/equipecuisine.dart';
import '../pages/menu.dart';
import '../pages/order.dart';
import '../pages/sales point.dart';
import '../pages/traking.dart';
import '../pages/equipecuisine.dart';
import '../pages/AffecterRole.dart';






class AppRoutes {
  static const String signIn = '/signin';
  static const String signUp = '/signup';
  static const String home = '/home';
  static const String cart = '/cart';
  static const String menu = '/menu';
  static const String order = '/order';
  static const String traking = '/traking';
  static const String commande = '/commande';
  static const String dashboard = '/dashboard';
  static const String salespoint = '/sales_point';
  static const String cuisine = '/equipe_cuisine';
  static const String role = '/role';

  static const String Collaborators = '/collaborator';





  static Map<String, WidgetBuilder> routes = {
    signIn: (context) => const SignInScreen(),
    signUp: (context) => const SignUpScreen(),
    cart: (context) => const CartScreen(),
    menu: (context) => const MainProductsPage(),
    order: (context) => const OrderDetailsPage(),
    traking: (context) => const OrderTrackingPage(),
    commande: (context) => const Command(),
    dashboard: (context) => DashboardPage(),
    salespoint: (context) => PointDeVentePage(),
    cuisine: (context) => EquipeCuisinePage(),
    role: (context) => AffecterRolePage(),
    Collaborators: (context) =>CoordinatorDashboard(coordinatorId: '',),


  };
}
