import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../models/Product.dart';
import '../routes/app_routes.dart';

// Main Products Page
class MainProductsPage extends StatefulWidget {
  const MainProductsPage({Key? key}) : super(key: key);

  @override
  State<MainProductsPage> createState() => _MainProductsPageState();
}

class _MainProductsPageState extends State<MainProductsPage> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = true;
  String? _errorMessage;
  String selectedCategory = 'mlawi';
  String searchQuery = '';

  List<Product> allProducts = [];
  List<String> categories = ['mlawi', 'jus', 'supplumnet'];

  List<Product> get filteredProducts {
    return allProducts.where((product) {
      final matchesCategory = product.category == selectedCategory;
      final matchesSearch = searchQuery.isEmpty ||
          product.name.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _productService.fetchProducts(),
        _productService.fetchCategories(),
      ]);

      setState(() {
        allProducts = results[0] as List<Product>;
        final fetchedCategories = results[1] as List<String>;
        if (fetchedCategories.isNotEmpty) {
          categories = fetchedCategories;
          // Set default category if current one doesn't exist
          if (!categories.contains(selectedCategory) && categories.isNotEmpty) {
            selectedCategory = categories.first;
          }
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

              // Error message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.red),
                          onPressed: _loadData,
                        ),
                      ],
                    ),
                  ),
                ),

              // Category Filter Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((cat) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _buildCategoryChip(cat),
                    )).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Products List
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF6B35),
                        ),
                      )
                    : filteredProducts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.restaurant_menu,
                                  size: 64,
                                  color: Color(0xFF7C7C8D),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  searchQuery.isEmpty
                                      ? 'Aucun produit dans cette catégorie'
                                      : 'Aucun produit trouvé',
                                  style: const TextStyle(
                                    color: Color(0xFF7C7C8D),
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadData,
                            color: const Color(0xFFFF6B35),
                            child: ListView.builder(
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
                                            child: product.image.startsWith('http') || product.image.startsWith('https')
                                                ? Image.network(
                                                    product.image,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Image.asset(
                                                        'assets/images/logo.png',
                                                        fit: BoxFit.cover,
                                                      );
                                                    },
                                                  )
                                                : Image.asset(
                                                    product.image,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Image.asset(
                                                        'assets/images/logo.png',
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
                                              // Product Name
                                              Text(
                                                product.name,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              // Price
                                              Text(
                                                '${product.price.toStringAsFixed(2)} TND',
                                                style: const TextStyle(
                                                  color: Color(0xFFFF6B35),
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              // Description bullets
                                              if (product.description.isNotEmpty)
                                                ...product.description.take(3).map((desc) => Padding(
                                                  padding: const EdgeInsets.only(bottom: 4),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                    children: [
                                                      const Text(
                                                        '• ',
                                                        style: TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          desc,
                                                          style: const TextStyle(
                                                            color: Colors.white70,
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )).toList(),
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
                    // Logo - Navigate to Dashboard
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
                      },
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Home/Menu Button - Stay on menu
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

                    // Cart Button - Navigate to cart
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.cart);
                      },
                      child: const Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),

                    // Menu Button - Navigate to Dashboard
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
                      },
                      child: const Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 35,
                      ),
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
