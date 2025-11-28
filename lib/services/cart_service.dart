import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/cart_item.dart';

class CartService {
  static const String _cartKey = 'client_cart';
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  List<CartItem> _cartItems = [];
  List<Function(List<CartItem>)> _listeners = [];

  List<CartItem> get items => List.unmodifiable(_cartItems);

  double get total => _cartItems.fold(0.0, (sum, item) => sum + item.total);

  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  void addListener(Function(List<CartItem>) listener) {
    _listeners.add(listener);
  }

  void removeListener(Function(List<CartItem>) listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (var listener in _listeners) {
      listener(_cartItems);
    }
  }

  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);
      if (cartJson != null) {
        final List<dynamic> decoded = jsonDecode(cartJson);
        _cartItems = decoded.map((item) => CartItem.fromJson(item)).toList();
        _notifyListeners();
      }
    } catch (e) {
      _cartItems = [];
    }
  }

  Future<void> saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(_cartItems.map((item) => item.toJson()).toList());
      await prefs.setString(_cartKey, cartJson);
    } catch (e) {
      print('Error saving cart: $e');
    }
  }

  Future<void> addItem(CartItem item) async {
    final existingIndex = _cartItems.indexWhere((i) => i.id == item.id);
    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity += item.quantity;
    } else {
      _cartItems.add(item);
    }
    await saveCart();
    _notifyListeners();
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(itemId);
      return;
    }
    final index = _cartItems.indexWhere((i) => i.id == itemId);
    if (index >= 0) {
      _cartItems[index].quantity = quantity;
      await saveCart();
      _notifyListeners();
    }
  }

  Future<void> removeItem(String itemId) async {
    _cartItems.removeWhere((item) => item.id == itemId);
    await saveCart();
    _notifyListeners();
  }

  Future<void> clearCart() async {
    _cartItems.clear();
    await saveCart();
    _notifyListeners();
  }
}

