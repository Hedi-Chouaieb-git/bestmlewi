import 'package:supabase_flutter/supabase_flutter.dart';

class SalesPointService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _tableName = 'PointDeVente';

  // Get all sales points
  Future<List<Map<String, dynamic>>> getSalesPoints() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('*')
          .order('nom', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch sales points: $e');
    }
  }

  // Get a single sales point by ID
  Future<Map<String, dynamic>> getSalesPoint(String id) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('*')
          .eq('idPoint', id)
          .single();
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch sales point: $e');
    }
  }

  // Create a new sales point
  Future<Map<String, dynamic>> createSalesPoint(Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .insert(data)
          .select()
          .single();
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to create sales point: $e');
    }
  }

  // Update an existing sales point
  Future<Map<String, dynamic>> updateSalesPoint(
      String id, Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .update(data)
          .eq('idPoint', id)
          .select()
          .single();
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to update sales point: $e');
    }
  }

  // Delete a sales point
  Future<void> deleteSalesPoint(String id) async {
    try {
      await _supabase.from(_tableName).delete().eq('idPoint', id);
    } catch (e) {
      throw Exception('Failed to delete sales point: $e');
    }
  }

  // Get sales points with optional filters
  Future<List<Map<String, dynamic>>> getFilteredSalesPoints({
    bool? isOpen,
    String? address,
  }) async {
    try {
      var query = _supabase.from(_tableName).select('*');

      if (isOpen != null) {
        query = query.eq('ouvert', isOpen);
      }

      if (address != null && address.isNotEmpty) {
        query = query.ilike('adresse', '%$address%');
      }

      final response = await query.order('nom', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch filtered sales points: $e');
    }
  }


}
