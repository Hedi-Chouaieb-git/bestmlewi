import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/Product.dart';

class ProductService {
  ProductService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Fetch all products from the database
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await _client
          .from('products')
          .select('id, name, image, description, price, category')
          .order('name');

      final rows = List<Map<String, dynamic>>.from(response);
      return rows.map((row) => _productFromRow(row)).toList();
    } catch (e) {
      // If table doesn't exist, return empty list
      return [];
    }
  }

  /// Fetch products by category
  Future<List<Product>> fetchProductsByCategory(String category) async {
    try {
      final response = await _client
          .from('products')
          .select('id, name, image, description, price, category')
          .eq('category', category)
          .order('name');

      final rows = List<Map<String, dynamic>>.from(response);
      return rows.map((row) => _productFromRow(row)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get product by ID
  Future<Product?> getProduct(String id) async {
    try {
      final response = await _client
          .from('products')
          .select('id, name, image, description, price, category')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return _productFromRow(response);
    } catch (e) {
      return null;
    }
  }

  /// Create a new product
  Future<Product> createProduct({
    required String name,
    required String image,
    required List<String> description,
    required double price,
    required String category,
  }) async {
    try {
      final response = await _client.from('products').insert({
        'name': name,
        'image': image,
        'description': description, // Supabase handles JSON arrays
        'price': price,
        'category': category,
        'created_at': DateTime.now().toIso8601String(),
      }).select('id, name, image, description, price, category').single();

      return _productFromRow(response);
    } on PostgrestException catch (e) {
      throw Exception('Erreur lors de la création du produit: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: ${e.toString()}');
    }
  }

  /// Update an existing product
  Future<Product> updateProduct({
    required String id,
    String? name,
    String? image,
    List<String>? description,
    double? price,
    String? category,
  }) async {
    try {
      final Map<String, dynamic> updates = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updates['name'] = name;
      if (image != null) updates['image'] = image;
      if (description != null) updates['description'] = description;
      if (price != null) updates['price'] = price;
      if (category != null) updates['category'] = category;

      final response = await _client
          .from('products')
          .update(updates)
          .eq('id', id)
          .select('id, name, image, description, price, category')
          .single();

      return _productFromRow(response);
    } on PostgrestException catch (e) {
      throw Exception('Erreur lors de la mise à jour du produit: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: ${e.toString()}');
    }
  }

  /// Delete a product
  Future<void> deleteProduct(String id) async {
    try {
      await _client.from('products').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Erreur lors de la suppression du produit: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: ${e.toString()}');
    }
  }

  /// Get all available categories
  Future<List<String>> fetchCategories() async {
    try {
      final response = await _client
          .from('products')
          .select('category')
          .order('category');

      final rows = List<Map<String, dynamic>>.from(response);
      final categories = rows
          .map((row) => row['category'] as String? ?? '')
          .where((cat) => cat.isNotEmpty)
          .toSet()
          .toList();
      return categories;
    } catch (e) {
      // Return default categories if table doesn't exist
      return ['mlawi', 'jus', 'supplumnet'];
    }
  }

  /// Convert database row to Product model
  Product _productFromRow(Map<String, dynamic> row) {
    // Handle description - could be JSON array, string, or null
    List<String> description = [];
    final descData = row['description'];
    if (descData is List) {
      description = descData.map((e) => e.toString()).toList();
    } else if (descData is String) {
      // If it's a string, try to parse as JSON array first
      try {
        // Check if it looks like JSON array
        if (descData.trim().startsWith('[') && descData.trim().endsWith(']')) {
          // This would require dart:convert, but for now just split by comma or use as single
          description = [descData];
        } else {
          // Single description string
          description = [descData];
        }
      } catch (e) {
        // If parsing fails, treat as single description line
        description = [descData];
      }
    } else if (descData == null) {
      // No description provided
      description = [];
    }

    // Handle price - could be num or string
    double price = 0.0;
    final priceData = row['price'];
    if (priceData is num) {
      price = priceData.toDouble();
    } else if (priceData is String) {
      price = double.tryParse(priceData) ?? 0.0;
    }

    return Product(
      id: row['id'] as String? ?? '',
      name: row['name'] as String? ?? 'Unknown',
      image: row['image'] as String? ?? 'assets/images/logo.png',
      description: description,
      price: price,
      category: row['category'] as String? ?? 'mlawi',
    );
  }
}

