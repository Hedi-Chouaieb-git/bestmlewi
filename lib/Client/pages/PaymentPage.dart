import 'package:flutter/material.dart';
import 'package:supabase_app/services/auth_service.dart';
import '../../services/order_service.dart';
import '../../services/cart_service.dart';
import '../../models/cart_item.dart' as models;

class PaymentPage extends StatefulWidget {
  final double total;
  final String? clientId;

  const PaymentPage({super.key, required this.total, this.clientId});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedAddress = "";
  String selectedPayment = "Carte bancaire";
  TextEditingController couponCtrl = TextEditingController();
  TextEditingController addressCtrl = TextEditingController();

  double discount = 0;
  String? _savedAddress;

  final AuthService _authService = AuthService();
  final OrderService _orderService = OrderService();
  final CartService _cartService = CartService();

  // Coupon system
  Map<String, double> _availableCoupons = {};
  bool _isValidatingCoupon = false;

  @override
  void initState() {
    super.initState();
    _loadClientAddress();
  }

  Future<void> _loadClientAddress() async {
    if (widget.clientId != null) {
      try {
        final clientData = await _authService.getClientById(widget.clientId!);
        if (clientData != null) {
          final address = clientData['adresse'] as String?;
          if (address != null && address.isNotEmpty) {
            setState(() {
              _savedAddress = address;
              // Pre-fill the input with saved address
              addressCtrl.text = address;
              selectedAddress = address;
            });
          }
        }
      } catch (e) {
        // Handle error silently - user can still enter address manually
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    double finalTotal = widget.total - discount;

    return Scaffold(
      backgroundColor: const Color(0xFF2B2B2B),
      appBar: AppBar(
        title: const Text("Paiement"),
        backgroundColor: const Color(0xFF424242),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Adresse de livraison",
              style: TextStyle(color: Colors.orange, fontSize: 18),
            ),
            const SizedBox(height: 10),

            // Show saved address if available
            if (_savedAddress != null) ...[
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A3A),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.orange.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Adresse sauvegardée:",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _savedAddress!,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedAddress = _savedAddress!;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("Utiliser cette adresse"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Ou entrer une nouvelle adresse:",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 10),
            ],

            // Address input field
            TextField(
              controller: addressCtrl,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Entrer votre adresse de livraison",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF3A3A3A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.orange),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  selectedAddress = value;
                });
              },
            ),

            if (selectedAddress.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                "Adresse sélectionnée: $selectedAddress",
                style: const TextStyle(color: Colors.white),
              ),
            ],

            const SizedBox(height: 25),

            // Méthode de paiement
            const Text(
              "Méthode de paiement",
              style: TextStyle(color: Colors.orange, fontSize: 18),
            ),
            const SizedBox(height: 10),
            _buildOption("Carte bancaire", selectedPayment, () {
              setState(() => selectedPayment = "Carte bancaire");
            }),
            _buildOption("Paiement à la livraison", selectedPayment, () {
              setState(() => selectedPayment = "Paiement à la livraison");
            }),
            _buildOption("PayPal", selectedPayment, () {
              setState(() => selectedPayment = "PayPal");
            }),

            const SizedBox(height: 25),

            // Coupons
            const Text(
              "Code promo",
              style: TextStyle(color: Colors.orange, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: couponCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Entrer un coupon",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF3A3A3A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isValidatingCoupon ? Colors.grey : Colors.orange,
                  ),
                  onPressed: _isValidatingCoupon ? null : () => _validateCoupon(couponCtrl.text),
                  child: _isValidatingCoupon
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("OK"),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Addition
            const Text(
              "Addition",
              style: TextStyle(color: Colors.orange, fontSize: 18),
            ),
            const SizedBox(height: 10),
            _buildTotalRow("Sous-total :", "${widget.total.toStringAsFixed(2)} DT"),
            _buildTotalRow("Remise :", "- ${discount.toStringAsFixed(2)} DT"),
            const Divider(color: Colors.white30),
            _buildTotalRow("Total à payer :", "${finalTotal.toStringAsFixed(2)} DT", isBold: true),

            const SizedBox(height: 30),

            // Payer
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () async {
                  if (selectedAddress.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Veuillez sélectionner une adresse")),
                    );
                    return;
                  }

                  try {
                    // Get cart items
                    await _cartService.loadCart();
                    final cartItems = _cartService.items;

                    if (cartItems.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Votre panier est vide")),
                      );
                      return;
                    }

                    // Create the order
                    final order = await _orderService.createOrder(
                      idClient: widget.clientId ?? 'CLI001', // Default to CLI001 if not provided
                      items: cartItems,
                      montantTotal: finalTotal,
                      adresseLivraison: selectedAddress,
                      notes: 'Paiement: $selectedPayment',
                    );

                    // Clear the cart
                    await _cartService.clearCart();

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Commande créée avec succès! ID: ${order.idCommande}"),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // Navigate back to home or order tracking
                    Navigator.of(context).popUntil((route) => route.isFirst);

                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Erreur lors de la création de la commande: $e")),
                    );
                  }
                },
                child: const Text(
                  "Payer maintenant",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildOption(String text, String selected, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF3A3A3A),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected == text ? Colors.orange : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected == text ? Icons.radio_button_checked : Icons.radio_button_off,
              color: Colors.orange,
            ),
            const SizedBox(width: 10),
            Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              )),
          Text(value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              )),
        ],
      ),
    );
  }

  Future<void> _validateCoupon(String couponCode) async {
    if (couponCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer un code coupon")),
      );
      return;
    }

    setState(() => _isValidatingCoupon = true);

    try {
      // For now, we'll use a simple coupon system
      // In a real app, this would query a coupons table in the database
      final validCoupons = {
        'FOOD10': {'discount': 0.10, 'description': '10% de réduction'},
        'WELCOME15': {'discount': 0.15, 'description': '15% pour les nouveaux clients'},
        'SPECIAL20': {'discount': 0.20, 'description': '20% de réduction spéciale'},
        'SUMMER25': {'discount': 0.25, 'description': '25% été'},
      };

      if (validCoupons.containsKey(couponCode.toUpperCase())) {
        final couponData = validCoupons[couponCode.toUpperCase()]!;
        final discountPercent = couponData['discount'] as double;
        final discountAmount = widget.total * discountPercent;

        setState(() {
          discount = discountAmount;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${couponData['description']} appliqué (-${discountAmount.toStringAsFixed(2)} DT)"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Coupon invalide"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors de la validation: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isValidatingCoupon = false);
    }
  }
}
