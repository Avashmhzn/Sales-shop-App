// File: lib/screen/categories/widget/category_card.dart

import 'package:flutter/material.dart';
import 'package:saleup_app/model/category_response.dart';

class CategoryCard extends StatelessWidget {
  final CategoryData category;
  final String? parentName;
  final bool isSelected;
  final ValueChanged<bool?> onSelect;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CategoryCard({
    super.key,
    required this.category,
    this.parentName,
    required this.isSelected,
    required this.onSelect,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  static const _orange = Color(0xFFE8891A);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFF8F0) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isSelected ? _orange.withOpacity(0.4) : const Color(0xFFEEEEEE),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row 1: Checkbox + Name + ID badge ──
            Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: isSelected,
                    onChanged: onSelect,
                    activeColor: _orange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    side:
                        const BorderSide(color: Color(0xFFCCCCCC), width: 1.5),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    category.name ?? 'Unnamed',
                    style: const TextStyle(
                      fontSize: 15,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Text(
                    'ID: ${category.id}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF555555),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Row 2: Chips ──
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (category.shortCode != null &&
                    category.shortCode!.isNotEmpty)
                  _Chip(
                    icon: Icons.tag,
                    label: category.shortCode!,
                    color: const Color(0xFF4A90D9),
                    bgColor: const Color(0xFFEBF4FF),
                  ),
                if (parentName != null)
                  _Chip(
                    icon: Icons.account_tree_outlined,
                    label: parentName!,
                    color: const Color(0xFF9B59B6),
                    bgColor: const Color(0xFFF3E5F5),
                  )
                else
                  _Chip(
                    icon: Icons.folder_outlined,
                    label: 'Top Level',
                    color: const Color(0xFF27AE60),
                    bgColor: const Color(0xFFE8F8F0),
                  ),
                _Chip(
                  icon: category.status
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  label: category.status ? 'Active' : 'Inactive',
                  color: category.status
                      ? const Color(0xFF27AE60)
                      : const Color(0xFFE74C3C),
                  bgColor: category.status
                      ? const Color(0xFFE8F8F0)
                      : const Color(0xFFFFF0F0),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Row 3: Description + Actions ──
            Row(
              children: [
                if (category.description != null &&
                    category.description!.trim().isNotEmpty)
                  Expanded(
                    child: Text(
                      category.description!.trim(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Inter',
                        color: Color(0xFF888888),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                else
                  const Spacer(),
                _ActionBtn(
                  icon: Icons.remove_red_eye_outlined,
                  onTap: onView,
                  bgColor: const Color(0xFFF5F5F5),
                  iconColor: const Color(0xFF888888),
                ),
                const SizedBox(width: 6),
                _ActionBtn(
                  icon: Icons.edit_outlined,
                  onTap: onEdit,
                  bgColor: const Color(0xFFF5F5F5),
                  iconColor: const Color(0xFF888888),
                ),
                const SizedBox(width: 6),
                _ActionBtn(
                  icon: Icons.delete_outline,
                  onTap: onDelete,
                  bgColor: const Color(0xFFFFF0F0),
                  iconColor: const Color(0xFFD9534F),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  const _Chip({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color bgColor;
  final Color iconColor;

  const _ActionBtn({
    required this.icon,
    required this.onTap,
    required this.bgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: iconColor),
      ),
    );
  }
}
