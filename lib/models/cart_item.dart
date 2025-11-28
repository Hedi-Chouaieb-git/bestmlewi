class CartItem {
  final String id;
  final String name;
  final String image;
  final String? description;
  int quantity;
  final double price;
  final String category;

  CartItem({
    required this.id,
    required this.name,
    required this.image,
    this.description,
    required this.quantity,
    required this.price,
    required this.category,
  });

  double get total => price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      description: json['description'] as String?,
      quantity: json['quantity'] as int? ?? 1,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'description': description,
      'quantity': quantity,
      'price': price,
      'category': category,
    };
  }

  CartItem copyWith({
    String? id,
    String? name,
    String? image,
    String? description,
    int? quantity,
    double? price,
    String? category,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      category: category ?? this.category,
    );
  }
}

