import 'package:flutter/material.dart';

// Unified Auth
import '../auth/signin_page.dart';
import '../auth/signup_page.dart';

// Client
import '../Client/Home.dart';
import '../Client/pages/cart.dart';
import '../Client/pages/menu.dart';
import '../Client/pages/order_tracking.dart' as client_tracking;

// Gerant
import '../Gerant/pages/AffecterRole.dart';
import '../Gerant/pages/Commande.dart';
import '../Gerant/pages/Dashboard.dart';
import '../Gerant/pages/order_management.dart';
import '../Gerant/pages/cart.dart';
import '../Gerant/pages/collaborateur.dart';
import '../Gerant/pages/equipecuisine.dart';
import '../Gerant/pages/menu.dart';
import '../Gerant/pages/order.dart';
import '../Gerant/pages/refunds_page.dart';
import '../Gerant/pages/sales point.dart';
import '../Gerant/pages/traking.dart' as gerant_tracking;

// Livreur
import '../Collaborateur/Livreur/Home.dart';
import '../Collaborateur/Livreur/delivery_details_page.dart';

// Coordinateur
import '../Collaborateur/Cordinateur/Home.dart';

class AppRoutes {
  // Unified Auth
  static const String signIn = '/signin';
  static const String signUp = '/signup';

  // Client
  static const String clientHome = '/client/home';
  static const String clientMenu = '/client/menu';
  static const String clientCart = '/client/cart';
  static const String clientOrderTracking = '/client/order-tracking';

  // Gerant
  static const String gerantDashboard = '/gerant/dashboard';
  static const String gerantMenu = '/gerant/menu';
  static const String gerantCart = '/gerant/cart';
  static const String gerantOrders = '/gerant/orders';
  static const String gerantTracking = '/gerant/tracking';
  static const String gerantCommand = '/gerant/command';
  static const String gerantOrderManagement = '/gerant/order-management';
  static const String gerantRoles = '/gerant/roles';
  static const String gerantSalesPoints = '/gerant/sales-points';
  static const String gerantKitchen = '/gerant/kitchen';
  static const String gerantTeam = '/gerant/team';
  static const String gerantRefunds = '/gerant/refunds';

  static const String livreurHome = '/livreur/home';
  // Note: deliveryDetails route uses MaterialPageRoute with parameters

  // Coordinateur
  static const String coordinateurHome = '/coordinateur/home';

  static Map<String, WidgetBuilder> routes = {
    // Unified Auth
    signIn: (context) => const SignInPage(),
    signUp: (context) => const SignUpPage(),

    // Client
    clientHome: (context) => const ClientHomePage(),
    clientMenu: (context) => const ClientMenuPage(),
    clientCart: (context) => const ClientCartScreen(),
    clientOrderTracking: (context) => const client_tracking.OrderTrackingPage(),

    // Gerant
    gerantDashboard: (context) => const DashboardPage(),
    gerantCart: (context) => const GerantCartScreen(),
    gerantOrders: (context) => const OrderDetailsPage(),
    gerantTracking: (context) => const gerant_tracking.OrderTrackingPage(),
    gerantCommand: (context) => const Command(),
    gerantOrderManagement: (context) => const GerantOrderManagementPage(),
    gerantRoles: (context) => AffecterRolePage(),
    gerantSalesPoints: (context) => PointDeVentePage(),
    gerantKitchen: (context) => EquipeCuisinePage(),
    gerantTeam: (context) => CollaborateursPage(),
    gerantRefunds: (context) => const RefundsPage(),

    // Livreur
    livreurHome: (context) => const LivreurHomePage(),

    // Coordinateur
    coordinateurHome: (context) => const CoordinatorHomePage(),
  };
}
