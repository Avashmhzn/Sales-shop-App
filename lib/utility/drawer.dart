// import 'package:flutter/material.dart';

// class AppDrawer extends StatelessWidget {
//   final Function(int) onNavigate;

//   const AppDrawer({super.key, required this.onNavigate});

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       backgroundColor: Colors.white,
//       child: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.only(top: 12), // Reduced from 16
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min, // Shrink to fit content
//               children: [
//                 // Drawer Header with Title and Close Button
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 16), // Reduced padding
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         "Sales Shop",
//                         style: TextStyle(
//                           fontSize: 22, // Reduced from 25
//                           fontWeight: FontWeight.w500,
//                           color: Color(0xFF623807),
//                         ),
//                       ),
//                       IconButton(
//                         icon: Container(
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             border: Border.all(color: Colors.black, width: 1.5),
//                           ),
//                           padding: const EdgeInsets.all(4),
//                           child: const Icon(Icons.close,
//                               color: Colors.black, size: 16), // Reduced size
//                         ),
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(),
//                         onPressed: () => Navigator.pop(context),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 12), // Reduced from 20

//                 // Drawer Items with Expandable Sub-Menu
//                 DrawerItem(
//                   title: "Dashboard",
//                   icon: Icons.dashboard,
//                   onTap: () {
//                     print('Navigating to Dashboard (/home)');
//                     onNavigate(0);
//                     Navigator.pop(context);
//                   },
//                 ),
//                 ExpandableDrawerItem(
//                   title: "Setup",
//                   icon: Icons.settings,
//                   subItems: const [
//                     'Account Heads', // index 4
//                     'Parties', // index 5
//                     'Locations', // index 6
//                     'Categories', // index 7
//                     'Products', // index 8
//                     'Units', // index 9
//                     'Expiry', // index 10
//                   ],
//                   onNavigate: (index) => onNavigate(index + 4),
//                 ),
//                 ExpandableDrawerItem(
//                   title: "Accounting",
//                   icon: Icons.dock_outlined,
//                   subItems: const [
//                     'Purchase', // index 1
//                     'Purchase Return', // index 11
//                     'Sales', // index 2
//                     'Sales Return', // index 12
//                     'Voucher', // index 13
//                     'Receipt', // index 14
//                     'Payment', // index 15
//                   ],
//                   onNavigate: (index) {
//                     final indices = [1, 11, 2, 12, 13, 14, 15];
//                     onNavigate(indices[index]);
//                   },
//                 ),

//               ],
//             ),
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

//   const DrawerItem(
//       {required this.title, required this.onTap, this.icon, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         InkWell(
//           onTap: onTap,
//           splashColor: Colors.blueAccent,
//           highlightColor: Colors.transparent,
//           child: Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(
//                 horizontal: 16, vertical: 10), // Reduced vertical padding
//             child: Row(
//               children: [
//                 if (icon != null)
//                   Icon(icon, color: Colors.black87, size: 18), // Reduced size
//                 if (icon != null) const SizedBox(width: 8), // Reduced spacing
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 14, // Reduced from 16
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
//     super.key,
//   });

//   @override
//   _ExpandableDrawerItemState createState() => _ExpandableDrawerItemState();
// }

// class _ExpandableDrawerItemState extends State<ExpandableDrawerItem> {
//   bool _isExpanded = false;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min, // Shrink to fit content
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         InkWell(
//           onTap: () => setState(() => _isExpanded = !_isExpanded),
//           splashColor: Colors.blueAccent,
//           highlightColor: Colors.transparent,
//           child: Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(
//                 horizontal: 16, vertical: 10), // Reduced vertical padding
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     if (widget.icon != null)
//                       Icon(widget.icon,
//                           color: Colors.black87, size: 18), // Reduced size
//                     if (widget.icon != null) const SizedBox(width: 8),
//                     Text(
//                       widget.title,
//                       style: const TextStyle(
//                         fontSize: 14, // Reduced from 16
//                         fontWeight: FontWeight.normal,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Icon(
//                   _isExpanded ? Icons.expand_less : Icons.expand_more,
//                   color: Colors.black87,
//                   size: 18, // Reduced size
//                 ),
//               ],
//             ),
//           ),
//         ),
//         if (_isExpanded)
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: List.generate(widget.subItems.length, (index) {
//               return InkWell(
//                 onTap: () {
//                   print(
//                       'Navigating to ${widget.subItems[index]} (index: $index)');
//                   widget.onNavigate(index);
//                   Navigator.pop(context);
//                 },
//                 child: Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.only(
//                       left: 48,
//                       right: 16,
//                       top: 8,
//                       bottom: 8), // Reduced padding
//                   child: Text(
//                     widget.subItems[index],
//                     style: const TextStyle(
//                       fontSize: 14, // Reduced from 16
//                       fontWeight: FontWeight.normal,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ),
//               );
//             }),
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
                    'Sales', // index 2
                    'Sales Return', // index 12
                    'Purchase', // index 1
                    'Purchase Return', // index 11
                  ],
                  onNavigate: (index) {
                    final indices = [2, 12, 1, 11];
                    onNavigate(indices[index]);
                  },
                ),
                ExpandableDrawerItem(
                  title: "Reports",
                  icon: Icons.settings,
                  subItems: [
                    ExpandableDrawerItem(
                      title: "Transaction Reports",
                      icon: Icons.list_alt,
                      subItems: const [
                        'Voucher', // index 13
                        'Receipt', // index 14
                        'Payment', // index 15
                        'Day Closing', // index 17
                        "Product Report", // index 18
                      ],
                      onNavigate: (index) {
                        final indices = [13, 14, 15, 17, 18];
                        onNavigate(indices[index]);
                      },
                    ),
                    ExpandableDrawerItem(
                      title: "Accounting Reports",
                      icon: Icons.account_balance,
                      subItems: const [
                        "Ledger Report", // index 19
                        "Stock-Ledger", // index 20
                        "Trial Balance", // index 21
                        "Balance Sheet",
                        "Profit & Loss",
                        "Log Summary",
                      ],
                      onNavigate: (index) {
                        final indices = [19, 20, 21];
                        onNavigate(indices[index]);
                      },
                    ),
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
  final List<dynamic> subItems; // ✅ FIXED HERE (was List<String>)
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
              final item = widget.subItems[index];
              if (item is ExpandableDrawerItem) {
                // ✅ support nested ExpandableDrawerItems
                return Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: item,
                );
              }
              // fallback: normal string item
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
                    widget.subItems[index].toString(),
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
