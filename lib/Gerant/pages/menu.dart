import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Product Model
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

  // Factory constructor to create Product from Supabase JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unknown',
      image: json['image'] ?? 'assets/images/mlawi.jpeg',
      description: (json['description'] as String?)?.split(',') ?? ['No description'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] ?? 'mlawi',
    );
  }
}

// Main Products Page with Supabase
class MainProductsPage extends StatefulWidget {
  const MainProductsPage({Key? key}) : super(key: key);

  @override
  State<MainProductsPage> createState() => _MainProductsPageState();
}

class _MainProductsPageState extends State<MainProductsPage> {
  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = 'mlawi';
  String searchQuery = '';

  List<Product> allProducts = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final client = Supabase.instance.client;

      // Fetch all products from Supabase
      final response = await client
          .from('products')
          .select()
          .order('created_at', ascending: false);

      // Convert response to Product list
      final products = (response as List)
          .map((p) => Product.fromJson(p as Map<String, dynamic>))
          .toList();

      setState(() {
        allProducts = products;
        loading = false;
      });
    } catch (err) {
      setState(() {
        error = err.toString();
        loading = false;
      });
      print('Error fetching products: $err');
    }
  }

  List<Product> get filteredProducts {
    return allProducts.where((product) {
      final matchesCategory = product.category == selectedCategory;
      final matchesSearch = searchQuery.isEmpty ||
          product.name.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        body: Center(
          child: Text('Error: $error', style: TextStyle(color: Colors.red)),
        ),
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF2B2B2B),
          image: DecorationImage(
            image: AssetImage('assets/images/group55.png'),
            fit: BoxFit.cover,
            opacity: 0.1,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Search Bar
              Padding(
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
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'search',
                      hintStyle: TextStyle(
                        color: Color(0xFF7C7C8D),
                        fontSize: 18,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Color(0xFF7C7C8D),
                        size: 28,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),

              // Category Filter Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    _buildCategoryChip('mlawi'),
                    const SizedBox(width: 12),
                    _buildCategoryChip('jus'),
                    const SizedBox(width: 12),
                    _buildCategoryChip('supplumnet'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Products List
              Expanded(
                child: filteredProducts.isEmpty
                    ? Center(
                  child: Text(
                    'No products found',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF424242),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFFF6B35),
                                  width: 4,
                                ),
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  product.image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/mlawi.jpeg',
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Product Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...product.description.map((desc) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '• ',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            desc,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )).toList(),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${product.price.toStringAsFixed(2)} TND',
                                    style: const TextStyle(
                                      color: Color(0xFFFF6B35),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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
                ),
              ),

              // Bottom Navigation Bar
              Container(
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF2B2B2B),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                    Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6B35),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to cart
                      },
                      child: const Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                    const Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 35,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B35) : const Color(0xFF424242),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          category,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
