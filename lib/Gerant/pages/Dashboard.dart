import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int commandes = 0;
  int livraisons = 0;
  int ptsOuverts = 0;
  double chiffreAffaires = 0.0;
  List<String> alertes = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }


  Future<void> fetchDashboardData() async {
    try {
      final client = Supabase.instance.client;

      // Fetch orders count
      final commandesCount = await client
          .from('Commande')
          .select('id')
          .count(CountOption.exact);

      // Fetch collaborators count (or you can use Livraisons if that table exists)
      final collaborateursCount = await client
          .from('Collaborateur')
          .select('id')
          .count(CountOption.exact);

      // Fetch open sales points
      final pointsCount = await client
          .from('TopMlawi')
          .select('id')
          .count(CountOption.exact);

      // For revenue, you can sum from Commande table if it has a montant/price column
      final revenueRes = await client
          .from('Commande')
          .select('*');

      double totalCA = 0;
      for (var item in revenueRes) {
        // Adjust column name if different
        totalCA += (item['montant'] as num?)?.toDouble() ?? 0;
      }

      setState(() {
        commandes = commandesCount.count ?? 0;
        livraisons = collaborateursCount.count ?? 0; // or another count
        ptsOuverts = pointsCount.count ?? 0;
        chiffreAffaires = totalCA;
        alertes = ['TopMlawi Centre : Stock bas', 'Livreur Sami : Retard', 'Commande #178 : En attente']; // Add real alerts if you create an Alertes table
        loading = false;
      });
    } catch (err) {
      print('Error fetching dashboard data: $err');
      setState(() {
        error = err.toString();
        loading = false;
      });
    }
  }



  void _refreshDashboard() {
    setState(() {
      loading = true;
    });
    fetchDashboardData();
  }

<<<<<<< HEAD
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/dashboard_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _dashboardService = DashboardService();
  final _authService = AuthService();
  late Future<DashboardSnapshot> _snapshotFuture;

  @override
  void initState() {
    super.initState();
    _snapshotFuture = _dashboardService.fetchSnapshot();
  }

  Future<void> _refresh() async {
    final future = _dashboardService.fetchSnapshot();
    setState(() {
      _snapshotFuture = future;
    });
    await future;
  }

  void _openRoute(String route) {
    Navigator.pushNamed(context, route);
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.signIn,
      (route) => false,
    );
  }

=======
>>>>>>> f2af5065b3643937146ae58626ec0547639525ad
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2B2B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Tableau de bord',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: _refresh,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: _logout,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2B2B2B),
          image: DecorationImage(
            image: AssetImage('assets/images/group55.png'),
            fit: BoxFit.cover,
            opacity: 0.08,
          ),
        ),
        child: SafeArea(
<<<<<<< HEAD
          child: RefreshIndicator(
            color: const Color(0xFFFF6B35),
            onRefresh: _refresh,
            child: FutureBuilder<DashboardSnapshot>(
              future: _snapshotFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data ??
                    DashboardSnapshot.failure('Aucune donnée disponible');

                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildDatabaseStatus(data),
                    const SizedBox(height: 24),
                    _buildStatsGrid(data),
                    const SizedBox(height: 28),
                    _buildAlertsSection(data.alerts),
                    const SizedBox(height: 28),
                    _buildActions(),
                    const SizedBox(height: 18),
                    _buildLastUpdated(data),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'TABLEAU DE BORD',
          style: TextStyle(
            fontSize: 32,
=======
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : (error != null
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Erreur: $error',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshDashboard,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          )
              : _buildDashboard()),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        // Page Title
        const Text(
          'TABLEAU DE BORD',
          style: TextStyle(
            fontSize: 34,
>>>>>>> f2af5065b3643937146ae58626ec0547639525ad
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
<<<<<<< HEAD
        const SizedBox(height: 12),
        Container(
          width: 220,
=======
        const SizedBox(height: 14),
        Container(
          width: 240,
>>>>>>> f2af5065b3643937146ae58626ec0547639525ad
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B35),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
<<<<<<< HEAD
      ],
    );
  }

  Widget _buildDatabaseStatus(DashboardSnapshot snapshot) {
    final statusColor = snapshot.databaseReachable ? Colors.green : Colors.redAccent;
    final icon = snapshot.databaseReachable ? Icons.check_circle : Icons.error_outline;
    final message = snapshot.databaseReachable
        ? 'Connexion Supabase active'
        : (snapshot.databaseMessage ?? 'Impossible d’accéder à la base');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF424242),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: statusColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: statusColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (!snapshot.databaseReachable)
            IconButton(
              icon: const Icon(Icons.support_agent, color: Colors.white),
              onPressed: _refresh,
              tooltip: 'Re-vérifier',
            ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(DashboardSnapshot snapshot) {
    final stats = [
      _StatItem(
        label: 'Commandes du jour',
        value: snapshot.ordersToday.toString(),
        icon: Icons.receipt_long,
      ),
      _StatItem(
        label: 'Livraisons',
        value: snapshot.deliveriesToday.toString(),
        icon: Icons.delivery_dining,
      ),
      _StatItem(
        label: 'Points ouverts',
        value: snapshot.activeSalesPoints.toString(),
        icon: Icons.store_mall_directory,
      ),
      _StatItem(
        label: 'CA journalier',
        value: '${snapshot.revenueToday.toStringAsFixed(2)} TND',
        icon: Icons.attach_money,
      ),
    ];

    return GridView.builder(
      itemCount: stats.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF424242),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(stat.icon, color: const Color(0xFFFF6B35), size: 32),
              Text(
                stat.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                stat.label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  letterSpacing: 0.6,
=======
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
                  children: [
                    Text('• $commandes commandes',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('• $livraisons livraisons',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              // Right column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• $ptsOuverts pts ouverts',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('• ${chiffreAffaires.toStringAsFixed(0)} TND CA',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ],
>>>>>>> f2af5065b3643937146ae58626ec0547639525ad
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlertsSection(List<DashboardAlert> alerts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ALERTES',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF6B35),
          ),
        ),
<<<<<<< HEAD
        const SizedBox(height: 14),
        if (alerts.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF424242),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Aucune alerte active.',
              style: TextStyle(color: Colors.white70),
            ),
          )
        else
          ...alerts.map(_buildAlertTile),
      ],
    );
  }

  Widget _buildAlertTile(DashboardAlert alert) {
    final color = _severityColor(alert.severity);
    final icon = _severityIcon(alert.severity);
    final dateText = alert.createdAt != null
        ? '${alert.createdAt!.day}/${alert.createdAt!.month} ${alert.createdAt!.hour.toString().padLeft(2, '0')}:${alert.createdAt!.minute.toString().padLeft(2, '0')}'
        : '—';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF424242),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Signalé : $dateText',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.7)),
        ],
      ),
=======

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
            children: alertes.isEmpty
                ? const [
              Text('Aucune alerte',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold))
            ]
                : alertes
                .map((msg) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('• $msg',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ))
                .toList(),
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
                    onPressed: () {
                      // Navigate to assign orders
                      // Navigator.pushNamed(context, '/assign-orders');
                    },
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
                    onPressed: () {
                      // Navigate to manage team
                      // Navigator.pushNamed(context, '/manage-team');
                    },
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
            onPressed: () {
              // Navigate to sales points
              // Navigator.pushNamed(context, '/sales-points');
            },
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
>>>>>>> f2af5065b3643937146ae58626ec0547639525ad
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _openRoute(AppRoutes.commande),
                  style: _actionButtonStyle(),
                  child: const Text(
                    'AFFECTER\nCOMMANDES',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _openRoute(AppRoutes.collab),
                  style: _actionButtonStyle(),
                  child: const Text(
                    'GÉRER ÉQUIPE',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => _openRoute(AppRoutes.salespoint),
            style: _actionButtonStyle(),
            child: const Text(
              'POINTS DE VENTE',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  ButtonStyle _actionButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFF6B35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      elevation: 0,
    );
  }

  Widget _buildLastUpdated(DashboardSnapshot snapshot) {
    final formatted =
        '${snapshot.fetchedAt.hour.toString().padLeft(2, '0')}:${snapshot.fetchedAt.minute.toString().padLeft(2, '0')}';
    return Text(
      'Dernière actualisation : $formatted',
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 12,
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFF2B2B2B),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 50,
            height: 50,
            fit: BoxFit.contain,
          ),
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
          const Icon(
            Icons.person_outline,
            color: Colors.white,
            size: 35,
          ),
          const Icon(
            Icons.menu,
            color: Colors.white,
            size: 35,
          ),
        ],
      ),
    );
  }

  Color _severityColor(DashboardAlertSeverity severity) {
    switch (severity) {
      case DashboardAlertSeverity.warning:
        return Colors.orange;
      case DashboardAlertSeverity.error:
        return Colors.redAccent;
      case DashboardAlertSeverity.info:
      default:
        return Colors.lightBlueAccent;
    }
  }

  IconData _severityIcon(DashboardAlertSeverity severity) {
    switch (severity) {
      case DashboardAlertSeverity.warning:
        return Icons.warning_amber;
      case DashboardAlertSeverity.error:
        return Icons.error;
      case DashboardAlertSeverity.info:
      default:
        return Icons.info_outline;
    }
  }
}

class _StatItem {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

extension on SupabaseQueryBuilder {
  eq(String s, String t) {}
}
