import 'package:flutter/material.dart';
import 'package:supabase_app/Client/pages/product_detail.dart';
import 'package:supabase_app/Routes/app_routes.dart';
import '../../Gerant/services/product_service.dart';
import '../../models/product.dart';
import '../../services/cart_service.dart';
import '../../models/cart_item.dart';

import '../widgets/nav_bar.dart';

class ClientMenuPage extends StatefulWidget {
  const ClientMenuPage({super.key});

  @override
  State<ClientMenuPage> createState() => _ClientMenuPageState();
}

class _ClientMenuPageState extends State<ClientMenuPage> {
  final TextEditingController _searchController = TextEditingController();
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();
  String selectedCategory = 'Plat Principal';
  String searchQuery = '';
  List<Product> allProducts = [];
  List<String> categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCategories();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _productService.fetchProducts();
      setState(() {
        allProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur chargement produits: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _productService.fetchCategories();
      setState(() {
        categories = cats;
        if (categories.isNotEmpty && !categories.contains(selectedCategory)) {
          selectedCategory = categories.first;
        }
      });
    } catch (e) {
      // Use default categories if loading fails
      setState(() {
        categories = ['Plat Principal', 'Boisson', 'Dessert', 'Entrée'];
      });
    }
  }

  List<Product> get filteredProducts {
    return allProducts.where((p) {
      final matchesCategory = p.category == selectedCategory;
      final matchesSearch = searchQuery.isEmpty ||
          p.name.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF2B2B2B),
          image: DecorationImage(
            image: AssetImage('assets/images/group55.png'),
            fit: BoxFit.cover,
            opacity: 0.1,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(),

              const SizedBox(height: 10),

              _buildCategoryRow(),

              const SizedBox(height: 20),

              Expanded(child: _buildProductsList()),

              const NavBar(currentPage: AppRoutes.clientMenu),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF424242),
          borderRadius: BorderRadius.circular(50),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          onChanged: (value) => setState(() => searchQuery = value),
          decoration: const InputDecoration(
            hintText: 'search',
            hintStyle: TextStyle(color: Color(0xFF7C7C8D), fontSize: 18),
            prefixIcon: Icon(Icons.search, color: Color(0xFF7C7C8D)),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryRow() {
    if (categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            _buildCategoryChip('Plat Principal'),
            const SizedBox(width: 12),
            _buildCategoryChip('Boisson'),
            const SizedBox(width: 12),
            _buildCategoryChip('Dessert'),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            return Row(
              children: [
                _buildCategoryChip(category),
                const SizedBox(width: 12),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProductsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
      );
    }

    if (filteredProducts.isEmpty) {
      return const Center(
        child: Text(
          'Aucun produit trouvé',
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];

        return GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) {
                  return FractionallySizedBox(
                    heightFactor: 1,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF2B2B2B),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                      ),
                      child: ProductDetailPage(product: product, isModal: true),
                    ),
                  );
                },
              );
            },

            child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF3A3A3A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        product.image,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () async {
                          final cartItem = CartItem(
                            id: product.id,
                            name: product.name,
                            image: product.image,
                            price: product.price,
                            quantity: 1,
                            description: product.description.isNotEmpty ? product.description[0] : '',
                            category: product.category,
                          );
                          await _cartService.addItem(cartItem);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} ajouté au panier'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add,
                              size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),

                      const SizedBox(height: 6),

                      Text(
                        product.description.isNotEmpty ? product.description[0] : 'Aucune description disponible',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),

                      const SizedBox(height: 8),

                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "${product.price} DT",
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(String category) {
    final bool isSelected = selectedCategory == category;

    return GestureDetector(
      onTap: () => setState(() => selectedCategory = category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color:
          isSelected ? const Color(0xFFFF6B35) : const Color(0xFF424242),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          category,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
