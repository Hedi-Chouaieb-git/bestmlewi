import 'dart:convert';

class Product {
  final String id;
  final String name;
  final String image;
  final List<String> description;
  final double price;
  final String category;
  final bool available;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.image,
    this.description = const [],
    required this.price,
    required this.category,
    this.available = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> description = [];
    final descData = json['description'];
    if (descData is List) {
      description = descData.map((e) => e.toString()).toList();
    } else if (descData is String) {
      try {
        if (descData.trim().startsWith('[') && descData.trim().endsWith(']')) {
          final decoded = jsonDecode(descData);
          if (decoded is List) {
            description = decoded.map((e) => e.toString()).toList();
          } else {
            description = [descData];
          }
        } else if (descData.isNotEmpty) {
          description = [descData];
        }
      } catch (e) {
        if (descData.isNotEmpty) {
          description = [descData];
        }
      }
    }

    return Product(
      id: json['id'] as String? ?? json['idProduit'] as String? ?? '',
      name: json['name'] as String? ?? json['nom'] as String? ?? 'Unknown',
      image: json['image'] as String? ?? 'assets/images/logo.png',
      description: description,
      price: (json['price'] as num?)?.toDouble() ?? (json['prix'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String? ?? json['categorie'] as String? ?? 'mlawi',
      available: json['available'] as bool? ?? json['disponible'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'description': description,
      'price': price,
      'category': category,
      'available': available,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
