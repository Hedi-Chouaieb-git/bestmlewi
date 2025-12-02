import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../../services/notification_service.dart';
import '../../Routes/app_routes.dart';

class DeliveryDetailsPage extends StatefulWidget {
  final String deliveryId;

  const DeliveryDetailsPage({
    super.key,
    required this.deliveryId,
  });

  @override
  State<DeliveryDetailsPage> createState() => _DeliveryDetailsPageState();
}

class _DeliveryDetailsPageState extends State<DeliveryDetailsPage> {
  final supabase = Supabase.instance.client;
  Order? _order;
  bool _isLoading = true;
  bool _isUpdatingStatus = false;

  @override
  void initState() {
    super.initState();
    _loadDeliveryDetails();
  }

  Future<void> _loadDeliveryDetails() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase
          .from('Commande')
          .select('*')
          .eq('idCommande', widget.deliveryId)
          .single();

      // Get client data separately
      if (response['idClient'] != null) {
        try {
          final clientData = await supabase
              .from('Client')
              .select('idClient, nom, prenom, phone, adresse')
              .eq('idClient', response['idClient'])
              .single();
          response['Client'] = clientData;
        } catch (e) {
          response['Client'] = null;
        }
      }

      final order = Order.fromJson(response);
      setState(() {
        _order = order;
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

  Future<void> _updateDeliveryStatus(String newStatus) async {
    if (_order == null) return;

    setState(() => _isUpdatingStatus = true);
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

      await supabase
          .from('Commande')
          .update(updates)
          .eq('idCommande', _order!.idCommande);

      // Create notification for coordinator
      await _createNotification('COORD001', _order!.idCommande, 'statut_modifie', 'Statut de livraison mis à jour');

      // Create notification for client
      String clientNotificationTitle = '';
      String clientNotificationMessage = '';

      switch (newStatus) {
        case 'en_cours':
          clientNotificationTitle = 'Commande en livraison';
          clientNotificationMessage = 'Votre commande #${_order!.idCommande} est en cours de livraison.';
          break;
        case 'livree':
          clientNotificationTitle = 'Commande livrée';
          clientNotificationMessage = 'Votre commande #${_order!.idCommande} a été livrée avec succès !';
          break;
      }

      if (clientNotificationTitle.isNotEmpty) {
        final notificationService = NotificationService();
        await notificationService.showClientNotification(
          orderId: _order!.idCommande,
          title: clientNotificationTitle,
          message: clientNotificationMessage,
        );
      }

      await _loadDeliveryDetails();

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
    } finally {
      if (mounted) {
        setState(() => _isUpdatingStatus = false);
      }
    }
  }

  Future<void> _createNotification(String recipientId, String orderId, String type, String message) async {
    try {
      final notificationService = NotificationService();
      await notificationService.createNotification(
        recipientId: recipientId,
        orderId: orderId,
        type: type,
        title: message,
        message: 'Commande $orderId: $message',
      );
    } catch (e) {
      print('Error creating notification: $e');
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
          'Détails de la Livraison',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: _loadDeliveryDetails,
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
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
              )
            : _order == null
                ? const Center(
                    child: Text(
                      'Livraison non trouvée',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOrderHeader(),
                        const SizedBox(height: 24),
                        _buildClientInfo(),
                        const SizedBox(height: 24),
                        _buildDeliveryInfo(),
                        const SizedBox(height: 24),
                        _buildStatusTimeline(),
                        const SizedBox(height: 24),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    final date = DateFormat('dd/MM/yyyy HH:mm').format(_order!.dateCommande);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Commande #${_order!.idCommande}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildStatusBadge(_order!.statut),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Commandée le $date',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'Montant: ${_order!.montantTotal.toStringAsFixed(2)} TND',
            style: const TextStyle(
              color: Color(0xFFFF6B35),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'en_attente':
        color = Colors.orange;
        label = 'En attente';
        break;
      case 'en_preparation':
        color = Colors.blue;
        label = 'En préparation';
        break;
      case 'en_cours':
        color = Colors.purple;
        label = 'En livraison';
        break;
      case 'livree':
        color = Colors.green;
        label = 'Livrée';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildClientInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations Client',
            style: TextStyle(
              color: Color(0xFFFF6B35),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.person, 'Client ID: ${_order!.idClient}'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.phone, 'Téléphone: Non disponible'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on, 'Adresse: ${_order!.adresseLivraison}'),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations de Livraison',
            style: TextStyle(
              color: Color(0xFFFF6B35),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.store, 'Point de vente: ${_order!.idPointVente ?? 'Non assigné'}'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.restaurant, 'Cuisinier: ${_order!.idCuisinier ?? 'Non assigné'}'),
          if (_order!.notes != null && _order!.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow(Icons.note, 'Notes: ${_order!.notes}'),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusTimeline() {
    final timelineItems = [
      _TimelineItem(
        'Commande reçue',
        _order!.dateCommande,
        true,
        Colors.blue,
      ),
      _TimelineItem(
        'Préparation démarrée',
        _order!.tempsPreparationDebut,
        _order!.tempsPreparationDebut != null,
        Colors.orange,
      ),
      _TimelineItem(
        'Préparation terminée',
        _order!.tempsPreparationFin,
        _order!.tempsPreparationFin != null,
        Colors.orange,
      ),
      _TimelineItem(
        'Récupération par livreur',
        _order!.tempsRecuperationLivreur,
        _order!.tempsRecuperationLivreur != null,
        Colors.purple,
      ),
      _TimelineItem(
        'Livraison effectuée',
        _order!.tempsLivraison,
        _order!.tempsLivraison != null,
        Colors.green,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chronologie',
            style: TextStyle(
              color: Color(0xFFFF6B35),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...timelineItems.map((item) => _buildTimelineItem(item)),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(_TimelineItem item) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: item.completed ? item.color : Colors.grey,
          ),
          child: item.completed
              ? const Icon(Icons.check, color: Colors.white, size: 12)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: TextStyle(
                  color: item.completed ? Colors.white : Colors.white54,
                  fontSize: 14,
                  fontWeight: item.completed ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
              if (item.timestamp != null)
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(item.timestamp!),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (_order!.statut == 'livree') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green, width: 1),
        ),
        child: const Center(
          child: Text(
            'Livraison terminée',
            style: TextStyle(
              color: Colors.green,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        if (_order!.statut == 'en_preparation')
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isUpdatingStatus ? null : () => _updateDeliveryStatus('en_cours'),
              icon: const Icon(Icons.delivery_dining),
              label: const Text(
                'Commencer la livraison',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        if (_order!.statut == 'en_cours')
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isUpdatingStatus ? null : () => _updateDeliveryStatus('livree'),
              icon: const Icon(Icons.check_circle),
              label: const Text(
                'Marquer comme livrée',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF6B35), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class _TimelineItem {
  final String title;
  final DateTime? timestamp;
  final bool completed;
  final Color color;

  _TimelineItem(this.title, this.timestamp, this.completed, this.color);
}
