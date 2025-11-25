import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              // Page Title
              const Text(
                'TABLEAU DE BORD',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
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
              const SizedBox(height: 24),

              // Chiffres du Jour
              const Text(
                'Chiffres du Jour :',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B35),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF424242),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    // Left column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('• 45 commandes',
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text('• 12 livraisons',
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    // Right column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('• 5 pts ouverts',
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text('• 850 TND CA',
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              // Alertes
              const Text(
                'ALERTES :',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B35),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF424242),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('• TopMlawi Centre : Stock bas',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('• Livreur Sami : Retard',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('• Commande #178 : En attente',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              const SizedBox(height: 38),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B35),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'AFFECTER\nCOMMANDES',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B35),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'GÉRER ÉQUIPE',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 250,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'POINTS DE VENTE',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),

              // Spacer for bottom navigation bar
              const Spacer(),

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
                    // Profile Button
                    const Icon(
                      Icons.person_outline,
                      color: Colors.white,
                      size: 35,
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
