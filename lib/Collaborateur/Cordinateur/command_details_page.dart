import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../../services/notification_service.dart';

class CommandDetailsPage extends StatefulWidget {
  final String commandId;
  final String coordinatorId;

  const CommandDetailsPage({
    super.key,
    required this.commandId,
    required this.coordinatorId,
  });

  @override
  State<CommandDetailsPage> createState() => _CommandDetailsPageState();
}

class _CommandDetailsPageState extends State<CommandDetailsPage> {
  final supabase = Supabase.instance.client;
  Order? _order;
  Map<String, dynamic>? _clientData;
  Map<String, dynamic>? _collaboratorData;
  Map<String, dynamic>? _cookData;
  bool _isLoading = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadCommandDetails();
  }

  Future<void> _loadCommandDetails() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase
          .from('Commande')
          .select('*')
          .eq('idCommande', widget.commandId)
          .single();

      _order = Order.fromJson(response);

      // Load related data
      if (_order!.idClient.isNotEmpty) {
        _clientData = await supabase
            .from('Client')
            .select('idClient, nom, prenom, phone, adresse')
            .eq('idClient', _order!.idClient)
            .maybeSingle();
      }

      if (_order!.idCollab != null) {
        _collaboratorData = await supabase
            .from('Collaborateurs')
            .select('idCollab, nom, prenom, phone')
            .eq('idCollab', _order!.idCollab!)
            .maybeSingle();
      }

      if (_order!.idCuisinier != null) {
        _cookData = await supabase
            .from('Collaborateurs')
            .select('idCollab, nom, prenom')
            .eq('idCollab', _order!.idCuisinier!)
            .maybeSingle();
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print('Error loading details: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _assignCook() async {
    try {
      final cooks = await supabase
          .from('Collaborateurs')
          .select()
          .eq('role', 'cuisinier');

      if (!mounted) return;

      if ((cooks as List).isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucun cuisinier trouvé')),
        );
        return;
      }

      final selected = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF3A3A3A),
          title: const Text('Assigner un cuisinier', style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: cooks.length,
              itemBuilder: (context, index) {
                final cook = cooks[index];
                return ListTile(
                  title: Text('${cook['prenom']} ${cook['nom']}', style: const TextStyle(color: Colors.white)),
                  subtitle: Text('ID: ${cook['idCollab']}', style: const TextStyle(color: Colors.white70)),
                  onTap: () => Navigator.pop(context, cook),
                );
              },
            ),
          ),
        ),
      );

      if (selected != null) {
        setState(() => _isUpdating = true);
        final now = DateTime.now().toIso8601String();
        await supabase.from('Commande').update({
          'idCuisinier': selected['idCollab'],
          'statut': 'en_preparation',
          'tempsPreparationDebut': now,
        }).eq('idCommande', widget.commandId);

        // Notify cook
        final notif = NotificationService();
        await notif.createNotification(
          recipientId: selected['idCollab'],
          orderId: widget.commandId,
          type: 'commande_assignee',
          title: 'Nouvelle commande à préparer',
          message: 'Commande ${widget.commandId} assignée',
        );

        await _loadCommandDetails();
        setState(() => _isUpdating = false);
      }
    } catch (e) {
      setState(() => _isUpdating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  Future<void> _assignDelivery() async {
    try {
      final drivers = await supabase
          .from('Collaborateurs')
          .select()
          .eq('role', 'livreur');

      if (!mounted) return;

      if ((drivers as List).isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucun livreur trouvé')),
        );
        return;
      }

      final selected = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF3A3A3A),
          title: const Text('Assigner un livreur', style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: drivers.length,
              itemBuilder: (context, index) {
                final driver = drivers[index];
                return ListTile(
                  title: Text('${driver['prenom']} ${driver['nom']}', style: const TextStyle(color: Colors.white)),
                  subtitle: Text('ID: ${driver['idCollab']}', style: const TextStyle(color: Colors.white70)),
                  onTap: () => Navigator.pop(context, driver),
                );
              },
            ),
          ),
        ),
      );

      if (selected != null) {
        setState(() => _isUpdating = true);
        final now = DateTime.now().toIso8601String();
        await supabase.from('Commande').update({
          'idCollab': selected['idCollab'],
          'statut': 'en_preparation', // Or keep current status if just assigning
          'tempsRemiseLivreur': now,
        }).eq('idCommande', widget.commandId);

        // Notify driver
        final notif = NotificationService();
        await notif.createNotification(
          recipientId: selected['idCollab'],
          orderId: widget.commandId,
          type: 'commande_assignee',
          title: 'Nouvelle livraison assignée',
          message: 'Commande ${widget.commandId} assignée',
        );

        await _loadCommandDetails();
        setState(() => _isUpdating = false);
      }
    } catch (e) {
      setState(() => _isUpdating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
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
        title: const Text('Détails de la Commande', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadCommandDetails,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B35)))
          : _order == null
              ? const Center(child: Text('Commande non trouvée', style: TextStyle(color: Colors.white)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildClientSection(),
                      const SizedBox(height: 20),
                      _buildStaffSection(),
                      const SizedBox(height: 20),
                      _buildTimeline(),
                      const SizedBox(height: 20),
                      _buildActions(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader() {
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
              Expanded(
                child: Text(
                  'Commande #${_order!.idCommande}',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildStatusBadge(_order!.statut),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(_order!.dateCommande)}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 5),
          Text(
            'Total: ${_order!.montantTotal.toStringAsFixed(2)} TND',
            style: const TextStyle(color: Color(0xFFFF6B35), fontSize: 18, fontWeight: FontWeight.bold),
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
        border: Border.all(color: color),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildClientSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Client', style: TextStyle(color: Color(0xFFFF6B35), fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (_clientData != null) ...[
            _buildInfoRow(Icons.person, '${_clientData!['prenom']} ${_clientData!['nom']}'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone, _clientData!['phone'] ?? 'Non disponible'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on, _order!.adresseLivraison),
          ] else
            const Text('Information client non disponible', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildStaffSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Personnel', style: TextStyle(color: Color(0xFFFF6B35), fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.restaurant, _cookData != null 
              ? 'Cuisinier: ${_cookData!['prenom']} ${_cookData!['nom']}' 
              : 'Cuisinier: Non assigné'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.delivery_dining, _collaboratorData != null 
              ? 'Livreur: ${_collaboratorData!['prenom']} ${_collaboratorData!['nom']}' 
              : 'Livreur: Non assigné'),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    // Simple timeline implementation
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Chronologie', style: TextStyle(color: Color(0xFFFF6B35), fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildTimelineItem('Commande reçue', _order!.dateCommande, true),
          if (_order!.tempsPreparationDebut != null)
            _buildTimelineItem('Préparation commencée', _order!.tempsPreparationDebut!, true),
          if (_order!.tempsRecuperationLivreur != null)
            _buildTimelineItem('Récupérée par livreur', _order!.tempsRecuperationLivreur!, true),
          if (_order!.tempsLivraison != null)
            _buildTimelineItem('Livrée', _order!.tempsLivraison!, true),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, DateTime date, bool completed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(completed ? Icons.check_circle : Icons.circle_outlined, color: completed ? Colors.green : Colors.grey, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text('$title (${DateFormat('HH:mm').format(date)})', style: const TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        if (_order!.idCuisinier == null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isUpdating ? null : _assignCook,
              icon: const Icon(Icons.restaurant),
              label: const Text('Assigner Cuisinier'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B35)),
            ),
          ),
        const SizedBox(height: 10),
        if (_order!.idCollab == null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isUpdating ? null : _assignDelivery,
              icon: const Icon(Icons.delivery_dining),
              label: const Text('Assigner Livreur'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFFF6B35), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }
}
