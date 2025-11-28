import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

enum RealtimeListenTypes {
  postgresChanges,
  broadcast,
  presence,
}

class OrderService {
  OrderService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Create a new order
  Future<Order> createOrder({
    required String idClient,
    required List<CartItem> items,
    required double montantTotal,
    required String adresseLivraison,
    String? notes,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final idCommande = DateTime.now().millisecondsSinceEpoch.toString();

      final orderData = {
        'idCommande': idCommande,
        'idClient': idClient,
        'statut': 'en_attente',
        'dateCommande': DateTime.now().toIso8601String(),
        'montantTotal': montantTotal,
        'adresseLivraison': adresseLivraison,
        'notes': notes,
        'latitude': latitude,
        'longitude': longitude,
      };

      final response = await _client
          .from('Commande')
          .insert(orderData)
          .select()
          .single();

      final order = Order.fromJson(response);

      // Create order items (assuming there's an OrderItems table or similar)
      // For now, we'll store items in the order notes or handle differently
      // This might need a separate table for order items

      return order;
    } on PostgrestException catch (e) {
      throw Exception('Erreur lors de la création de la commande: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: ${e.toString()}');
    }
  }

  /// Fetch orders for a client
  Future<List<Order>> fetchClientOrders(String clientId) async {
    try {
      final response = await _client
          .from('Commande')
          .select()
          .eq('idClient', clientId)
          .order('dateCommande', ascending: false);

      final rows = List<Map<String, dynamic>>.from(response);
      return rows.map((row) => Order.fromJson(row)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch all orders (for managers/coordinators)
  Future<List<Order>> fetchAllOrders() async {
    try {
      final response = await _client
          .from('Commande')
          .select()
          .order('dateCommande', ascending: false);

      final rows = List<Map<String, dynamic>>.from(response);
      return rows.map((row) => Order.fromJson(row)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch orders by status
  Future<List<Order>> fetchOrdersByStatus(String status) async {
    try {
      final response = await _client
          .from('Commande')
          .select()
          .eq('statut', status)
          .order('dateCommande', ascending: false);

      final rows = List<Map<String, dynamic>>.from(response);
      return rows.map((row) => Order.fromJson(row)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Update order status
  Future<Order> updateOrderStatus({
    required String orderId,
    required String newStatus,
    String? idPointVente,
    String? idCollab,
    String? idCuisinier,
  }) async {
    try {
      final updates = {
        'statut': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Add timestamps based on status
      if (newStatus == 'en_preparation') {
        updates['tempsPreparationDebut'] = DateTime.now().toIso8601String();
      } else if (newStatus == 'en_cours') {
        updates['tempsRemiseLivreur'] = DateTime.now().toIso8601String();
        if (idCollab != null) updates['idCollab'] = idCollab;
      } else if (newStatus == 'livree') {
        updates['tempsLivraison'] = DateTime.now().toIso8601String();
        updates['dateLivraison'] = DateTime.now().toIso8601String();
      }

      if (idPointVente != null) updates['idPointVente'] = idPointVente;
      if (idCuisinier != null) updates['idCuisinier'] = idCuisinier;

      final response = await _client
          .from('Commande')
          .update(updates)
          .eq('idCommande', orderId)
          .select()
          .single();

      return Order.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Erreur lors de la mise à jour de la commande: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: ${e.toString()}');
    }
  }

  /// Get order by ID
  Future<Order?> getOrder(String orderId) async {
    try {
      final response = await _client
          .from('Commande')
          .select()
          .eq('idCommande', orderId)
          .maybeSingle();

      if (response == null) return null;
      return Order.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Stream orders for real-time updates
  Stream<List<Order>> streamOrders({String? status, String? clientId}) {
    var query = _client.from('Commande').select();

    if (status != null) {
      query = query.eq('statut', status);
    }

    if (clientId != null) {
      query = query.eq('idClient', clientId);
    }

    return query
        .order('dateCommande', ascending: false)
        .asStream()
        .map((response) {
          final rows = List<Map<String, dynamic>>.from(response);
          return rows.map((row) => Order.fromJson(row)).toList();
        });
  }

  /// Stream single order for real-time updates
  Stream<Order?> streamOrder(String orderId) {
    return _client
        .from('Commande')
        .select()
        .eq('idCommande', orderId)
        .asStream()
        .map((response) {
          if (response.isEmpty) return null;
          return Order.fromJson(response.first);
        });
  }

  /// Cancel order
  Future<void> cancelOrder(String orderId) async {
    try {
      await _client
          .from('Commande')
          .update({
            'statut': 'annulee',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('idCommande', orderId);
    } on PostgrestException catch (e) {
      throw Exception('Erreur lors de l\'annulation de la commande: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: ${e.toString()}');
    }
  }

  /// Reject order (manager action)
  Future<void> rejectOrder(String orderId, String reason) async {
    try {
      await _client
          .from('Commande')
          .update({
            'statut': 'rejete',
            'notes': reason,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('idCommande', orderId);

      // Create a refund request automatically
      await createRefundRequest(orderId, reason);
    } on PostgrestException catch (e) {
      throw Exception('Erreur lors du rejet de la commande: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: ${e.toString()}');
    }
  }

  /// Create refund request
  Future<void> createRefundRequest(String orderId, String reason) async {
    try {
      // First get the order to get client and amount info
      final order = await getOrder(orderId);
      if (order == null) return;

      final refundId = DateTime.now().millisecondsSinceEpoch.toString();

      await _client.from('RefundRequests').insert({
        'idRefund': refundId,
        'idCommande': orderId,
        'idClient': order.idClient,
        'motif': reason,
        'statut': 'en_attente',
        'montantRembourse': order.montantTotal,
      });
    } on PostgrestException catch (e) {
      print('Error creating refund request: ${e.message}');
      // Don't throw - refund request creation shouldn't fail the rejection
    } catch (e) {
      print('Unexpected error creating refund request: ${e.toString()}');
    }
  }
}
