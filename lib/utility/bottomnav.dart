import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({
    super.key,
    this.currentIndex = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          color: const Color(0xFF1E1733),
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(context, 0, Icons.home_outlined, 'Home'),
              _buildNavItem(
                  context, 1, Icons.shopping_cart_outlined, 'Purchase'),
              _buildNavItem(context, 2, Icons.point_of_sale_outlined, 'Sales'),
              _buildNavItem(context, 3, Icons.settings_outlined, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, int index, IconData icon, String label) {
    final isSelected = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        splashColor: Colors.white.withValues(alpha: 0.2),
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10), // Reduced from 12
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color:
                    isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
                size: 20, // Reduced from 24
              ),
              const SizedBox(height: 4), // Reduced from 6
              Text(
                label,
                style: TextStyle(
                  color:
                      isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
                  fontSize: 10, // Reduced from 12
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
