// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// class AppDrawer extends StatelessWidget {
//   final Function(int)
//       onNavigate; // Navigation callback (kept for compatibility)

//   const AppDrawer({super.key, required this.onNavigate});

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       backgroundColor: Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.only(top: 60),
//         child: Container(
//           width: 250,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Drawer Header with Title and Close Button
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "Sales Shop",
//                       style: TextStyle(
//                         fontSize: 25,
//                         fontWeight: FontWeight.w500,
//                         color: Color(0xFF623807),
//                       ),
//                     ),
//                     IconButton(
//                       icon: Container(
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           border: Border.all(color: Colors.black, width: 1.5),
//                         ),
//                         padding: EdgeInsets.all(4),
//                         child: Icon(Icons.close, color: Colors.black, size: 18),
//                       ),
//                       padding: EdgeInsets.zero,
//                       constraints: BoxConstraints(),
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 20),

//               // Drawer Items with Expandable Sub-Menu
//               DrawerItem(
//                 title: "Dashboard",
//                 icon: Icons.dashboard,
//                 onTap: () {
//                   print('Navigating to Dashboard (/home)');
//                   context.go('/home');
//                   Navigator.pop(context); // Close the drawer
//                 },
//               ),
//               // Setup with Expandable Sub-Menu
//               ExpandableDrawerItem(
//                 title: "Setup",
//                 icon: Icons.settings,
//                 subItems: const [
//                   'Account Heads',
//                   'Parties',
//                   'Locations',
//                   'Categories',
//                   'Products',
//                   'Units',
//                   'Expiry',
//                 ],
//                 onNavigate: onNavigate, // Kept for compatibility
//               ),
//               ExpandableDrawerItem(
//                 title: "Accounting",
//                 icon: Icons.dock_outlined,
//                 subItems: const [
//                   'Purchase',
//                   'Purchase Return',
//                   'Sales',
//                   'Sales Return',
//                   'Voucher',
//                   'Receipt',
//                   'Payment',
//                 ],
//                 onNavigate: onNavigate, // Kept for compatibility
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class DrawerItem extends StatelessWidget {
//   final String title;
//   final VoidCallback onTap;
//   final IconData? icon;

//   const DrawerItem({required this.title, required this.onTap, this.icon});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         InkWell(
//           onTap: onTap,
//           splashColor: Colors.blueAccent,
//           highlightColor: Colors.transparent,
//           child: Container(
//             width: double.infinity,
//             padding:
//                 const EdgeInsets.only(left: 24, right: 16, top: 14, bottom: 14),
//             child: Row(
//               children: [
//                 if (icon != null) Icon(icon, color: Colors.black87, size: 20),
//                 if (icon != null) SizedBox(width: 10),
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.normal,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         Divider(
//           height: 1,
//           thickness: 1,
//           color: Colors.grey.shade300,
//           indent: 16,
//           endIndent: 16,
//         ),
//       ],
//     );
//   }
// }

// class ExpandableDrawerItem extends StatefulWidget {
//   final String title;
//   final IconData? icon;
//   final List<String> subItems;
//   final Function(int) onNavigate;

//   const ExpandableDrawerItem({
//     required this.title,
//     this.icon,
//     required this.subItems,
//     required this.onNavigate,
//   });

//   @override
//   _ExpandableDrawerItemState createState() => _ExpandableDrawerItemState();
// }

// class _ExpandableDrawerItemState extends State<ExpandableDrawerItem> {
//   bool _isExpanded = false;

//   // Explicit mapping of sub-items to routes
//   static const Map<String, String> _subItemRouteMap = {
//     'Account Heads': '/account-heads',
//     'Parties': '/parties',
//     'Locations': '/locations',
//     'Categories': '/categories',
//     'Products': '/products',
//     'Units': '/units',
//     'Expiry': '/expiry',
//     'Purchase': '/purchase',
//     'Purchase Return': '/purchase-return',
//     'Sales': '/sales',
//     'Sales Return': '/sales-return',
//     'Voucher': '/voucher',
//     'Receipt': '/receipt',
//     'Payment': '/payment',
//   };

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         InkWell(
//           onTap: () {
//             setState(() {
//               _isExpanded = !_isExpanded;
//             });
//           },
//           splashColor: Colors.blueAccent,
//           highlightColor: Colors.transparent,
//           child: Container(
//             width: double.infinity,
//             padding:
//                 const EdgeInsets.only(left: 24, right: 16, top: 14, bottom: 14),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     if (widget.icon != null)
//                       Icon(widget.icon, color: Colors.black87, size: 20),
//                     if (widget.icon != null) SizedBox(width: 10),
//                     Text(
//                       widget.title,
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.normal,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Icon(
//                   _isExpanded ? Icons.expand_less : Icons.expand_more,
//                   color: Colors.black87,
//                   size: 20,
//                 ),
//               ],
//             ),
//           ),
//         ),
//         if (_isExpanded)
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: widget.subItems.map((subItem) {
//               return InkWell(
//                 onTap: () {
//                   final route = _subItemRouteMap[subItem];
//                   if (route != null) {
//                     print('Navigating to $subItem ($route)');
//                     context.go(route);
//                     Navigator.pop(context); // Close the drawer
//                   } else {
//                     print('No route found for sub-item: $subItem');
//                   }
//                 },
//                 child: Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.only(
//                       left: 48, right: 16, top: 10, bottom: 10),
//                   child: Text(
//                     subItem,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.normal,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         Divider(
//           height: 1,
//           thickness: 1,
//           color: Colors.grey.shade300,
//           indent: 16,
//           endIndent: 16,
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final Function(int) onNavigate;

  const AppDrawer({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 12), // Reduced from 16
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Shrink to fit content
              children: [
                // Drawer Header with Title and Close Button
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16), // Reduced padding
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Sales Shop",
                        style: TextStyle(
                          fontSize: 22, // Reduced from 25
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF623807),
                        ),
                      ),
                      IconButton(
                        icon: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.close,
                              color: Colors.black, size: 16), // Reduced size
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12), // Reduced from 20

                // Drawer Items with Expandable Sub-Menu
                DrawerItem(
                  title: "Dashboard",
                  icon: Icons.dashboard,
                  onTap: () {
                    print('Navigating to Dashboard (/home)');
                    onNavigate(0);
                    Navigator.pop(context);
                  },
                ),
                ExpandableDrawerItem(
                  title: "Setup",
                  icon: Icons.settings,
                  subItems: const [
                    'Account Heads', // index 4
                    'Parties', // index 5
                    'Locations', // index 6
                    'Categories', // index 7
                    'Products', // index 8
                    'Units', // index 9
                    'Expiry', // index 10
                  ],
                  onNavigate: (index) => onNavigate(index + 4),
                ),
                ExpandableDrawerItem(
                  title: "Accounting",
                  icon: Icons.dock_outlined,
                  subItems: const [
                    'Purchase', // index 1
                    'Purchase Return', // index 11
                    'Sales', // index 2
                    'Sales Return', // index 12
                    'Voucher', // index 13
                    'Receipt', // index 14
                    'Payment', // index 15
                  ],
                  onNavigate: (index) {
                    final indices = [1, 11, 2, 12, 13, 14, 15];
                    onNavigate(indices[index]);
                  },
                ),
                ExpandableDrawerItem(
                  title: "Reports",
                  icon: Icons.settings,
                  subItems: const [
                    'Ledger Report', // index 17
                  ],
                  onNavigate: (index) {
                    final indices = [17];
                    onNavigate(indices[index]);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final IconData? icon;

  const DrawerItem(
      {required this.title, required this.onTap, this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          splashColor: Colors.blueAccent,
          highlightColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10), // Reduced vertical padding
            child: Row(
              children: [
                if (icon != null)
                  Icon(icon, color: Colors.black87, size: 18), // Reduced size
                if (icon != null) const SizedBox(width: 8), // Reduced spacing
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14, // Reduced from 16
                    fontWeight: FontWeight.normal,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey.shade300,
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }
}

class ExpandableDrawerItem extends StatefulWidget {
  final String title;
  final IconData? icon;
  final List<String> subItems;
  final Function(int) onNavigate;

  const ExpandableDrawerItem({
    required this.title,
    this.icon,
    required this.subItems,
    required this.onNavigate,
    super.key,
  });

  @override
  _ExpandableDrawerItemState createState() => _ExpandableDrawerItemState();
}

class _ExpandableDrawerItemState extends State<ExpandableDrawerItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Shrink to fit content
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          splashColor: Colors.blueAccent,
          highlightColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10), // Reduced vertical padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (widget.icon != null)
                      Icon(widget.icon,
                          color: Colors.black87, size: 18), // Reduced size
                    if (widget.icon != null) const SizedBox(width: 8),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 14, // Reduced from 16
                        fontWeight: FontWeight.normal,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.black87,
                  size: 18, // Reduced size
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(widget.subItems.length, (index) {
              return InkWell(
                onTap: () {
                  print(
                      'Navigating to ${widget.subItems[index]} (index: $index)');
                  widget.onNavigate(index);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                      left: 48,
                      right: 16,
                      top: 8,
                      bottom: 8), // Reduced padding
                  child: Text(
                    widget.subItems[index],
                    style: const TextStyle(
                      fontSize: 14, // Reduced from 16
                      fontWeight: FontWeight.normal,
                      color: Colors.black87,
                    ),
                  ),
                ),
              );
            }),
          ),
        Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey.shade300,
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }
}
