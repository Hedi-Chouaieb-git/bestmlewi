import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supabase_app/Routes/app_routes.dart';
import 'widgets/nav_bar.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  final supabase = Supabase.instance.client;

  bool _isLoading = false;
  String _customerName = 'TopMlawi Lover';
  String _favoriteCategory = 'Mlawi';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase.from('Client').select('name,favorite').limit(1);
      final rows = List<Map<String, dynamic>>.from(response);
      if (rows.isNotEmpty) {
        final data = rows.first;
        setState(() {
          _customerName = (data['name'] as String?)?.trim().isNotEmpty == true
              ? data['name'] as String
              : _customerName;
          _favoriteCategory = (data['favorite'] as String?)?.trim().isNotEmpty == true
              ? data['favorite'] as String
              : _favoriteCategory;
        });
      }
    } catch (_) {
      // Silent fallback to demo data when the table does not exist yet.
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF2B2B2B),
          image: DecorationImage(
            image: AssetImage('assets/images/group55.png'),
            fit: BoxFit.cover,
            opacity: 0.08,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildActiveOrderCard(),
              const SizedBox(height: 16),
              _buildQuickActions(),
              const SizedBox(height: 16),
              _buildRecommendationsTitle(),
              Expanded(child: _buildRecommendationsList()),
              const NavBar(currentPage: AppRoutes.clientHome),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFFF6B35),
            child: Text(
              _customerName.substring(0, 1).toUpperCase(),
              style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isLoading ? 'Chargement...' : 'Bonjour, $_customerName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Envie de $_favoriteCategory aujourd’hui ?',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loadProfile,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOrderCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF424242),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFF6B35).withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFFF6B35),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delivery_dining, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Commande en cours',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Livreur Youssef arrive dans 12 min',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.clientCart),
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          _QuickActionButton(
            icon: Icons.restaurant_menu,
            label: 'Commander',
            onTap: () => Navigator.pushNamed(context, AppRoutes.clientMenu),
          ),
          const SizedBox(width: 12),
          _QuickActionButton(
            icon: Icons.shopping_cart_checkout,
            label: 'Panier',
            onTap: () => Navigator.pushNamed(context, AppRoutes.clientCart),
          ),
          const SizedBox(width: 12),
          _QuickActionButton(
            icon: Icons.delivery_dining,
            label: 'Suivi',
            onTap: () => Navigator.pushNamed(context, AppRoutes.livreurHome),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            'Recommandé pour vous',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
        ],
      ),
    );
  }

  Widget _buildRecommendationsList() {
    final items = [
      _RecommendationItem('Shawarma Wrap', 'assets/images/shwarma.jpeg', 24.0),
      _RecommendationItem('Mlawi Royal', 'assets/images/mlawi.jpeg', 19.0),
      _RecommendationItem('Jus d’orange', 'assets/images/jus.jpeg', 8.0),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF3A3A3A),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  item.image,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Préparé en 10 min',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              ),
              Text(
                '${item.price.toStringAsFixed(1)} DT',
                style: const TextStyle(
                  color: Color(0xFFFF6B35),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF424242),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 30),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendationItem {
  _RecommendationItem(this.title, this.image, this.price);

  final String title;
  final String image;
  final double price;
}
