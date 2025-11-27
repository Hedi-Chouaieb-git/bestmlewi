import 'package:flutter/material.dart';

import 'package:supabase_app/Routes/app_routes.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key, required this.currentPage});

  final String currentPage;

  Widget _buildNavButton({
    required BuildContext context,
    required String route,
    required IconData icon,
  }) {
    final bool isSelected = currentPage == route;
    return GestureDetector(
      onTap: () {
        if (isSelected) return;
        Navigator.pushReplacementNamed(context, route);
      },
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? const Color(0xFFFF6B35) : Colors.transparent,
        ),
        child: Icon(
          icon,
          size: 30,
          color: isSelected ? Colors.white : Colors.white70,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      decoration: const BoxDecoration(
        color: Color(0xFF2B2B2B),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 48,
            height: 48,
            fit: BoxFit.contain,
          ),
          _buildNavButton(
            context: context,
            route: AppRoutes.clientHome,
            icon: Icons.home_outlined,
          ),
          _buildNavButton(
            context: context,
            route: AppRoutes.clientMenu,
            icon: Icons.restaurant,
          ),
          _buildNavButton(
            context: context,
            route: AppRoutes.clientCart,
            icon: Icons.shopping_cart_outlined,
          ),
        ],
      ),
    );
  }
}
