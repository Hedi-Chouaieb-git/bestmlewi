// ========================================
// FILE 2: lib/screens/coordinator/manage_commands_page.dart
// ========================================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
//import 'command_details_page.dart';

class ManageCommandsPage extends StatefulWidget {
  final String coordinatorId;

  const ManageCommandsPage({
    super.key,
    required this.coordinatorId,
  });

  @override
  State<ManageCommandsPage> createState() => _ManageCommandsPageState();
}

class _ManageCommandsPageState extends State<ManageCommandsPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> commands = [];
  List<Map<String, dynamic>> filteredCommands = [];
  bool isLoading = true;
  String selectedFilter = 'tous';

  @override
  void initState() {
    super.initState();
    loadCommands();
  }

  Future<void> loadCommands() async {
    setState(() => isLoading = true);

    try {
      final response = await supabase
          .from('Commande')
          .select('*, Client(nom, adresse), Collaborateurs(nom, prenom, disponible)')
          .order('dateCommande', ascending: false);

      setState(() {
        commands = List<Map<String, dynamic>>.from(response);
        applyFilter();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading commands: $e');
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void applyFilter() {
    if (selectedFilter == 'tous') {
      filteredCommands = commands;
    } else {
      filteredCommands = commands
          .where((cmd) => cmd['statut'] == selectedFilter)
          .toList();
    }
  }

  Future<void> updateCommandStatus(String commandId, String newStatus) async {
    try {
      await supabase
          .from('Commande')
          .update({'statut': newStatus})
          .eq('idCommande', commandId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Statut mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }

      loadCommands();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> assignDeliveryPerson(String commandId) async {
    try {
      final deliveryPersons = await supabase
          .from('Collaborateurs')
          .select()
          .eq('role', 'livreur')
          .eq('disponible', true);

      if (!mounted) return;

      if ((deliveryPersons as List).isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucun livreur disponible'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final selected = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF3A3A3A),
          title: const Text(
            'Assigner un livreur',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: deliveryPersons.length,
              itemBuilder: (context, index) {
                final person = deliveryPersons[index];
                return ListTile(
                  title: Text(
                    '${person['prenom']} ${person['nom']}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'ID: ${person['idCollab']}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  leading: const Icon(Icons.delivery_dining, color: Color(0xFFFF6B35)),
                  onTap: () => Navigator.pop(context, person),
                );
              },
            ),
          ),
        ),
      );

      if (selected != null) {
        await supabase
            .from('Commande')
            .update({'idCollab': selected['idCollab'], 'statut': 'en_cours'})
            .eq('idCommande', commandId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Livreur ${selected['prenom']} ${selected['nom']} assigné'),
              backgroundColor: Colors.green,
            ),
          );
        }

        loadCommands();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2B2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B2B2B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Gestion des Commandes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: loadCommands,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: isLoading
                ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
            )
                : filteredCommands.isEmpty
                ? const Center(
              child: Text(
                'Aucune commande',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            )
                : RefreshIndicator(
              color: const Color(0xFFFF6B35),
              onRefresh: loadCommands,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredCommands.length,
                itemBuilder: (context, index) {
                  return _buildCommandCard(filteredCommands[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'label': 'Tous', 'value': 'tous', 'color': Colors.grey},
      {'label': 'En attente', 'value': 'en_attente', 'color': Colors.orange},
      {'label': 'En préparation', 'value': 'en_preparation', 'color': Colors.blue},
      {'label': 'En cours', 'value': 'en_cours', 'color': Colors.purple},
      {'label': 'Livrée', 'value': 'livree', 'color': Colors.green},
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
          final isSelected = selectedFilter == filter['value'];

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
              setState(() {
                selectedFilter = filter['value'] as String;
                applyFilter();
              });
            },
            backgroundColor: Colors.white.withOpacity(0.1),
            selectedColor: (filter['color'] as Color).withOpacity(0.3),
            checkmarkColor: Colors.white,
            side: BorderSide(
              color: (filter['color'] as Color).withOpacity(isSelected ? 0.8 : 0.3),
              width: 1,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommandCard(Map<String, dynamic> command) {
    final client = command['Client'];
    final collaborateur = command['Collaborateurs'];
    final statut = command['statut'] ?? 'inconnu';
    final date = command['dateCommande'] != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(command['dateCommande']))
        : 'Date inconnue';

    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (statut) {
      case 'en_attente':
        statusColor = Colors.orange;
        statusLabel = 'En attente';
        statusIcon = Icons.pending_actions;
        break;
      case 'en_preparation':
        statusColor = Colors.blue;
        statusLabel = 'En préparation';
        statusIcon = Icons.restaurant;
        break;
      case 'en_cours':
        statusColor = Colors.purple;
        statusLabel = 'En cours de livraison';
        statusIcon = Icons.local_shipping;
        break;
      case 'livree':
        statusColor = Colors.green;
        statusLabel = 'Livrée';
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = statut;
        statusIcon = Icons.info;
    }

    return Card(
      color: Colors.white.withOpacity(0.08),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
         /* Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CommandDetailsPage(
                commandId: command['idCommande'],
                coordinatorId: widget.coordinatorId,
              ),
            ),
          ).then((_) => loadCommands());*/
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Commande #${command['idCommande']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          date,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor, width: 1),
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
              const Divider(color: Colors.white24, height: 24),

              if (client != null) ...[
                Row(
                  children: [
                    const Icon(Icons.person, color: Color(0xFFFF6B35), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Client',
                            style: TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                          Text(
                            client['nom'] ?? 'N/A',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              if (client?['adresse'] != null) ...[
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFFFF6B35), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        client['adresse'],
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              if (collaborateur != null)
                Row(
                  children: [
                    const Icon(Icons.delivery_dining, color: Color(0xFFFF6B35), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Livreur assigné',
                            style: TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                          Text(
                            '${collaborateur['prenom'] ?? ''} ${collaborateur['nom'] ?? ''}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (collaborateur['disponible'] == true)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 12),
                      ),
                  ],
                )
              else
                ElevatedButton.icon(
                  onPressed: () => assignDeliveryPerson(command['idCommande']),
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Assigner un livreur'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (statut == 'en_attente')
                    TextButton.icon(
                      onPressed: () => updateCommandStatus(
                        command['idCommande'],
                        'en_preparation',
                      ),
                      icon: const Icon(Icons.restaurant, size: 18),
                      label: const Text('Préparer'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
                  if (statut == 'en_preparation' && collaborateur != null)
                    TextButton.icon(
                      onPressed: () => updateCommandStatus(
                        command['idCommande'],
                        'en_cours',
                      ),
                      icon: const Icon(Icons.local_shipping, size: 18),
                      label: const Text('En livraison'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.purple,
                      ),
                    ),
                  if (statut == 'en_cours')
                    TextButton.icon(
                      onPressed: () => updateCommandStatus(
                        command['idCommande'],
                        'livree',
                      ),
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('Marquer livrée'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green,
                      ),
                    ),
                  TextButton(
                    onPressed: () {
                     /* Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CommandDetailsPage(
                            commandId: command['idCommande'],
                            coordinatorId: widget.coordinatorId,
                          ),
                        ),
                      ).then((_) => loadCommands());*/
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFF6B35),
                    ),
                    child: const Text('Détails →'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}