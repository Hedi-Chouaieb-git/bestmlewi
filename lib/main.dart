import 'package:flutter/material.dart';
import 'Gerant/routes/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://winrzmxneayivpsimfnn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndpbnJ6bXhuZWF5aXZwc2ltZm5uIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMzODI5MjcsImV4cCI6MjA3ODk1ODkyN30.laGMkbHyi4KqpSzzZEZdcWZUWafNyzMP859rqpXmHz8',
  );
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
      initialRoute: AppRoutes.signIn,
      routes: AppRoutes.routes,
    );
  }
}
