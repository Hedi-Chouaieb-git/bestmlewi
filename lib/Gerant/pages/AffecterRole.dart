import 'package:flutter/material.dart';

class AffecterRolePage extends StatefulWidget {
  @override
  State<AffecterRolePage> createState() => _AffecterRolePageState();
}

class _AffecterRolePageState extends State<AffecterRolePage> {
  String? selectedUser = 'Sami';
  String? selectedRole;
  String? selectedPoint;

  final List<String> users = ['Sami', 'John', 'Leila'];
  final List<String> roles = ['Cuisinier', 'Livreur', 'Chef'];
  final List<String> points = ['TopMlawi Centre', 'Point 2', 'Point 3'];

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
              const SizedBox(height: 38),
              // Title
              const Text(
                'AFFECTER UN RÔLE',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 240,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 44),

              // Dropdown fields
              _buildDropdownField(
                value: selectedUser,
                hint: 'Sami',
                items: users,
                onChanged: (val) => setState(() => selectedUser = val),
              ),
              const SizedBox(height: 30),
              _buildDropdownField(
                value: selectedRole,
                hint: 'Nouveau rôle',
                items: roles,
                onChanged: (val) => setState(() => selectedRole = val),
              ),
              const SizedBox(height: 30),
              _buildDropdownField(
                value: selectedPoint,
                hint: 'Point de vente:',
                items: points,
                onChanged: (val) => setState(() => selectedPoint = val),
              ),

              const Spacer(),

              // Buttons
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Save Button
                    SizedBox(
                      width: 180,
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
                          'SAUVEGARDER',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 22),
                    // Cancel Button
                    SizedBox(
                      width: 180,
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
                          'ANNULER',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
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

  Widget _buildDropdownField({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF424242),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(
              color: Color(0xFF7C7C8D),
              fontSize: 20,
              fontFamily: 'Montserrat',
            ),
          ),
          items: items
              .map((e) => DropdownMenuItem(
            value: e,
            child: Text(
              e,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'Montserrat',
              ),
            ),
          ))
              .toList(),
          dropdownColor: const Color(0xFF424242),
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFF6B35), size: 32),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
