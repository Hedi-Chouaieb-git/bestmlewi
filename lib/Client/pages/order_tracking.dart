import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../services/order_service.dart';
import '../../models/order.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({super.key});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  final OrderService _orderService = OrderService();
  final supabase = Supabase.instance.client;
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    // Set up periodic refresh for real-time feel
    // In a real app, you'd use proper real-time streams
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      // In a real app, you'd get the current client ID from authentication
      // For now, we'll load all orders (this would be client orders in production)
      final orders = await _orderService.fetchAllOrders();

      setState(() {
        _orders = orders;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _cancelOrder(String orderId, String status) async {
    if (status != 'en_attente') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'annuler une commande déjà en préparation'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF3A3A3A),
        title: const Text('Annuler la commande', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Êtes-vous sûr de vouloir annuler cette commande ?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _orderService.cancelOrder(orderId);
        await _loadOrders();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Commande annulée'),
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
  }

  Future<void> _requestRefund(String orderId, String clientId) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF3A3A3A),
        title: const Text('Demander un remboursement', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Motif du remboursement :',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Expliquez la raison...',
                hintStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFF6B35)),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Color(0xFFFF6B35)),
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );

    if (confirmed == true && reasonController.text.isNotEmpty) {
      try {
        final refundId = DateTime.now().millisecondsSinceEpoch.toString();

        await supabase.from('RefundRequests').insert({
          'idRefund': refundId,
          'idCommande': orderId,
          'idClient': clientId,
          'motif': reasonController.text,
          'statut': 'en_attente',
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Demande de remboursement envoyée'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2B2B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Suivi des commandes',
          style: TextStyle(fontWeight: FontWeight.bold),
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B35)))
            : _orders.isEmpty
                ? const Center(
                    child: Text(
                      'Aucune commande trouvée',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  )
                : RefreshIndicator(
                    color: const Color(0xFFFF6B35),
                    onRefresh: _loadOrders,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _orders.length,
                      itemBuilder: (context, index) => _buildOrderCard(_orders[index]),
                    ),
                  ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final status = order.statut;
    final date = DateFormat('dd/MM/yyyy HH:mm').format(order.dateCommande);

    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (status) {
      case 'en_attente':
        statusColor = Colors.orange;
        statusLabel = 'En attente';
        statusIcon = Icons.pending;
        break;
      case 'en_preparation':
        statusColor = Colors.blue;
        statusLabel = 'En préparation';
        statusIcon = Icons.restaurant;
        break;
      case 'en_cours':
        statusColor = Colors.purple;
        statusLabel = 'En livraison';
        statusIcon = Icons.delivery_dining;
        break;
      case 'livree':
        statusColor = Colors.green;
        statusLabel = 'Livrée';
        statusIcon = Icons.check_circle;
        break;
      case 'annulee':
        statusColor = Colors.red;
        statusLabel = 'Annulée';
        statusIcon = Icons.cancel;
        break;
      case 'rejete':
        statusColor = Colors.red;
        statusLabel = 'Rejetée';
        statusIcon = Icons.block;
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = status;
        statusIcon = Icons.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF424242),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: statusColor.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Commande #${order.idCommande}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      statusLabel,
                      style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Date: $date',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'Montant: ${order.montantTotal.toStringAsFixed(2)} DT',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (status == 'en_attente')
                TextButton.icon(
                  onPressed: () => _cancelOrder(order.idCommande, status),
                  icon: const Icon(Icons.cancel, size: 16),
                  label: const Text('Annuler'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              if (status == 'livree')
                TextButton.icon(
                  onPressed: () => _requestRefund(order.idCommande, order.idClient),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Remboursement'),
                  style: TextButton.styleFrom(foregroundColor: Color(0xFFFF6B35)),
                ),
              if (status == 'rejete')
                TextButton.icon(
                  onPressed: () => _requestRefund(order.idCommande, order.idClient),
                  icon: const Icon(Icons.block, size: 16),
                  label: const Text('Demander remboursement'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
