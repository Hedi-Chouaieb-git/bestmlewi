import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/product.dart';

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
      return rows.map((row) => Product.fromJson(row)).toList();
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
      return rows.map((row) => Product.fromJson(row)).toList();
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
      return Product.fromJson(response);
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

      return Product.fromJson(response);
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

      return Product.fromJson(response);
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
      return ['mlawi', 'jus', 'supplement'];
    }
  }
}
