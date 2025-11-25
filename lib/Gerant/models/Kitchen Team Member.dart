class KitchenMember {
  final String id;
  final String name;
  final String currentOrder; // or int orderCount;
  final String status;

  KitchenMember({
    required this.id,
    required this.name,
    required this.currentOrder,
    required this.status,
  });
}
