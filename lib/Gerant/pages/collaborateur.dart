import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../Routes/app_routes.dart';

class CollaborateursPage extends StatefulWidget {
  const CollaborateursPage({super.key});

  @override
  State<CollaborateursPage> createState() => _CollaborateursPageState();
}

class _CollaborateursPageState extends State<CollaborateursPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> collaborators = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadCollaborators();
  }

  Future<void> _loadCollaborators() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await supabase
          .from('Collaborateurs')
          .select('idCollab, nom, prenom, role, disponible, email')
          .order('nom');

      setState(() {
        collaborators = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Erreur de chargement: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _showAddCollaboratorDialog() async {
    final nomController = TextEditingController();
    final prenomController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String? selectedRole = 'livreur';

    final roles = ['livreur', 'coordinateur', 'cuisinier', 'chef'];

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF424242),
        title: const Text(
          'Ajouter un collaborateur',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              TextField(
                controller: prenomController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Prénom',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                dropdownColor: const Color(0xFF424242),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Rôle',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
                items: roles.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedRole = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nomController.text.isEmpty ||
                  prenomController.text.isEmpty ||
                  emailController.text.isEmpty ||
                  passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez remplir tous les champs'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                // Generate a unique ID for the collaborator
                final idCollab = DateTime.now().millisecondsSinceEpoch.toString();

                await supabase.from('Collaborateurs').insert({
                  'idCollab': idCollab,
                  'nom': nomController.text.trim(),
                  'prenom': prenomController.text.trim(),
                  'email': emailController.text.trim(),
                  'role': selectedRole,
                  'disponible': true,
                  'password': passwordController.text.trim(), // Note: In production, hash this!
                });

                if (mounted) {
                  Navigator.pop(context);
                  _loadCollaborators();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Collaborateur ajouté avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
            ),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditCollaboratorDialog(Map<String, dynamic> collaborator) async {
    final nomController = TextEditingController(text: collaborator['nom'] ?? '');
    final prenomController = TextEditingController(text: collaborator['prenom'] ?? '');
    final emailController = TextEditingController(text: collaborator['email'] ?? '');
    String? selectedRole = collaborator['role'] ?? 'livreur';
    bool disponible = collaborator['disponible'] ?? true;

    final roles = ['livreur', 'coordinateur', 'cuisinier', 'chef'];

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
        backgroundColor: const Color(0xFF424242),
        title: const Text(
          'Modifier collaborateur',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              TextField(
                controller: prenomController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Prénom',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                dropdownColor: const Color(0xFF424242),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Rôle',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
                items: roles.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    selectedRole = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Disponible', style: TextStyle(color: Colors.white)),
                value: disponible,
                onChanged: (value) {
                  setDialogState(() {
                    disponible = value ?? true;
                  });
                },
                activeColor: const Color(0xFFFF6B35),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await supabase
                    .from('Collaborateurs')
                    .update({
                      'nom': nomController.text.trim(),
                      'prenom': prenomController.text.trim(),
                      'email': emailController.text.trim(),
                      'role': selectedRole,
                      'disponible': disponible,
                    })
                    .eq('idCollab', collaborator['idCollab']);

                if (mounted) {
                  Navigator.pop(dialogContext);
                  _loadCollaborators();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Collaborateur modifié avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
            ),
            child: const Text('Modifier'),
          ),
        ],
      ),
      ),
    );
  }

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
              Text(
                'EMPLOYÉS DISPONIBLES (${collaborators.length})',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),

              // Grid of collaborators
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
                      )
                    : error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  error!,
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadCollaborators,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF6B35),
                                  ),
                                  child: const Text('Réessayer'),
                                ),
                              ],
                            ),
                          )
                        : collaborators.isEmpty
                            ? const Center(
                                child: Text(
                                  'Aucun collaborateur trouvé',
                                  style: TextStyle(color: Colors.white70, fontSize: 18),
                                ),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 32,
                                  crossAxisSpacing: 20,
                                  childAspectRatio: 0.85,
                                ),
                                itemCount: collaborators.length,
                                itemBuilder: (context, index) {
                                  final collab = collaborators[index];
                                  final nom = collab['nom'] ?? '';
                                  final prenom = collab['prenom'] ?? '';
                                  final role = collab['role'] ?? '';
                                  final disponible = collab['disponible'] ?? false;
                                  final displayName = '$prenom $nom'.trim();
                                  final initials = (prenom.isNotEmpty
                                          ? prenom[0]
                                          : nom.isNotEmpty
                                              ? nom[0]
                                              : '?')
                                      .toUpperCase();

                                  return GestureDetector(
                                    onTap: () => _showEditCollaboratorDialog(collab),
                                    child: Column(
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              width: 70,
                                              height: 70,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: disponible
                                                      ? Colors.green
                                                      : Colors.grey,
                                                  width: 3,
                                                ),
                                                color: disponible
                                                    ? Colors.green.withOpacity(0.2)
                                                    : Colors.grey.withOpacity(0.2),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  initials,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (!disponible)
                                              Positioned(
                                                right: 0,
                                                top: 0,
                                                child: Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: const BoxDecoration(
                                                    color: Colors.red,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 12,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          displayName.isEmpty ? 'Sans nom' : displayName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          role.toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
              ),

              // Buttons at the bottom
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ajouter button
                    SizedBox(
                      width: 150,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _showAddCollaboratorDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'AJOUTER',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Modifier button
                    SizedBox(
                      width: 150,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: collaborators.isEmpty
                            ? null
                            : () {
                                if (collaborators.isNotEmpty) {
                                  _showEditCollaboratorDialog(collaborators[0]);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'MODIFIER',
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

                    // Home/Dashboard Button
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.gerantDashboard),
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6B35),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.home,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ),

                    // Refresh Button
                    IconButton(
                      onPressed: _loadCollaborators,
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 35,
                      ),
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
