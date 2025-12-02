import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/notification_service.dart';
import 'Routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Supabase
  await Supabase.initialize(
    url: 'https://qxajdhjecopmgvbtbkpu.supabase.co/',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF4YWpkaGplY29wbWd2YnRia3B1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM5NzMxMTYsImV4cCI6MjA3OTU0OTExNn0.CB06Fr7jcQPAFctPG7chV9yeF6B2GQldgFyqcrdq7Bc',
  );

  // Initialize local notifications
  final notificationService = NotificationService();
  await notificationService.initializeLocalNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Auth App',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      initialRoute: AppRoutes.signIn, // Correction: AppRoutes au lieu de ApRoutes
      routes: AppRoutes.routes, // Correction: AppRoutes au lieu de ApRoutes
    );
  }
}
