// import 'package:flutter/material.dart';
// import 'package:saleup_app/screen/notification/view/notification_screen.dart';

// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final VoidCallback onMenuPressed;
//   final int notificationCount;
//   final VoidCallback? onNotificationTap;

//   const CustomAppBar({
//     super.key,
//     required this.onMenuPressed,
//     this.notificationCount = 3, // Updated to match the image (3 notifications)
//     this.onNotificationTap,
//   });

//   @override
//   Size get preferredSize =>
//       const Size.fromHeight(70); // Keep your app bar height

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Container(
//         padding: const EdgeInsets.symmetric(
//             horizontal: 16, vertical: 12), // Reverted to 16 pixels
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 2,
//               offset: const Offset(0, 1),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             IconButton(
//               icon: Icon(Icons.menu, color: Colors.grey[600], size: 24),
//               onPressed: onMenuPressed,
//             ),
//             Expanded(
//               child: Text(
//                 'Sales Shop',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 25,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.brown[700],
//                 ),
//               ),
//             ),
//             // Notification icon with badge
//             InkWell(
//               onTap: onNotificationTap ??
//                   () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const NotificationsScreen(),
//                       ),
//                     );
//                   },
//               child: Stack(
//                 children: [
//                   Icon(Icons.notifications_outlined,
//                       color: Colors.grey[600], size: 30),
//                   if (notificationCount > 0)
//                     Positioned(
//                       right: 0,
//                       top: 0,
//                       child: Container(
//                         padding: const EdgeInsets.all(2),
//                         decoration: BoxDecoration(
//                           color: Colors.orange[500],
//                           shape: BoxShape.circle,
//                         ),
//                         constraints: const BoxConstraints(
//                           minWidth: 16,
//                           minHeight: 16,
//                         ),
//                         child: Center(
//                           child: Text(
//                             notificationCount.toString(),
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:saleup_app/screen/notification/view/notification_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuPressed;
  final int notificationCount;
  final VoidCallback? onNotificationTap;

  const CustomAppBar({
    super.key,
    required this.onMenuPressed,
    this.notificationCount = 3,
    this.onNotificationTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(120);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      shadowColor: Colors.white,
      color: Colors.transparent, // ← USED HERE
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/custom_appbar.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 1,
              bottom: 50,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 26),
                  onPressed: onMenuPressed,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Expanded(
                  child: Center(
                    child: Image.asset(
                      'assets/images/sales_up_logo.png',
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onNotificationTap ??
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationsScreen(),
                          ),
                        );
                      },
                  child: Stack(
                    children: [
                      const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                      if (notificationCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.orange[500],
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Center(
                              child: Text(
                                notificationCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
