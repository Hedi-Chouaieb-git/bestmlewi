import 'package:flutter/material.dart';
import '../../Routes/app_routes.dart';
import '../services/role_service.dart';
import '../services/sales_point_service.dart';
import '../../models/collaborator.dart';

class EquipeCuisinePage extends StatefulWidget {
  const EquipeCuisinePage({Key? key}) : super(key: key);

  @override
  _EquipeCuisinePageState createState() => _EquipeCuisinePageState();
}

class _EquipeCuisinePageState extends State<EquipeCuisinePage> {
  final RoleService _roleService = RoleService();
  final SalesPointService _salesPointService = SalesPointService();

  bool _isLoading = true;
  String? _error;
  List<Collaborator> _kitchenMembers = [];
  List<Map<String, dynamic>> _salesPoints = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final collaborators = await _roleService.fetchCollaborators();
      final salesPoints = await _salesPointService.getSalesPoints();

      setState(() {
        _kitchenMembers = collaborators.where((c) => c.role.toLowerCase() == 'cuisinier').toList();
        _salesPoints = salesPoints;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showReassignDialog(Collaborator member) {
    String? selectedPointId = member.idPointAffecte;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF424242),
          title: Text(
            'Réaffecter ${member.fullName}',
            style: const TextStyle(color: Colors.white),
          ),
          content: _salesPoints.isEmpty
              ? const Text(
                  'Aucun point de vente disponible',
                  style: TextStyle(color: Colors.white70),
                )
              : DropdownButton<String>(
                  isExpanded: true,
                  value: selectedPointId,
                  hint: const Text(
                    'Sélectionner un point de vente',
                    style: TextStyle(color: Colors.white70),
                  ),
                  dropdownColor: const Color(0xFF424242),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text(
                        'Aucun point de vente',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ..._salesPoints.map((point) => DropdownMenuItem(
                          value: point['idPoint'] as String,
                          child: Text(
                            point['nom'] as String,
                            style: const TextStyle(color: Colors.white),
                          ),
                        )),
                  ],
                  onChanged: (val) {
                    selectedPointId = val;
                    (context as Element).markNeedsBuild();
                  },
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _roleService.assignRole(
                    collaboratorId: member.idCollab,
                    role: 'Cuisinier',
                    salesPointId: selectedPointId,
                  );

                  Navigator.of(context).pop();
                  _loadData(); // Refresh the list
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cuisinier réaffecté avec succès'),
                      backgroundColor: Color(0xFFFF6B35),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
              ),
              child: const Text('Réaffecter'),
            ),
          ],
        );
      },
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
                'ÉQUIPE CUISINE',
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
              const SizedBox(height: 32),

              // Stacked member cards
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B35)))
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Erreur: $_error', style: const TextStyle(color: Colors.red)),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadData,
                                  child: const Text('Réessayer'),
                                ),
                              ],
                            ),
                          )
                        : _kitchenMembers.isEmpty
                            ? const Center(
                                child: Text(
                                  'Aucun cuisinier trouvé',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 36),
                                itemCount: _kitchenMembers.length,
                                itemBuilder: (context, index) {
                                  final member = _kitchenMembers[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 24),
                                    child: Stack(
                                      alignment: Alignment.topCenter,
                                      children: [
                                        // Card details
                                        Container(
                                          margin: const EdgeInsets.only(top: 48),
                                          padding: const EdgeInsets.fromLTRB(20, 55, 20, 24),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF424242),
                                            borderRadius: BorderRadius.circular(28),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 8),
                                              Text(
                                                '• Statut: ${member.disponible ? 'Disponible' : 'Occupé'}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '• Téléphone: ${member.telephone ?? 'N/A'}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 24),
                                              // Button
                                              SizedBox(
                                                width: double.infinity,
                                                height: 54,
                                                child: ElevatedButton(
                                                  onPressed: () => _showReassignDialog(member),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFFFF6B35),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(18),
                                                    ),
                                                    elevation: 0,
                                                  ),
                                                  child: const Text(
                                                    'RÉAFFECTER',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      letterSpacing: 1,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Circular user icon above card center
                                        Positioned(
                                          top: 0,
                                          child: Column(
                                            children: [
                                              Container(
                                                width: 98,
                                                height: 98,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFFF6B35),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.person_outline,
                                                      size: 40,
                                                      color: Colors.white,
                                                    ),
                                                    const SizedBox(height: 2),
                                                    FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Text(
                                                        member.fullName,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.w400,
                                                          fontFamily: 'Montserrat',
                                                        ),
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
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
                    // Logo - Navigate to Dashboard
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.gerantDashboard);
                      },
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                    ),
                    // Home/Menu Button - Navigate to Dashboard
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.gerantDashboard);
                      },
                      child: Container(
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
                    ),
                    // Profile Button - Navigate to Collaborateurs
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.gerantTeam);
                      },
                      child: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                    // Menu Button - Navigate to Collaborateurs
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.gerantTeam);
                      },
                      child: const Icon(
                        Icons.menu,
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
