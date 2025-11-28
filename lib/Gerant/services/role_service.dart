import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/collaborator.dart';
import '../../models/sales_point.dart';

class RoleService {
  RoleService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Fetch all collaborators from the database
  Future<List<Collaborator>> fetchCollaborators() async {
    try {
      final response = await _client
          .from('Collaborateurs')
          .select('idCollab, nom, prenom, email, role, disponible, telephone')
          .order('nom');

      final rows = List<Map<String, dynamic>>.from(response);
      return rows.map((row) => Collaborator.fromJson(row)).toList();
    } catch (e) {
      // If table doesn't exist, return empty list
      return [];
    }
  }

  /// Fetch all available roles
  Future<List<String>> fetchRoles() async {
    try {
      // Try to fetch from a roles table, or return default roles
      final response = await _client
          .from('roles')
          .select('name')
          .order('name');

      final rows = List<Map<String, dynamic>>.from(response);
      if (rows.isNotEmpty) {
        return rows
            .map((row) => row['name'] as String? ?? '')
            .where((name) => name.isNotEmpty)
            .toList();
      }
    } catch (e) {
      // Table doesn't exist, use default roles
    }

    // Default roles if table doesn't exist
    return ['Cuisinier', 'Livreur', 'Chef', 'Coordinateur', 'Gérant'];
  }

  /// Fetch all sales points
  Future<List<SalesPoint>> fetchSalesPoints() async {
    try {
      final response = await _client
          .from('sales_points')
          .select('id, title, status, collaborators')
          .order('title');

      final rows = List<Map<String, dynamic>>.from(response);
      return rows.map((row) => SalesPoint.fromJson(row)).toList();
    } catch (e) {
      // If table doesn't exist, return empty list
      return [];
    }
  }

  /// Assign a role and sales point to a collaborator
  Future<void> assignRole({
    required String collaboratorId,
    required String role,
    String? salesPointId,
  }) async {
    try {
      // Update the collaborator's role
      await _client
          .from('Collaborateurs')
          .update({
            'role': role,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('idCollab', collaboratorId);

      // If sales point is provided, also update the sales_point_collaborators junction table
      if (salesPointId != null) {
        try {
          // Check if relationship already exists
          final existing = await _client
              .from('sales_point_collaborators')
              .select('id')
              .eq('collaborator_id', collaboratorId)
              .eq('sales_point_id', salesPointId)
              .maybeSingle();

          if (existing == null) {
            // Create new relationship
            await _client.from('sales_point_collaborators').insert({
              'collaborator_id': collaboratorId,
              'sales_point_id': salesPointId,
              'created_at': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          // Junction table might not exist, that's okay
        }
      }
    } on PostgrestException catch (e) {
      throw Exception('Erreur lors de l\'affectation du rôle: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: ${e.toString()}');
    }
  }

  /// Get collaborator by ID with full details
  Future<Collaborator?> getCollaborator(String id) async {
    try {
      final response = await _client
          .from('Collaborateurs')
          .select('idCollab, nom, prenom, email, role, disponible, telephone')
          .eq('idCollab', id)
          .maybeSingle();

      if (response == null) return null;

      return Collaborator.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}
