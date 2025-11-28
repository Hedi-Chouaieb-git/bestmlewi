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
          .from('Produit')
          .select('idProduit, nom, image, description, prix, categorie, disponible, created_at, updated_at')
          .eq('disponible', true)
          .order('nom');

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
          .from('Produit')
          .select('idProduit, nom, image, description, prix, categorie, disponible, created_at, updated_at')
          .eq('categorie', category)
          .eq('disponible', true)
          .order('nom');

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
          .from('Produit')
          .select('idProduit, nom, image, description, prix, categorie, disponible, created_at, updated_at')
          .eq('idProduit', id)
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
    required String description,
    required double price,
    required String category,
  }) async {
    try {
      final idProduit = DateTime.now().millisecondsSinceEpoch.toString();
      final response = await _client.from('Produit').insert({
        'idProduit': idProduit,
        'nom': name,
        'image': image,
        'description': description,
        'prix': price,
        'categorie': category,
        'disponible': true,
      }).select('idProduit, nom, image, description, prix, categorie, disponible, created_at, updated_at').single();

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
    String? description,
    double? price,
    String? category,
    bool? disponible,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (name != null) updates['nom'] = name;
      if (image != null) updates['image'] = image;
      if (description != null) updates['description'] = description;
      if (price != null) updates['prix'] = price;
      if (category != null) updates['categorie'] = category;
      if (disponible != null) updates['disponible'] = disponible;

      final response = await _client
          .from('Produit')
          .update(updates)
          .eq('idProduit', id)
          .select('idProduit, nom, image, description, prix, categorie, disponible, created_at, updated_at')
          .single();

      return Product.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Erreur lors de la mise à jour du produit: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: ${e.toString()}');
    }
  }

  /// Delete a product (soft delete by setting disponible to false)
  Future<void> deleteProduct(String id) async {
    try {
      await _client
          .from('Produit')
          .update({'disponible': false})
          .eq('idProduit', id);
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
          .from('Produit')
          .select('categorie')
          .eq('disponible', true)
          .order('categorie');

      final rows = List<Map<String, dynamic>>.from(response);
      final categories = rows
          .map((row) => row['categorie'] as String? ?? '')
          .where((cat) => cat.isNotEmpty)
          .toSet()
          .toList();
      return categories;
    } catch (e) {
      // Return default categories if table doesn't exist
      return ['Plat Principal', 'Boisson', 'Dessert', 'Supplement'];
    }
  }
}
