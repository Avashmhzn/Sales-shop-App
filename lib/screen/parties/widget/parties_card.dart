// File: lib/screen/parties/widgets/party_card.dart

import 'package:flutter/material.dart';
import 'package:saleup_app/model/party_response.dart';

class PartyCard extends StatelessWidget {
  final PartyData party;
  final bool isSelected;
  final ValueChanged<bool?> onSelect;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PartyCard({
    super.key,
    required this.party,
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
              isSelected ? _orange.withValues(alpha: 0.4) : const Color(0xFFEEEEEE),
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
                    party.name,
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
                    'ID: ${party.id}',
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

            // ── Row 2: Type + Account Type chips ──
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (party.type != null)
                  _TypeChip(
                    icon: Icons.people_alt_outlined,
                    label: party.type!,
                    color: const Color(0xFF4A90D9),
                    bgColor: const Color(0xFFEBF4FF),
                  ),
                if (party.accType != null)
                  _TypeChip(
                    icon: Icons.account_tree_outlined,
                    label: party.accType!,
                    color: const Color(0xFF9B59B6),
                    bgColor: const Color(0xFFF3E5F5),
                  ),
                if (party.phone != null)
                  _TypeChip(
                    icon: Icons.phone_outlined,
                    label: party.phone!,
                    color: const Color(0xFF27AE60),
                    bgColor: const Color(0xFFE8F8F0),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Row 3: Balance + Status + Actions ──
            Row(
              children: [
                // Balance
                const Icon(Icons.account_balance_wallet_outlined,
                    size: 14, color: Color(0xFF888888)),
                const SizedBox(width: 4),
                Text(
                  'Rs ${(party.openingBalance ?? 0.0).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(width: 8),
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (party.status == true)
                        ? const Color(0xFFE8F8F0)
                        : const Color(0xFFFFF0F0),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (party.status == true)
                          ? const Color(0xFF27AE60)
                          : const Color(0xFFE74C3C),
                    ),
                  ),
                  child: Text(
                    (party.status == true) ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      color: (party.status == true)
                          ? const Color(0xFF27AE60)
                          : const Color(0xFFE74C3C),
                    ),
                  ),
                ),
                const Spacer(),
                // Action buttons
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

// ─── Type Chip ────────────────────────────────────────────────────────────────

class _TypeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  const _TypeChip({
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
        border: Border.all(color: color.withValues(alpha: 0.25)),
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

// ─── Action Button ────────────────────────────────────────────────────────────

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
