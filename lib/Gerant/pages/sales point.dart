import 'package:flutter/material.dart';
import 'package:supabase_app/models/sales_point.dart';
import 'package:supabase_app/Gerant/services/sales_point_service.dart';

import '../../routes/app_routes.dart';

class PointDeVentePage extends StatefulWidget {
  const PointDeVentePage({Key? key}) : super(key: key);

  @override
  _PointDeVentePageState createState() => _PointDeVentePageState();
}

class _PointDeVentePageState extends State<PointDeVentePage> {
  final _salesPointService = SalesPointService();
  bool _isLoading = true;
  String? _error;
  List<SalesPoint> _salesPoints = [];

  @override
  void initState() {
    super.initState();
    _loadSalesPoints();
  }

  Future<void> _loadSalesPoints() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final pointsData = await _salesPointService.getSalesPoints();
      final points = pointsData.map((data) => SalesPoint.fromJson(data)).toList();
      setState(() {
        _salesPoints = points;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showAddSalesPointDialog() {
    final _formKey = GlobalKey<FormState>();
    final _nomController = TextEditingController();
    final _adresseController = TextEditingController();
    final _villeController = TextEditingController();
    final _telephoneController = TextEditingController();
    bool _isOpen = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF424242),
          title: const Text(
            'Ajouter Point de Vente',
            style: TextStyle(color: Colors.white),
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nomController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Nom',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFFF6B35)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un nom';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _adresseController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Adresse',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFFF6B35)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une adresse';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _villeController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Ville',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFFF6B35)),
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _telephoneController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Téléphone',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFFF6B35)),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Ouvert',
                        style: TextStyle(color: Colors.white),
                      ),
                      StatefulBuilder(
                        builder: (context, setState) {
                          return Switch(
                            value: _isOpen,
                            onChanged: (value) {
                              setState(() {
                                _isOpen = value;
                              });
                            },
                            activeColor: const Color(0xFFFF6B35),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    final newPointData = {
                      'idPoint': 'PV${DateTime.now().millisecondsSinceEpoch}',
                      'nom': _nomController.text,
                      'adresse': _adresseController.text,
                      'ville': _villeController.text,
                      'telephone': _telephoneController.text,
                      'ouvert': _isOpen,
                      'heureOuverture': '09:00',
                      'heureFermeture': '22:00',
                    };

                    await _salesPointService.createSalesPoint(newPointData);
                    Navigator.of(context).pop();
                    _loadSalesPoints(); // Refresh the list
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Point de vente ajouté avec succès'),
                        backgroundColor: Color(0xFFFF6B35),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
              ),
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  void _showEditSalesPointDialog(SalesPoint point) {
    final _formKey = GlobalKey<FormState>();
    final _nomController = TextEditingController(text: point.title);
    final _adresseController = TextEditingController(text: point.address ?? '');
    final _villeController = TextEditingController();
    final _telephoneController = TextEditingController();
    bool _isOpen = point.isOpen;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF424242),
          title: const Text(
            'Modifier Point de Vente',
            style: TextStyle(color: Colors.white),
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nomController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Nom',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFFF6B35)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un nom';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _adresseController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Adresse',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFFF6B35)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une adresse';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _villeController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Ville',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFFF6B35)),
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _telephoneController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Téléphone',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFFF6B35)),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Ouvert',
                        style: TextStyle(color: Colors.white),
                      ),
                      StatefulBuilder(
                        builder: (context, setState) {
                          return Switch(
                            value: _isOpen,
                            onChanged: (value) {
                              setState(() {
                                _isOpen = value;
                              });
                            },
                            activeColor: const Color(0xFFFF6B35),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    final updateData = {
                      'nom': _nomController.text,
                      'adresse': _adresseController.text,
                      'ville': _villeController.text,
                      'telephone': _telephoneController.text,
                      'ouvert': _isOpen,
                      'heureOuverture': '09:00',
                      'heureFermeture': '22:00',
                    };

                    await _salesPointService.updateSalesPoint(point.id, updateData);
                    Navigator.of(context).pop();
                    _loadSalesPoints(); // Refresh the list
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Point de vente modifié avec succès'),
                        backgroundColor: Color(0xFFFF6B35),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
              ),
              child: const Text('Modifier'),
            ),
          ],
        );
      },
    );
  }

  void _showStatsDialog(SalesPoint point) {
    final openPoints = _salesPoints.where((p) => p.isOpen).length;
    final closedPoints = _salesPoints.length - openPoints;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF424242),
          title: Text(
            'Statistiques - ${point.title}',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatRow('Total Points de Vente', _salesPoints.length.toString()),
                const SizedBox(height: 8),
                _buildStatRow('Points Ouverts', openPoints.toString(), color: Colors.green),
                const SizedBox(height: 8),
                _buildStatRow('Points Fermés', closedPoints.toString(), color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Détails du Point:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStatRow('Statut', point.isOpen ? 'Ouvert' : 'Fermé'),
                if (point.address != null) ...[
                  const SizedBox(height: 8),
                  _buildStatRow('Adresse', point.address!),
                ],
                if (point.collaborators != null && point.collaborators!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildStatRow('Collaborateurs', point.collaborators!),
                ],
                const SizedBox(height: 8),
                _buildStatRow('ID', point.id),
                if (point.createdAt != null) ...[
                  const SizedBox(height: 8),
                  _buildStatRow('Créé le', point.createdAt!.toString().split(' ')[0]),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Fermer',
                style: TextStyle(color: Color(0xFFFF6B35)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
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
            image: const AssetImage('assets/images/group55.png'),
            fit: BoxFit.cover,
            opacity: 0.1,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 32),
              const Text(
                'POINTS DE VENTE',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.3,
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
              const SizedBox(height: 34),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Erreur: $_error', style: const TextStyle(color: Colors.red)),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadSalesPoints,
                                  child: const Text('Réessayer'),
                                ),
                              ],
                            ),
                          )
                        : _salesPoints.isEmpty
                            ? const Center(
                                child: Text(
                                  'Aucun point de vente',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _salesPoints.length,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemBuilder: (context, index) {
                                  final point = _salesPoints[index];
                                  const commandCount = 0; // TODO: Get actual command count
                                  final status = point.isOpen ? 'OUVERT' : 'FERMÉ';
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 28),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 120,
                                          height: 120,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFFF6B35),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Image.asset(
                                              'assets/images/logo.png',
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF424242),
                                              borderRadius: BorderRadius.circular(28),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '• ${point.title}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  '• $status - $commandCount cmd',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                if (point.address != null) ...[
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    '• ${point.address}',
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                                const SizedBox(height: 20),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: SizedBox(
                                                        height: 48,
                  child: ElevatedButton(
                    onPressed: () => _showStatsDialog(point),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'STATS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 18),
                                                    Expanded(
                                                      child: SizedBox(
                                                        height: 48,
                                                        child: ElevatedButton(
                                                          onPressed: () => _showEditSalesPointDialog(point),
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: const Color(0xFFFF6B35),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(22),
                                                            ),
                                                            elevation: 0,
                                                          ),
                                                          child: const Text(
                                                            'MODIFIER',
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.white,
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: SizedBox(
                  width: 260,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _showAddSalesPointDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'AJOUTER POINT',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF2B2B2B),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.clientHome),
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6B35),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.dashboard,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _loadSalesPoints,
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
