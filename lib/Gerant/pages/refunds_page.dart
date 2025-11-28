import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class RefundsPage extends StatefulWidget {
  const RefundsPage({super.key});

  @override
  State<RefundsPage> createState() => _RefundsPageState();
}

class _RefundsPageState extends State<RefundsPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _refunds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRefunds();
  }

  Future<void> _loadRefunds() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase
          .from('RefundRequests')
          .select('*, Commande(idCommande, montantTotal, Client(idClient, nom, prenom)), Collaborateurs(idCollab, nom, prenom)')
          .order('created_at', ascending: false);

      setState(() {
        _refunds = List<Map<String, dynamic>>.from(response);
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

  Future<void> _processRefund(String refundId, String status, {double? amount}) async {
    try {
      final now = DateTime.now().toIso8601String();
      final updates = {
        'statut': status,
        'dateTraitement': now,
        'traiteePar': 'GER001', // This should be the current manager ID
      };

      if (amount != null) {
        updates['montantRembourse'] = amount.toString();
      }

      await supabase
          .from('RefundRequests')
          .update(updates)
          .eq('idRefund', refundId);

      await _loadRefunds();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Demande de remboursement ${status == 'approuvee' ? 'approuvée' : 'refusée'}'),
            backgroundColor: status == 'approuvee' ? Colors.green : Colors.orange,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2B2B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Gestion des remboursements',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _loadRefunds,
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
            : _refunds.isEmpty
                ? const Center(
                    child: Text(
                      'Aucune demande de remboursement',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  )
                : RefreshIndicator(
                    color: const Color(0xFFFF6B35),
                    onRefresh: _loadRefunds,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _refunds.length,
                      itemBuilder: (context, index) => _buildRefundCard(_refunds[index]),
                    ),
                  ),
      ),
    );
  }

  Widget _buildRefundCard(Map<String, dynamic> refund) {
    final order = refund['Commande'];
    final client = order?['Client'];
    final manager = refund['Collaborateurs'];
    final status = refund['statut'] ?? 'inconnu';
    final createdAt = refund['created_at'] != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(refund['created_at']))
        : 'Date inconnue';

    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (status) {
      case 'en_attente':
        statusColor = Colors.orange;
        statusLabel = 'En attente';
        statusIcon = Icons.pending;
        break;
      case 'approuvee':
        statusColor = Colors.green;
        statusLabel = 'Approuvée';
        statusIcon = Icons.check_circle;
        break;
      case 'refusee':
        statusColor = Colors.red;
        statusLabel = 'Refusée';
        statusIcon = Icons.cancel;
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
                'Demande #${refund['idRefund']}',
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
            'Créée le: $createdAt',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),

          if (order != null) ...[
            Text(
              'Commande: #${order['idCommande']}',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Montant: ${order['montantTotal']?.toString() ?? '0'} DT',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
          ],

          if (client != null) ...[
            Text(
              'Client: ${client['nom'] ?? 'N/A'}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
          ],

          Text(
            'Motif: ${refund['motif'] ?? 'Non spécifié'}',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),

          if (manager != null && status != 'en_attente') ...[
            const SizedBox(height: 8),
            Text(
              'Traité par: ${manager['prenom'] ?? ''} ${manager['nom'] ?? ''}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            if (refund['dateTraitement'] != null)
              Text(
                'Date de traitement: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(refund['dateTraitement']))}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            if (refund['montantRembourse'] != null)
              Text(
                'Montant remboursé: ${refund['montantRembourse']} DT',
                style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold),
              ),
          ],

          if (refund['notes'] != null && refund['notes'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Notes: ${refund['notes']}',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],

          const SizedBox(height: 16),
          if (status == 'en_attente')
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showProcessRefundDialog(refund),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Traiter'),
                  style: TextButton.styleFrom(foregroundColor: Colors.green),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showProcessRefundDialog(Map<String, dynamic> refund) {
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF3A3A3A),
        title: const Text('Traiter la demande de remboursement', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Décision:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Montant à rembourser (DT)',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFF6B35)),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Notes (optionnel)',
                labelStyle: TextStyle(color: Colors.white70),
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final amount = double.tryParse(amountController.text);
              _processRefund(refund['idRefund'], 'approuvee', amount: amount);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Approuver'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _processRefund(refund['idRefund'], 'refusee');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Refuser'),
          ),
        ],
      ),
    );
  }
}
