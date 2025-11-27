import 'package:flutter/material.dart';
import 'package:supabase_app/Gerant/pages/Dashboard.dart';

// Auth
import '../Auth/signin_page.dart';
import '../Auth/signup_page.dart';

// Client
import '../Client/Home.dart';
import '../Client/pages/cart.dart';
import '../Client/pages/menu.dart';

// Gerant
import '../Gerant/pages/AffecterRole.dart';
import '../Gerant/pages/Commande.dart';
import '../Gerant/pages/Dashboard.dart';
import '../Gerant/pages/cart.dart';
import '../Gerant/pages/collaborateur.dart';
import '../Gerant/pages/equipecuisine.dart';
import '../Gerant/pages/menu.dart';
import '../Gerant/pages/order.dart';
import '../Gerant/pages/sales point.dart';
import '../Gerant/pages/traking.dart';
import '../Gerant/pages/auth/signin_page.dart';
import '../Gerant/pages/auth/signup_page.dart';

// Livreur
import '../Collaborateur/Livreur/Home.dart';

class AppRoutes {
  // Public auth
  static const String signIn = '/signin';
  static const String signUp = '/signup';
  static const String dashboard = '/dashboard';

  // Client
  static const String clientHome = '/client/home';
  static const String clientMenu = '/client/menu';
  static const String clientCart = '/client/cart';

  // Gerant auth + dashboard
  static const String gerantSignIn = '/gerant/signIn';
  static const String gerantSignUp = '/gerant/signup';
  static const String gerantDashboard = '/gerant/dashboard';
  static const String gerantMenu = '/gerant/menu';
  static const String gerantCart = '/gerant/cart';
  static const String gerantOrders = '/gerant/orders';
  static const String gerantTracking = '/gerant/tracking';
  static const String gerantCommand = '/gerant/command';
  static const String gerantRoles = '/gerant/roles';
  static const String gerantSalesPoints = '/gerant/sales-points';
  static const String gerantKitchen = '/gerant/kitchen';
  static const String gerantTeam = '/gerant/team';

  // Livreur
  static const String livreurHome = '/livreur/home';

  static Map<String, WidgetBuilder> routes = {
    // Auth
    signIn: (context) => const SignInScreen(),
    signUp: (context) => const SignUpScreen(),
    dashboard: (context) =>  DashboardPage(),

    // Client
    clientHome: (context) => const ClientHomePage(),
    clientMenu: (context) => const ClientMenuPage(),
    clientCart: (context) => const ClientCartScreen(),

    // Gerant auth + dashboard
    gerantSignIn: (context) => const GerantSignInScreen(),
    gerantSignUp: (context) => const GerantSignUpScreen(),
    gerantDashboard: (context) => const DashboardPage(),
    gerantMenu: (context) => const GerantMenuPage(),
    gerantCart: (context) => const GerantCartScreen(),
    gerantOrders: (context) => const OrderDetailsPage(),
    gerantTracking: (context) => const OrderTrackingPage(),
    gerantCommand: (context) => const Command(),
    gerantRoles: (context) => AffecterRolePage(),
    gerantSalesPoints: (context) => PointDeVentePage(),
    gerantKitchen: (context) => EquipeCuisinePage(),
    gerantTeam: (context) => CollaborateursPage(),

    // Livreur
    livreurHome: (context) => const LivreurHomePage(),
  };
}
