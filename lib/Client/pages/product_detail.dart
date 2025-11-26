import 'package:flutter/material.dart';

class ProductDetailPage extends StatefulWidget {
  final dynamic product;

  const ProductDetailPage({super.key, required this.product, required bool isModal});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool extraSauce = false;
  bool spicy = false;
  bool cheese = false;

  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2B2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF424242),
        title: Text(widget.product.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(0xFFFF6B35), width: 5),
                ),
                child: ClipOval(
                  child: Image.asset(widget.product.image, fit: BoxFit.cover),
                ),
              ),
            ),

            const SizedBox(height: 20),

            ...widget.product.description.map(
                  (desc) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  "- $desc",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Recommandations",
              style: TextStyle(color: Color(0xFFFF6B35), fontSize: 18),
            ),

            _buildCheck("Extra Sauce", extraSauce, (v) {
              setState(() => extraSauce = v);
            }),
            _buildCheck("Spicy", spicy, (v) {
              setState(() => spicy = v);
            }),
            _buildCheck("Cheese", cheese, (v) {
              setState(() => cheese = v);
            }),

            const SizedBox(height: 20),
            const SizedBox(height: 20),

// QUANTITY SELECTOR CENTERED
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // 👈 centré
              children: [
                // BOUTON -
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFFFF6B35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.remove, color: Colors.white),
                    onPressed: () {
                      if (quantity > 1) setState(() => quantity--);
                    },
                  ),
                ),

                const SizedBox(width: 20),

                // QUANTITY TEXT
                Text(
                  "$quantity",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(width: 20),

                // BOUTON +
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFFFF6B35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      setState(() => quantity++);
                    },
                  ),
                ),
              ],
            ),


            const SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 60, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Commande enregistrée !")),
                  );
                },
                child: const Text(
                  "Ajouter au panier",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheck(String title, bool value, Function(bool) onChanged) {
    return CheckboxListTile(
      value: value,
      onChanged: (v) => onChanged(v ?? false),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      activeColor: Colors.orange,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
