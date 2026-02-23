// import 'package:flutter/material.dart';

// class DashboardCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final IconData icon;
//   final Color cardColor;
//   final Color textColor;

//   const DashboardCard({
//     super.key,
//     required this.title,
//     required this.value,
//     required this.icon,
//     required this.cardColor,
//     this.textColor = const Color(0xFF65636D),
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 180, // keep your original width
//       height: 100, // keep your original height
//       child: Container(
//         margin: const EdgeInsets.all(8.0), // keep same margin
//         padding: const EdgeInsets.all(12.0), // keep same padding
//         decoration: BoxDecoration(
//           color: cardColor,
//           borderRadius: BorderRadius.circular(12.0),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.3),
//               spreadRadius: 2,
//               blurRadius: 5,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start, // align left
//           children: [
//             // Top row: title + icon
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: textColor,
//                     ),
//                     overflow: TextOverflow.ellipsis, // prevent overflow
//                   ),
//                 ),
//                 Icon(icon, size: 20, color: textColor),
//               ],
//             ),
//             const SizedBox(height: 12),
//             // Value below
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: textColor,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// new code
import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final String iconPath; // ← changed from IconData
  final Color cardColor;
  final Color textColor;
  final String subtitle;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.iconPath, // e.g. 'assets/images/product_return.png'
    required this.cardColor,
    this.textColor = const Color(0xFF65636D),
    this.subtitle = 'Overview of the purchases,\nsales and returns',
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth / 2) - 8;

    return SizedBox(
      width: cardWidth,
      height: 160,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 3,
              blurRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                      color: textColor,
                    ),
                  ),
                ),
                // Replaced Icon(...) with Image.asset
                Image.asset(
                  iconPath,
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                  color: textColor.withOpacity(0.7), // optional tint
                  // colorBlendMode: BlendMode.srcIn,          // use if tint looks wrong
                ),
              ],
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 8,
                fontFamily: 'Inter',
                color: textColor.withOpacity(0.6),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
