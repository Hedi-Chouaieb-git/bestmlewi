import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/notification_service.dart';
import '../../services/auth_service.dart';
import 'delivery_details_page.dart';

class LivreurHomePage extends StatefulWidget {
  const LivreurHomePage({super.key});

  @override
  State<LivreurHomePage> createState() => _LivreurHomePageState();
}

class _LivreurHomePageState extends State<LivreurHomePage> {
  final supabase = Supabase.instance.client;

  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _deliveries = const [];

  @override
  void initState() {
    super.initState();
    _loadDeliveries();
  }

  Future<void> _loadDeliveries() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await supabase
          .from('Commande')
          .select('*, Client(idClient, nom, prenom, phone, adresse)')
          .order('dateCommande', ascending: false)
          .limit(12);

      setState(() {
        _deliveries = List<Map<String, dynamic>>.from(response);
      });
    } on PostgrestException catch (error) {
      setState(() => _error = error.message);
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateStatus(String id, String newStatus) async {
    try {
      final now = DateTime.now().toIso8601String();
      final updates = {'statut': newStatus};

      // Add timestamp based on status
      switch (newStatus) {
        case 'en_cours':
          updates['tempsRecuperationLivreur'] = now;
          break;
        case 'livree':
          updates['tempsLivraison'] = now;
          break;
      }

      // Get order details first to notify client
      final orderDetails = await supabase
          .from('Commande')
          .select('idClient, statut')
          .eq('idCommande', id)
          .single();

      await supabase.from('Commande').update(updates).eq('idCommande', id);

      // Create notification for coordinator/manager
      await _createNotification(id, 'statut_modifie', 'Statut de livraison mis à jour');

      // Create notification for client
      String clientNotificationTitle = '';
      String clientNotificationMessage = '';

      switch (newStatus) {
        case 'en_cours':
          clientNotificationTitle = 'Commande en livraison';
          clientNotificationMessage = 'Votre commande #$id est en cours de livraison.';
          break;
        case 'livree':
          clientNotificationTitle = 'Commande livrée';
          clientNotificationMessage = 'Votre commande #$id a été livrée avec succès !';
          break;
      }

      if (clientNotificationTitle.isNotEmpty) {
        final notificationService = NotificationService();
        await notificationService.showClientNotification(
          orderId: id,
          title: clientNotificationTitle,
          message: clientNotificationMessage,
        );
      }

      await _loadDeliveries();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Statut mis à jour: ${_statusLabel(newStatus)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible de mettre à jour: $error'), backgroundColor: Colors.red),
        );
      }
    }
  }



  Future<void> _createNotification(String orderId, String type, String message) async {
    try {
      final notificationService = NotificationService();
      await notificationService.createNotification(
        recipientId: 'COORD001', // This should be dynamic based on coordinator
        orderId: orderId,
        type: type,
        title: message,
        message: 'Commande $orderId: $message',
      );
    } catch (e) {
      print('Error creating notification: $e');
    }
  }

  Future<void> _updateLocation() async {
    // In a real app, you'd get location from GPS
    // For now, we'll simulate location updates
    try {
      final locationId = DateTime.now().millisecondsSinceEpoch.toString();
      await supabase.from('Locations').insert({
        'idLocation': locationId,
        'idCollab': 'COLL002', // This should be the current delivery person ID
        'latitude': 36.8065,
        'longitude': 10.1815,
        'vitesse': 25.5,
        'precision': 5.2,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Position mise à jour'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de localisation: $e'), backgroundColor: Colors.red),
        );
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
          'Espace Livreur',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _loadDeliveries,
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
            _buildStatsRow(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: _ErrorBanner(message: _error!),
              ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B35)))
                  : RefreshIndicator(
                color: const Color(0xFFFF6B35),
                onRefresh: _loadDeliveries,
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _deliveries.length,
                  itemBuilder: (context, index) => _buildDeliveryCard(_deliveries[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final pending = _deliveries.where((d) => d['statut'] == 'en_attente').length;
    final inProgress = _deliveries.where((d) => d['statut'] == 'en_cours').length;
    final delivered = _deliveries.where((d) => d['statut'] == 'livree').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _StatChip(label: 'À récupérer', value: pending, color: Colors.orange),
          const SizedBox(width: 12),
          _StatChip(label: 'En route', value: inProgress, color: Colors.blue),
          const SizedBox(width: 12),
          _StatChip(label: 'Livrées', value: delivered, color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(Map<String, dynamic> delivery) {
    final client = delivery['Client'] as Map<String, dynamic>?;
    final status = delivery['statut'] as String? ?? 'inconnu';
    final date = delivery['dateCommande'] as String?;
    final formattedDate = date != null
        ? DateFormat('dd MMM - HH:mm').format(DateTime.tryParse(date) ?? DateTime.now())
        : 'Date inconnue';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DeliveryDetailsPage(
              deliveryId: delivery['idCommande'].toString(),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF424242),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _statusColor(status).withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cmd #${delivery['idCommande']}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(status),
                    style: TextStyle(color: _statusColor(status), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              client != null ? '${client['nom'] ?? ''} • ${client['adresse'] ?? ''}' : 'Client inconnu',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              formattedDate,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: _statusColor(status)),
                    ),
                    onPressed: status == 'livree'
                        ? null
                        : () => _updateStatus(
                      delivery['idCommande'].toString(),
                      status == 'en_cours' ? 'livree' : 'en_cours',
                    ),
                    icon: Icon(status == 'en_cours' ? Icons.check : Icons.play_arrow),
                    label: Text(status == 'en_cours' ? 'Marquer livrée' : 'Commencer'),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => _updateStatus(delivery['idCommande'].toString(), 'en_attente'),
                  icon: const Icon(Icons.refresh, color: Colors.white54),
                  tooltip: 'Replanifier',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'en_cours':
        return Colors.blue;
      case 'livree':
        return Colors.green;
      case 'en_attente':
        return Colors.orange;
      default:
        return Colors.white70;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'en_cours':
        return 'En cours';
      case 'livree':
        return 'Livrée';
      case 'en_attente':
        return 'En attente';
      default:
        return status;
    }
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF424242),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
