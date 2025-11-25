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
    );
  }
}

extension on SupabaseQueryBuilder {
  eq(String s, String t) {}
}
