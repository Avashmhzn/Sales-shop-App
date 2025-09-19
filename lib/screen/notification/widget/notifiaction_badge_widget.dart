import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  final int count;
  final Function() onTap;
  final double iconSize;
  final double badgeSize;
  final Color? badgeColor; // Made optional with nullable type
  final Color? iconColor;  // Made optional with nullable type

  const NotificationBadge({
    super.key,
    required this.count,
    required this.onTap,
    this.iconSize = 30,
    this.badgeSize = 16,
    this.badgeColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Icon(
              Icons.notifications_outlined,
              color: iconColor ?? Colors.grey[600],
              size: iconSize
          ),
          if (count > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: badgeColor ?? Colors.orange[500],
                  shape: BoxShape.circle,
                ),
                constraints: BoxConstraints(
                  minWidth: badgeSize,
                  minHeight: badgeSize,
                ),
                child: Center(
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: badgeSize * 0.625,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}