import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner
      home: Scaffold(
        backgroundColor: Colors.grey[900], // Dark grey background
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Opacity(
            opacity: 0.1, // 10% opacity
            child: Image.asset(
              'assets/images/group55.png', // Your PNG with transparent BG
              fit: BoxFit.cover, // Full screen cover
            ),
          ),
        ),
      ),
    );
  }
}