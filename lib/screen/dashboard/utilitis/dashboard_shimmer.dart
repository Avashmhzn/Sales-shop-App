import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cards shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Wrap(
              spacing: 8,
              runSpacing: 12,
              children: List.generate(5, (index) => _buildCardShimmer()),
            ),
          ),

          // Line separator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(height: 2, color: Colors.white),
          ),

          // Chart placeholders
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 180, height: 24, color: Colors.white),
                const SizedBox(height: 8),
                Container(width: 140, height: 16, color: Colors.white),
                const SizedBox(height: 24),

                // Bar chart placeholder
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 16),

                // Legend chips
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: List.generate(4, (i) => _buildChipShimmer()),
                ),

                const SizedBox(height: 32),

                // Pie chart placeholder
                Container(
                  height: 320,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardShimmer() {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 100, height: 28, color: Colors.white),
          const SizedBox(height: 12),
          Container(width: 100, height: 28, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildChipShimmer() {
    return Container(
      width: 110,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
