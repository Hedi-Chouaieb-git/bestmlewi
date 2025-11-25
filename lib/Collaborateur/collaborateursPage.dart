// lib/gerant/screens/collaborateurs_page.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CollaborateursPage extends StatefulWidget {
  const CollaborateursPage({super.key});

  @override
  State<CollaborateursPage> createState() => _CollaborateursPageState();
}

class _CollaborateursPageState extends State<CollaborateursPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> collaborateurs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCollaborateurs();
  }

  Future<void> fetchCollaborateurs() async {
    try {
      final response = await supabase
          .from('collaborateurs')
          .select('idCollab, nom, prenom, telephone, disponible, photo_url')
          .order('nom', ascending: true);

      setState(() {
        collaborateurs = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF2B2B2B),
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

              // Title
              const Text(
                'COLLABORATEURS',
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
              const SizedBox(height: 24),

              // Available count
              Text(
                'EMPLOYÉS DISPONIBLES (${collaborateurs.where((c) => c['disponible'] == true).length})',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),

              // Loading or Grid
              isLoading
                  ? const CircularProgressIndicator(color: Color(0xFFFF6B35))
                  : Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 32,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: collaborateurs.length,
                  itemBuilder: (context, index) {
                    final collab = collaborateurs[index];
                    final bool isAvailable = collab['disponible'] ?? false;
                    final String fullName = "${collab['prenom'] ?? ''} ${collab['nom'] ?? 'Collaborateur'}".trim();

                    return Column(
                      children: [
                        Stack(
                          children: [
                            // Avatar
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                image: collab['photo_url'] != null
                                    ? DecorationImage(
                                  image: NetworkImage(collab['photo_url']),
                                  fit: BoxFit.cover,
                                )
                                    : null,
                              ),
                              child: collab['photo_url'] == null
                                  ? const Icon(Icons.person, color: Colors.white70, size: 50)
                                  : null,
                            ),
                            // Availability dot
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isAvailable ? Colors.green : Colors.red,
                                  border: Border.all(color: Colors.white, width: 3),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          fullName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          isAvailable ? "Disponible" : "Indisponible",
                          style: TextStyle(
                            color: isAvailable ? Colors.green : Colors.redAccent,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Open Add Collaborator Dialog/Screen
                        _showAddCollaboratorDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: const Text(
                        'AJOUTER',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 30),
                    OutlinedButton(
                      onPressed: () {
                        // TODO: Edit selected collaborator
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFF6B35), width: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: const Text(
                        'MODIFIER',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFF6B35)),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Bar
              Container(
                height: 80,
                color: const Color(0xFF2B2B2B),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Image.asset('assets/images/logo.png', width: 50),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6B35),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.restaurant, color: Colors.white, size: 35),
                    ),
                    const Icon(Icons.menu, color: Colors.white, size: 35),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCollaboratorDialog() {
    final nomCtrl = TextEditingController();
    final prenomCtrl = TextEditingController();
    final telCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF3A3A3A),
        title: const Text("Ajouter un collaborateur", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: prenomCtrl, decoration: const InputDecoration(labelText: "Prénom", labelStyle: TextStyle(color: Colors.white70))),
            TextField(controller: nomCtrl, decoration: const InputDecoration(labelText: "Nom", labelStyle: TextStyle(color: Colors.white70))),
            TextField(controller: telCtrl, decoration: const InputDecoration(labelText: "Téléphone", labelStyle: TextStyle(color: Colors.white70))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B35)),
            onPressed: () async {
              await supabase.from('collaborateurs').insert({
                'nom': nomCtrl.text.trim(),
                'prenom': prenomCtrl.text.trim(),
                'telephone': telCtrl.text.trim(),
                'disponible': false,
                'role': 'collaborateur',
              });
              Navigator.pop(ctx);
              fetchCollaborateurs(); // Refresh list
            },
            child: const Text("Ajouter", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}