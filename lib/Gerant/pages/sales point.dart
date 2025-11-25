import 'package:flutter/material.dart';

class PointDeVentePage extends StatelessWidget {
  // Example sales points list. Replace with your data model.
  final List<Map<String, String>> salesPoints = [
    {
      'title': 'TopMlawi Centre',
      'status': 'OUVERT - 12 cmd',
      'collaborators': 'collaborateurs',
    },
    {
      'title': 'TopMlawi Centre',
      'status': 'OUVERT - 12 cmd',
      'collaborators': 'collaborateurs',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF2B2B2B),
          image: DecorationImage(
            image: AssetImage('assets/images/group55.png'),
            fit: BoxFit.cover,
            opacity: 0.1,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Page Title
              const Text(
                'POINTS DE VENTE',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.3,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: 240,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 34),

              // List of sales points as cards
              Expanded(
                child: ListView.builder(
                  itemCount: salesPoints.length,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemBuilder: (context, index) {
                    final point = salesPoints[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 28),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo image left
                          Container(
                            width: 120,
                            height: 120,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF6B35),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: 80,
                                height: 80,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Details and buttons card
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF424242),
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '• ${point['title']}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '• ${point['status']}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '• ${point['collaborators']}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: 48,
                                          child: ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                              const Color(0xFFFF6B35),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(22),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: const Text(
                                              'STATS',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 18),
                                      Expanded(
                                        child: SizedBox(
                                          height: 48,
                                          child: ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                              const Color(0xFFFF6B35),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(22),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: const Text(
                                              'MODIFIER',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // "Ajouter Point" button
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: SizedBox(
                  width: 260,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'AJOUTER POINT',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Navigation Bar
              Container(
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF2B2B2B),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/images/logo.png',
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                    // Home/Menu Button
                    Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6B35),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                    // Menu Button
                    const Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 35,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
