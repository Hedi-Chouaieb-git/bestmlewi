import 'package:flutter/material.dart';

// Order Details Page (Without Map)
class Command extends StatefulWidget {
  const Command({Key? key}) : super(key: key);

  @override
  State<Command> createState() => _CommandState();
}

class _CommandState extends State<Command> {
  String orderStatus = 'pending';

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
              // Header with Order Number
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      'COMMANDE #125',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 200,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Product Image and Details Container
                        Stack(
                          children: [
                            // Main Container
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(top: 75),
                              padding: const EdgeInsets.fromLTRB(20, 90, 20, 24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF424242),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Client Section
                                  const Text(
                                    'Client: Ali Ben',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoRow('• 55 123 456'),
                                  const SizedBox(height: 4),
                                  _buildInfoRow('• 15 Rue Habib Bourguiba'),

                                  const SizedBox(height: 24),

                                  // Content Section
                                  const Text(
                                    'CONTENU:',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoRow('• 2 x Mlawi Traditionnel'),
                                  const SizedBox(height: 4),
                                  _buildInfoRow('• 1 x Boisson'),

                                  const SizedBox(height: 24),

                                  // Pickup Point Section
                                  const Text(
                                    'POINT DE RETRAIT:',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoRow('• TopMlawi Centre Ville'),
                                  const SizedBox(height: 4),
                                  _buildInfoRow('• 70 987 654'),
                                ],
                              ),
                            ),

                            // Product Image (Positioned at top center)
                            Positioned(
                              left: 0,
                              right: 0,
                              top: 0,
                              child: Center(
                                child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFFF6B35),
                                      width: 6,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/images/shwarma.jpeg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Action Buttons (Positioned on the right side)
                            Positioned(
                              right: 10,
                              top: 160,
                              child: Column(
                                children: [
                                  _buildRoundActionButton(
                                    'ACTUALISER\nPOSITION',
                                        () {
                                      // Handle update position
                                      print('Update position clicked');
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  _buildRoundActionButton(
                                    'RÉCUPÉRÉ AU\nPOINT',
                                        () {
                                      setState(() {
                                        orderStatus = 'picked_up';
                                      });
                                      print('Picked up clicked');
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  _buildRoundActionButton(
                                    'LIVRÉ AU\nCLIENT',
                                        () {
                                      setState(() {
                                        orderStatus = 'delivered';
                                      });
                                      print('Delivered clicked');
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),
                      ],
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

  Widget _buildInfoRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRoundActionButton(String text, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B35),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
