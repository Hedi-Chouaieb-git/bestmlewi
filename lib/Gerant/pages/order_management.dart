import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../../models/collaborator.dart';
import '../../Routes/app_routes.dart';

class GerantOrderManagementPage extends StatefulWidget {
  const GerantOrderManagementPage({super.key});

  @override
  State<GerantOrderManagementPage> createState() => _GerantOrderManagementPageState();
}

class _GerantOrderManagementPageState extends State<GerantOrderManagementPage> {
  final supabase = Supabase.instance.client;
  List<Order> _orders = [];
  bool _isLoading = true;
  String _selectedFilter = 'tous';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase
          .from('Commande')
          .select('*, Client(idClient, nom, prenom, phone, adresse)')
          .order('dateCommande', ascending: false);

      final orders = List<Map<String, dynamic>>.from(response)
          .map((json) => Order.fromJson(json))
          .toList();

      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await supabase
          .from('Commande')
          .update({'statut': newStatus})
          .eq('idCommande', orderId);

      await _loadOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Statut mis à jour: $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<Order> get _filteredOrders {
    if (_selectedFilter == 'tous') return _orders;
    return _orders.where((order) => order.statut == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2B2B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Gestion des Commandes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: _loadOrders,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/group55.png'),
            fit: BoxFit.cover,
            opacity: 0.05,
          ),
        ),
        child: Column(
          children: [
            _buildFilterChips(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
                    )
                  : _filteredOrders.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucune commande',
                            style: TextStyle(color: Colors.white70, fontSize: 18),
                          ),
                        )
                      : RefreshIndicator(
                          color: const Color(0xFFFF6B35),
                          onRefresh: _loadOrders,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredOrders.length,
                            itemBuilder: (context, index) {
                              return _buildOrderCard(_filteredOrders[index]);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'label': 'Tous', 'value': 'tous'},
      {'label': 'En attente', 'value': 'en_attente'},
      {'label': 'Approuvée', 'value': 'approuvee'},
      {'label': 'En préparation', 'value': 'en_preparation'},
      {'label': 'En cours', 'value': 'en_cours'},
      {'label': 'Livrée', 'value': 'livree'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['value'];

          return FilterChip(
            label: Text(
              filter['label'] as String,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() => _selectedFilter = filter['value'] as String);
              }
            },
            backgroundColor: Colors.white.withOpacity(0.1),
            selectedColor: const Color(0xFFFF6B35).withOpacity(0.3),
            checkmarkColor: Colors.white,
            side: BorderSide(
              color: const Color(0xFFFF6B35).withOpacity(isSelected ? 0.8 : 0.3),
              width: 1,
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final date = DateFormat('dd/MM/yyyy HH:mm').format(order.dateCommande);

    Color statusColor;
    String statusLabel;
    switch (order.statut) {
      case 'en_attente':
        statusColor = Colors.orange;
        statusLabel = 'En attente';
        break;
      case 'approuvee':
        statusColor = Colors.blue;
        statusLabel = 'Approuvée';
        break;
      case 'en_preparation':
        statusColor = Colors.purple;
        statusLabel = 'En préparation';
        break;
      case 'en_cours':
        statusColor = Colors.indigo;
        statusLabel = 'En livraison';
        break;
      case 'livree':
        statusColor = Colors.green;
        statusLabel = 'Livrée';
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = order.statut;
    }

    return Card(
      color: Colors.white.withOpacity(0.08),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Commande #${order.idCommande}',
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
            Text(
              date,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              'Montant: ${order.montantTotal.toStringAsFixed(2)} TND',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            if (order.statut == 'en_attente')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateOrderStatus(order.idCommande, 'approuvee'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('Approuver'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showRejectDialog(order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('Rejeter'),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  if (order.statut == 'approuvee')
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _updateOrderStatus(order.idCommande, 'en_preparation'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFF6B35)),
                        ),
                        child: const Text(
                          'Transférer au coordinateur',
                          style: TextStyle(color: Color(0xFFFF6B35)),
                        ),
                      ),
                    ),
                  if (['en_preparation', 'en_cours', 'livree'].contains(order.statut))
                    Expanded(
                      child: TextButton(
                        onPressed: () => _showOrderDetails(order),
                        child: const Text(
                          'Voir détails',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF3A3A3A),
        title: const Text(
          'Rejeter la commande',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir rejeter cette commande ?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateOrderStatus(order.idCommande, 'rejete');
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Rejeter'),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF3A3A3A),
        title: Text(
          'Détails de la commande #${order.idCommande}',
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Client: ${order.idClient}', style: const TextStyle(color: Colors.white70)),
              Text('Statut: ${order.statut}', style: const TextStyle(color: Colors.white70)),
              Text('Montant: ${order.montantTotal.toStringAsFixed(2)} TND', style: const TextStyle(color: Colors.white70)),
              Text('Adresse: ${order.adresseLivraison}', style: const TextStyle(color: Colors.white70)),
              if (order.notes != null && order.notes!.isNotEmpty)
                Text('Notes: ${order.notes}', style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFF2B2B2B),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavButton(Icons.home, 'Accueil', false, () {
            Navigator.pushReplacementNamed(context, AppRoutes.gerantDashboard);
          }),
          _buildNavButton(Icons.assignment, 'Commandes', true, () {}),
          _buildNavButton(Icons.group, 'Équipe', false, () {
            Navigator.pushReplacementNamed(context, AppRoutes.gerantTeam);
          }),
          _buildNavButton(Icons.settings, 'Paramètres', false, () {
            // TODO: Add settings page
          }),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFF6B35).withOpacity(0.2) : Colors.transparent,
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
