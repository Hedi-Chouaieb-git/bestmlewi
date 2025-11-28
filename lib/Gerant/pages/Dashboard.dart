import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supabase_app/Gerant/services/auth_service.dart';
import 'package:supabase_app/Gerant/services/dashboard_service.dart';
import 'package:supabase_app/Routes/app_routes.dart';

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
    _setupRealtimeSubscription();
  }

  void _setupRealtimeSubscription() {
    final supabase = Supabase.instance.client;
    supabase.from('Commande').stream(primaryKey: ['idCommande']).listen((data) {
      if (mounted) {
        _refresh();
      }
    });
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
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.signIn, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2B2B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Tableau de bord', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/group55.png'),
            opacity: 0.08,
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            color: const Color(0xFFFF6B35),
            onRefresh: _refresh,
            child: FutureBuilder<DashboardSnapshot>(
              future: _snapshotFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = snapshot.data ?? DashboardSnapshot.failure('Aucune donnée disponible');
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildDatabaseStatus(data),
                    const SizedBox(height: 20),
                    _buildStatsGrid(data),
                    const SizedBox(height: 24),
                    _buildAlertsSection(data.alerts),
                    const SizedBox(height: 24),
            _buildActions(),
            const SizedBox(height: 24),
            _buildOrderManagementActions(),
                    const SizedBox(height: 16),
                    _buildLastUpdated(data),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      // Removed bottom navigation as it contained non-functional buttons
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'TABLEAU DE BORD',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 200,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B35),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildDatabaseStatus(DashboardSnapshot snapshot) {
    final healthy = snapshot.databaseReachable;
    final color = healthy ? Colors.green : Colors.redAccent;
    final icon = healthy ? Icons.check_circle : Icons.error_outline;
    final message = healthy ? 'Connexion Supabase active' : snapshot.databaseMessage ?? 'Service indisponible';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF424242),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          if (!healthy)
            IconButton(
              onPressed: _refresh,
              icon: const Icon(Icons.support_agent, color: Colors.white70),
              tooltip: 'Réessayer',
            ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(DashboardSnapshot snapshot) {
    final stats = [
      _StatItem('Commandes du jour', snapshot.ordersToday.toString(), Icons.receipt_long),
      _StatItem('Livraisons', snapshot.deliveriesToday.toString(), Icons.delivery_dining),
      _StatItem('Points ouverts', snapshot.activeSalesPoints.toString(), Icons.storefront),
      _StatItem('CA du jour', '${snapshot.revenueToday.toStringAsFixed(2)} TND', Icons.payments),
    ];

    return GridView.builder(
      shrinkWrap: true,
      itemCount: stats.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF424242),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(stat.icon, color: const Color(0xFFFF6B35), size: 30),
              Text(
                stat.value,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                stat.label,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
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
          'Alertes',
          style: TextStyle(color: Color(0xFFFF6B35), fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (alerts.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF424242),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text('Aucune alerte active', style: TextStyle(color: Colors.white70)),
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
        ? '${alert.createdAt!.day}/${alert.createdAt!.month} '
            '${alert.createdAt!.hour.toString().padLeft(2, '0')}:${alert.createdAt!.minute.toString().padLeft(2, '0')}'
        : '—';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF424242),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withValues(alpha: 0.2),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Signalé : $dateText', style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white54),
        ],
      ),
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
                  onPressed: () => _openRoute(AppRoutes.gerantCommand),
                  style: _actionStyle(),
                  child: const Text(
                    'Affecter\ncommandes',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _openRoute(AppRoutes.gerantTeam),
                  style: _actionStyle(),
                  child: const Text(
                    'Gérer équipe',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _openRoute(AppRoutes.gerantSalesPoints),
                  style: _actionStyle(),
                  child: const Text(
                    'Points de\nvente',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _openRoute(AppRoutes.gerantRefunds),
                  style: _actionStyle(),
                  child: const Text(
                    'Remboursements',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderManagementActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gestion des Commandes',
          style: TextStyle(color: Color(0xFFFF6B35), fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () => _openRoute(AppRoutes.gerantOrderManagement),
            icon: const Icon(Icons.assignment),
            label: const Text(
              'Gérer les Commandes',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  ButtonStyle _actionStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFF6B35),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildLastUpdated(DashboardSnapshot snapshot) {
    final formatted =
        '${snapshot.fetchedAt.hour.toString().padLeft(2, '0')}:${snapshot.fetchedAt.minute.toString().padLeft(2, '0')}';
    return Text(
      'Dernière actualisation : $formatted',
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white54, fontSize: 12),
    );
  }



  Color _severityColor(DashboardAlertSeverity severity) {
    switch (severity) {
      case DashboardAlertSeverity.warning:
        return Colors.orange;
      case DashboardAlertSeverity.error:
        return Colors.redAccent;
      case DashboardAlertSeverity.info:
        return Colors.lightBlueAccent;
    }
    return Colors.lightBlueAccent;
  }

  IconData _severityIcon(DashboardAlertSeverity severity) {
    switch (severity) {
      case DashboardAlertSeverity.warning:
        return Icons.warning_amber;
      case DashboardAlertSeverity.error:
        return Icons.error;
      case DashboardAlertSeverity.info:
        return Icons.info_outline;
    }
    return Icons.info_outline;
  }
}

class _StatItem {
  const _StatItem(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}
