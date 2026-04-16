// import 'package:flutter/material.dart';
// import 'package:saleup_app/model/account_heads_response.dart';
// import 'package:saleup_app/screen/accountHead/view/account_head_details.dart';

// class AccountHeadCard extends StatelessWidget {
//   final AccountHeadData head;
//   final double screenWidth;
//   final double screenHeight;

//   const AccountHeadCard({
//     super.key,
//     required this.head,
//     required this.screenWidth,
//     required this.screenHeight,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         showDialog(
//           context: context,
//           builder: (context) => GestureDetector(
//             behavior: HitTestBehavior.opaque,
//             onTap: () {},
//             child: AlertDialog(
//               insetPadding: EdgeInsets.symmetric(
//                 horizontal: screenWidth * 0.03,
//                 vertical: screenHeight * 0.1,
//               ),
//               title: Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () => Navigator.pop(context),
//                     color: Colors.grey[600],
//                   ),
//                 ],
//               ),
//               content: SizedBox(
//                 width: screenWidth * 0.9,
//                 child: AccountHeadDetails(accountHeadId: head.id),
//               ),
//               actions: const [],
//             ),
//           ),
//         );
//       },
//       child: Padding(
//         padding: const EdgeInsets.only(left: 10.0, right: 10.0),
//         child: Container(
//           margin: const EdgeInsets.only(bottom: 12),
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 6,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: Text(
//                       head.name,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                         color: Colors.black,
//                       ),
//                       softWrap: true,
//                     ),
//                   ),
//                   Expanded(
//                     child: Text(
//                       'ID: ${head.id}',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                         color: Colors.black,
//                       ),
//                       textAlign: TextAlign.end,
//                       softWrap: true,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: Text(
//                       head.parent ?? 'N/A',
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey,
//                       ),
//                       softWrap: true,
//                     ),
//                   ),
//                   Expanded(
//                     child: Text(
//                       head.mainGroup ?? 'N/A',
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey,
//                       ),
//                       textAlign: TextAlign.end,
//                       softWrap: true,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: Text(
//                       head.openingBalance != null
//                           ? 'Rs ${head.openingBalance!.toStringAsFixed(2)}'
//                           : 'Rs 0.00',
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey,
//                       ),
//                       softWrap: true,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:saleup_app/model/account_heads_response.dart';

class AccountHeadCard extends StatelessWidget {
  final AccountHeadData head;
  final bool isSelected;
  final void Function(bool?) onSelect;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static const _orange = Color(0xFFE8891A);

  const AccountHeadCard({
    super.key,
    required this.head,
    required this.isSelected,
    required this.onSelect,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFF8EE) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              isSelected ? _orange.withOpacity(0.5) : const Color(0xFFEEEEEE),
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Checkbox (top-left, no overlap) ──
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: isSelected,
                onChanged: onSelect,
                activeColor: _orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: const BorderSide(color: Color(0xFFCCCCCC), width: 1.5),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 12),

            // ── Main content ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top row: Name + ID badge ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          head.name ?? 'Unnamed Account',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                            color: Color(0xFF1A1A1A),
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: Text(
                          'ID: ${head.id}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                            color: Color(0xFF555555),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ── Info chips row ──
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _InfoChip(
                        icon: Icons.account_tree_outlined,
                        label: head.parent ?? 'N/A',
                        color: const Color(0xFF5B8DEF),
                      ),
                      _InfoChip(
                        icon: Icons.category_outlined,
                        label: head.mainGroup ?? 'N/A',
                        color: const Color(0xFF9C6FDE),
                      ),
                      if (head.accountType != null)
                        _InfoChip(
                          icon: Icons.label_outline,
                          label: head.accountType!,
                          color: const Color(0xFF2BAE8E),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ── Bottom row: Balance + Actions ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Balance
                      Row(
                        children: [
                          const Icon(Icons.account_balance_wallet_outlined,
                              size: 14, color: Color(0xFF888888)),
                          const SizedBox(width: 4),
                          Text(
                            'Rs ${head.openingBalance?.toStringAsFixed(2) ?? '0.00'}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                              color: Color(0xFF333333),
                            ),
                          ),
                          if (head.drCr != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: head.drCr == 'Debit'
                                    ? const Color(0xFFFFEEEE)
                                    : const Color(0xFFEEF7EE),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                head.drCr!,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                  color: head.drCr == 'Debit'
                                      ? const Color(0xFFD9534F)
                                      : const Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Action buttons
                      Row(
                        children: [
                          _ActionBtn(
                            icon: Icons.remove_red_eye_outlined,
                            onTap: onView,
                          ),
                          const SizedBox(width: 4),
                          _ActionBtn(
                            icon: Icons.edit_outlined,
                            onTap: onEdit,
                          ),
                          const SizedBox(width: 4),
                          _ActionBtn(
                            icon: Icons.delete_outline,
                            onTap: onDelete,
                            isDestructive: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
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
  final bool isDestructive;

  const _ActionBtn({
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color:
              isDestructive ? const Color(0xFFFFEEEE) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDestructive
                ? const Color(0xFFFFCCCC)
                : const Color(0xFFE8E8E8),
          ),
        ),
        child: Icon(
          icon,
          size: 15,
          color:
              isDestructive ? const Color(0xFFD9534F) : const Color(0xFF666666),
        ),
      ),
    );
  }
}
