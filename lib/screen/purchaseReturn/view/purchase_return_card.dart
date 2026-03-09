import 'package:flutter/material.dart';
import 'package:saleup_app/screen/purchaseReturn/model/purchase_return.dart';

class PurchaseReturnCard extends StatelessWidget {
  final PurchaseReturn purchaseReturn;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PurchaseReturnCard({
    super.key,
    required this.purchaseReturn,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final desc = [
      purchaseReturn.invoiceNumber ?? '',
      purchaseReturn.reason ?? '',
    ].where((s) => s.isNotEmpty).join(' • ');

    return GestureDetector(
      onTap: () {
        // Optional: open detail screen
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        purchaseReturn.partyName ?? 'Unknown Party',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        desc.isNotEmpty ? desc : 'No details available',
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _circleIcon(
                      'assets/images/edit.png',
                      const Color(0xFF4CAF50),
                      onEdit,
                      'Edit',
                    ),
                    const SizedBox(width: 12),
                    _circleIcon(
                      'assets/images/delete.png',
                      const Color(0xFFE53935),
                      onDelete,
                      'Delete',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text('Amount',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(
              'NPR ${purchaseReturn.total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleIcon(
      String asset, Color bgColor, VoidCallback onTap, String label) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
            child: Image.asset(asset, width: 13, height: 13),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: bgColor, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
