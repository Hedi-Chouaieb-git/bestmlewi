// ========================================
// FILE 1: lib/screens/coordinator/coordinator_dashboard.dart
// ========================================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'manage_commands_page.dart';
//import 'view_menu_page.dart';
import 'coordinator_profile_page.dart';
import 'package:intl/intl.dart';

class CoordinatorDashboard extends StatefulWidget {
  final String coordinatorId;

  const CoordinatorDashboard({
    super.key,
    required this.coordinatorId,
  });

  @override
  State<CoordinatorDashboard> createState() => _CoordinatorDashboardState();
}

class _CoordinatorDashboardState extends State<CoordinatorDashboard> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? coordinatorData;
  int pendingCommands = 0;
  int activeCommands = 0;
  int completedToday = 0;
  List<Map<String, dynamic>> recentCommands = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    setState(() => isLoading = true);

    try {
      // Load coordinator info
      final coordData = await supabase
          .from('Collaborateurs')
          .select()
          .eq('idCollab', widget.coordinatorId)
          .single();

      // Count pending commands
      final pendingData = await supabase
          .from('Commande')
          .select('idCommande')
          .eq('statut', 'en_attente');

      // Count active commands
      final activeData = await supabase
          .from('Commande')
          .select('idCommande')
          .inFilter('statut', ['en_cours', 'en_preparation']);

      // Count completed today
      final today = DateTime.now().toIso8601String().split('T')[0];
      final completedData = await supabase
          .from('Commande')
          .select('idCommande')
          .eq('statut', 'livree')
          .gte('dateCommande', today);

      // Get recent commands
      final recentData = await supabase
          .from('Commande')
          .select('*, Client(idClient, nom, prenom, phone, adresse), Collaborateurs!Commande_idCollab_fkey(idCollab, nom, prenom, role)')
          .order('dateCommande', ascending: false)
          .limit(5);

      setState(() {
        coordinatorData = coordData;
        pendingCommands = (pendingData as List).length;
        activeCommands = (activeData as List).length;
        completedToday = (completedData as List).length;
        recentCommands = List<Map<String, dynamic>>.from(recentData);
        isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard: $e');
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2B2B),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF2B2B2B),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
          )
              : Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsCards(),
                      const SizedBox(height: 24),
                      _buildQuickActions(),
                      const SizedBox(height: 24),
                      _buildRecentCommands(),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFFFF6B35),
                child: Text(
                  coordinatorData?['prenom']?.substring(0, 1).toUpperCase() ?? 'C',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour, ${coordinatorData?['prenom'] ?? 'Coordinateur'}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Tableau de bord',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
                onPressed: loadDashboardData,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistiques',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'En attente',
                pendingCommands.toString(),
                Icons.pending_actions,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'En cours',
                activeCommands.toString(),
                Icons.local_shipping,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Livrées aujourd\'hui',
                completedToday.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Total',
                (pendingCommands + activeCommands).toString(),
                Icons.assignment,
                const Color(0xFFFF6B35),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions rapides',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            _buildActionCard(
              'Gérer Commandes',
              Icons.assignment,
              const Color(0xFFFF6B35),
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageCommandsPage(
                      coordinatorId: widget.coordinatorId,
                    ),
                  ),
                );
              },
            ),
            _buildActionCard(
              'Consulter Menu',
              Icons.restaurant_menu,
              Colors.green,
                  () {
               /* Navigator.push(
                  context,
                  MaterialPageRoute(
                    //builder: (context) => const ViewMenuPage(),
                  ),
                );*/
              },
            ),
            _buildActionCard(
              'Mon Profil',
              Icons.person,
              Colors.blue,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CoordinatorProfilePage(
                      coordinatorId: widget.coordinatorId,
                    ),
                  ),
                );
              },
            ),
            _buildActionCard(
              'Actualiser',
              Icons.refresh,
              Colors.purple,
              loadDashboardData,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.3),
              color.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCommands() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Commandes récentes',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        if (recentCommands.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'Aucune commande récente',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          )
        else
          ...recentCommands.map((command) => _buildCommandCard(command)).toList(),
      ],
    );
  }

  Widget _buildCommandCard(Map<String, dynamic> command) {
    final client = command['Client'];
    final collaborateur = command['Collaborateurs'];
    final statut = command['statut'] ?? 'inconnu';
    final date = command['dateCommande'] != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(command['dateCommande']))
        : 'Date inconnue';

    Color statusColor;
    String statusLabel;
    switch (statut) {
      case 'en_attente':
        statusColor = Colors.orange;
        statusLabel = 'En attente';
        break;
      case 'en_preparation':
        statusColor = Colors.blue;
        statusLabel = 'En préparation';
        break;
      case 'en_cours':
        statusColor = Colors.purple;
        statusLabel = 'En cours';
        break;
      case 'livree':
        statusColor = Colors.green;
        statusLabel = 'Livrée';
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = statut;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Commande #${command['idCommande']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (client != null)
            Text(
              'Client: ${client['nom']}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          if (collaborateur != null)
            Text(
              'Livreur: ${collaborateur['prenom'] ?? ''} ${collaborateur['nom'] ?? ''}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          Text(
            date,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2B),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavButton(Icons.home, 'Accueil', true, () {}),
          _buildNavButton(Icons.assignment, 'Commandes', false, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ManageCommandsPage(
                  coordinatorId: widget.coordinatorId,
                ),
              ),
            );
          }),
          _buildNavButton(Icons.restaurant_menu, 'Menu', false, () {
            /*Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ViewMenuPage(),
              ),
            );*/
          }),
          _buildNavButton(Icons.person, 'Profil', false, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CoordinatorProfilePage(
                  coordinatorId: widget.coordinatorId,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNavButton(
      IconData icon,
      String label,
      bool isActive,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFFF6B35).withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFFFF6B35) : Colors.white70,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFFFF6B35) : Colors.white70,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
