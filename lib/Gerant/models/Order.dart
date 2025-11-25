import '../../Client/pages/cart.dart';

class Order {
  final String id;
  final String clientName;
  final String clientPhone;
  final String clientAddress;
  final List<CartItem> items;
  final String pickupPoint;
  final String pickupPhone;
  final String status;
  final double total;

  Order({
    required this.id,
    required this.clientName,
    required this.clientPhone,
    required this.clientAddress,
    required this.items,
    required this.pickupPoint,
    required this.pickupPhone,
    required this.status,
    required this.total,
  });
}
