import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Supabase
  await Supabase.initialize(
    url: 'https://qxajdhjecopmgvbtbkpu.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF4YWpkaGplY29wbWd2YnRia3B1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM5NzMxMTYsImV4cCI6MjA3OTU0OTExNn0.CB06Fr7jcQPAFctPG7chV9yeF6B2GQldgFyqcrdq7Bc',
  );

=======
import 'Gerant/routes/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://winrzmxneayivpsimfnn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndpbnJ6bXhuZWF5aXZwc2ltZm5uIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMzODI5MjcsImV4cCI6MjA3ODk1ODkyN30.laGMkbHyi4KqpSzzZEZdcWZUWafNyzMP859rqpXmHz8',
  );
>>>>>>> 062d130ce4f8bc2c11a91b7224bb302ca74cee95
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
      initialRoute: ApRoutes.signIn,
      routes: ApRoutes.routes,
      //navigatorKey: AppRoutes.navigatorKey, // Pour navigation globale
    );
  }
}