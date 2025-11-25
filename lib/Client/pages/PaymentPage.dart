import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';

class PaymentPage extends StatefulWidget {
  final double total;

  const PaymentPage({super.key, required this.total});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedAddress = "";
  String selectedPayment = "Carte bancaire";
  TextEditingController couponCtrl = TextEditingController();

  double discount = 0;

  final places = FlutterGooglePlacesSdk("VOTRE_API_KEY"); // 🔑 Remplace par ta clé

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
            TypeAheadField<AutocompletePrediction>(
              textFieldConfiguration: TextFieldConfiguration(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Chercher une adresse",
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF3A3A3A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              suggestionsCallback: (pattern) async {
                if (pattern.isEmpty) return [];
                final result = await places.findAutocompletePredictions(pattern);
                return result.predictions;
              },
              itemBuilder: (context, AutocompletePrediction suggestion) {
                return ListTile(
                  title: Text(suggestion.fullText),
                );
              },
              onSuggestionSelected: (AutocompletePrediction suggestion) {
                setState(() {
                  selectedAddress = suggestion.fullText;
                });
              },
            ),
            const SizedBox(height: 10),
            Text(
              "Adresse sélectionnée: $selectedAddress",
              style: const TextStyle(color: Colors.white),
            ),

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
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: () {
                    if (couponCtrl.text == "FOOD10") {
                      setState(() => discount = widget.total * 0.1);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Coupon appliqué (-10%)")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Coupon invalide")),
                      );
                    }
                  },
                  child: const Text("OK"),
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
                onPressed: () {
                  if (selectedAddress.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Veuillez sélectionner une adresse")),
                    );
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Paiement effectué ✔")),
                  );
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
}
