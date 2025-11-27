import 'package:flutter/material.dart';
import 'package:supabase_app/Client/pages/product_detail.dart';
import '../widgets/nav_bar.dart';

class Product {
  final String id;
  final String name;
  final String image;
  final List<String> description;
  final double price;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.price,
    required this.category,
  });
}

class MainProductsPage extends StatefulWidget {
  const MainProductsPage({super.key});

  @override
  State<MainProductsPage> createState() => _MainProductsPageState();
}

class _MainProductsPageState extends State<MainProductsPage> {
  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = 'mlawi';
  String searchQuery = '';

  final List<Product> allProducts = [
    Product(
      id: '1',
      name: 'Shawarma Wrap',
      image: 'assets/images/shwarma.jpeg',
      description: [
        'orem ipsum dolor sit amet',
        'utpat Ut wisi enim ad',
        'lor in hendrerit in vu',
        'accumsan et iusto odio d',
      ],
      price: 250.0,
      category: 'mlawi',
    ),
    Product(
      id: '2',
      name: 'Crepe',
      image: 'assets/images/mlawi.jpeg',
      description: [
        'orem ipsum dolor sit amet',
        'utpat Ut wisi enim ad',
        'lor in hendrerit in vu',
        'accumsan et iusto odio d',
      ],
      price: 180.0,
      category: 'mlawi',
    ),
    Product(
      id: '3',
      name: 'Fresh Juice',
      image: 'assets/images/jus.jpeg',
      description: [
        'orem ipsum dolor sit amet',
        'utpat Ut wisi enim ad',
        'lor in hendrerit in vu',
        'accumsan et iusto odio d',
      ],
      price: 120.0,
      category: 'jus',
    ),
  ];

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

              const NavBar(currentPage: 'menu'),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildCategoryChip('mlawi'),
          const SizedBox(width: 12),
          _buildCategoryChip('jus'),
          const SizedBox(width: 12),
          _buildCategoryChip('supplement'),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
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
                        product.description[0],
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
