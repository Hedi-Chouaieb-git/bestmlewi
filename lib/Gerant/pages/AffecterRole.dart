import 'package:flutter/material.dart';
import '../services/role_service.dart';
import '../models/Collaborator.dart';
import '../models/Sales Point.dart';
import 'package:supabase_app/Routes/app_routes.dart';

class AffecterRolePage extends StatefulWidget {
  @override
  State<AffecterRolePage> createState() => _AffecterRolePageState();
}

class _AffecterRolePageState extends State<AffecterRolePage> {
  final RoleService _roleService = RoleService();
  
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  String? selectedUserId;
  String? selectedRole;
  String? selectedPointId;

  List<Collaborator> _collaborators = [];
  List<String> _roles = [];
  List<SalesPoint> _salesPoints = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _roleService.fetchCollaborators(),
        _roleService.fetchRoles(),
        _roleService.fetchSalesPoints(),
      ]);

      setState(() {
        _collaborators = results[0] as List<Collaborator>;
        _roles = results[1] as List<String>;
        _salesPoints = results[2] as List<SalesPoint>;
        _isLoading = false;

        // Set default selected user if available and load their current data
        if (_collaborators.isNotEmpty && selectedUserId == null) {
          selectedUserId = _collaborators.first.id;
          _updateDropdownsForSelectedCollaborator(_collaborators.first);
        } else if (selectedUserId != null) {
          // Reload current collaborator's data
          final selectedCollab = _collaborators.firstWhere(
            (c) => c.id == selectedUserId,
            orElse: () => _collaborators.first,
          );
          _updateDropdownsForSelectedCollaborator(selectedCollab);
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSave() async {
    if (selectedUserId == null || selectedRole == null) {
      setState(() {
        _errorMessage = 'Veuillez sélectionner un collaborateur et un rôle';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _roleService.assignRole(
        collaboratorId: selectedUserId!,
        role: selectedRole!,
        salesPointId: selectedPointId,
      );

      setState(() {
        _isSaving = false;
        _successMessage = 'Rôle affecté avec succès!';
      });

      // Reload data to show updated role
      await _loadData();

      // Show success message for 2 seconds, then navigate back
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  /// Update role and sales point dropdowns based on selected collaborator
  void _updateDropdownsForSelectedCollaborator(Collaborator collaborator) {
    setState(() {
      // Set current role if it exists in the roles list
      if (collaborator.role.isNotEmpty && _roles.contains(collaborator.role)) {
        selectedRole = collaborator.role;
      } else {
        selectedRole = null;
      }

      // Set current sales point if it exists
      if (collaborator.salesPointId != null && 
          _salesPoints.any((sp) => sp.id == collaborator.salesPointId)) {
        selectedPointId = collaborator.salesPointId;
      } else {
        selectedPointId = null;
      }
    });
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
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFF6B35),
                  ),
                )
              : Column(
                  children: [
                    const SizedBox(height: 38),
                    // Title
                    const Text(
                      'AFFECTER UN RÔLE',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 240,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 44),

                    // Error message
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red, width: 1),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Success message
                    if (_successMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green, width: 1),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _successMessage!,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Dropdown fields
                    _buildCollaboratorDropdown(),
                    const SizedBox(height: 30),
                    _buildRoleDropdown(),
                    const SizedBox(height: 30),
                    _buildSalesPointDropdown(),

                    const Spacer(),

                    // Buttons
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Save Button
                          SizedBox(
                            width: 180,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _handleSave,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6B35),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                elevation: 0,
                                disabledBackgroundColor: const Color(0xFFFF6B35).withOpacity(0.5),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'SAUVEGARDER',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 22),
                          // Cancel Button
                          SizedBox(
                            width: 180,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _handleCancel,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6B35),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                elevation: 0,
                                disabledBackgroundColor: const Color(0xFFFF6B35).withOpacity(0.5),
                              ),
                              child: const Text(
                                'ANNULER',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

              // Bottom Navigation Bar
              Container(
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF2B2B2B),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Logo - Navigate to Dashboard
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.gerantDashboard);
                      },
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                    ),
                    // Home/Menu Button - Navigate to Dashboard
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.gerantDashboard);
                      },
                      child: Container(
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
                    ),
                    // Menu Button - Navigate to Collaborateurs
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.gerantTeam);
                      },
                      child: const Icon(
                        Icons.menu,
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

  Widget _buildCollaboratorDropdown() {
    if (_collaborators.isEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 18),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF424242),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Aucun collaborateur disponible',
          style: TextStyle(
            color: Color(0xFF7C7C8D),
            fontSize: 20,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF424242),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedUserId,
          hint: const Text(
            'Sélectionner un collaborateur',
            style: TextStyle(
              color: Color(0xFF7C7C8D),
              fontSize: 20,
              fontFamily: 'Montserrat',
            ),
          ),
          items: _collaborators
              .map((collab) => DropdownMenuItem(
                    value: collab.id,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          collab.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        if (collab.role.isNotEmpty)
                          Text(
                            'Rôle actuel: ${collab.role}',
                            style: const TextStyle(
                              color: Color(0xFF7C7C8D),
                              fontSize: 14,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                      ],
                    ),
                  ))
              .toList(),
          dropdownColor: const Color(0xFF424242),
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFF6B35), size: 32),
          onChanged: (val) {
            if (val != null) {
              final selectedCollab = _collaborators.firstWhere(
                (c) => c.id == val,
              );
              setState(() {
                selectedUserId = val;
              });
              _updateDropdownsForSelectedCollaborator(selectedCollab);
            }
          },
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    if (_roles.isEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 18),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF424242),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Aucun rôle disponible',
          style: TextStyle(
            color: Color(0xFF7C7C8D),
            fontSize: 20,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF424242),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedRole,
          hint: const Text(
            'Nouveau rôle',
            style: TextStyle(
              color: Color(0xFF7C7C8D),
              fontSize: 20,
              fontFamily: 'Montserrat',
            ),
          ),
          items: _roles
              .map((role) => DropdownMenuItem(
                    value: role,
                    child: Text(
                      role,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ))
              .toList(),
          dropdownColor: const Color(0xFF424242),
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFF6B35), size: 32),
          onChanged: (val) => setState(() => selectedRole = val),
        ),
      ),
    );
  }

  Widget _buildSalesPointDropdown() {
    if (_salesPoints.isEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 18),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF424242),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Aucun point de vente disponible',
          style: TextStyle(
            color: Color(0xFF7C7C8D),
            fontSize: 20,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF424242),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedPointId,
          hint: const Text(
            'Point de vente (optionnel)',
            style: TextStyle(
              color: Color(0xFF7C7C8D),
              fontSize: 20,
              fontFamily: 'Montserrat',
            ),
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text(
                'Aucun point de vente',
                style: TextStyle(
                  color: Color(0xFF7C7C8D),
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            ..._salesPoints.map((point) => DropdownMenuItem(
                  value: point.id,
                  child: Text(
                    point.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                )),
          ],
          dropdownColor: const Color(0xFF424242),
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFF6B35), size: 32),
          onChanged: (val) => setState(() => selectedPointId = val),
        ),
      ),
    );
  }
}
