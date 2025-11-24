import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final String currentPage;

  const NavBar({super.key, required this.currentPage});

  Widget _buildNavButton({
    required BuildContext context,
    required String page,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final bool isSelected = currentPage == page;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? const Color(0xFFFF6B35) : null,
        ),
        child: Center(
          child: Icon(
            icon,
            size: 35,
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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

          // MENU
          _buildNavButton(
            context: context,
            page: "menu",
            icon: Icons.restaurant,
            onTap: () => Navigator.pushNamed(context, '/menu'),
          ),

          // CART
          _buildNavButton(
            context: context,
            page: "cart",
            icon: Icons.shopping_cart,
            onTap: () => Navigator.pushNamed(context, '/cart'),
          ),

          // DRAWER
          _buildNavButton(
            context: context,
            page: "menuDrawer",
            icon: Icons.menu,
            onTap: () => Navigator.pushNamed(context, '/drawer'),
          ),
        ],
      ),
    );
  }
}
