class CartItem {
  final String id;
  final String name;
  final String image;
  final List<String> description;
  int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.quantity,
    required this.price,
  });
}
