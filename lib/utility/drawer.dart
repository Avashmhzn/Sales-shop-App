// import 'package:flutter/material.dart';

// class AppDrawer extends StatelessWidget {
//   final Function(int) onNavigate;
//   final int currentIndex;

//   const AppDrawer({
//     super.key,
//     required this.onNavigate,
//     required this.currentIndex,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       backgroundColor: Colors.white,
//       child: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // ─── New Header using only your assets ───────────────────────────────
//               Stack(
//                 children: [
//                   SizedBox(
//                     height: 200,
//                     width: double.infinity,
//                     child: Image.asset(
//                       'assets/images/drawer_header.png',
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 60, vertical: 30),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Image.asset(
//                           'assets/images/sales_up_logo.png',
//                           height: 60,
//                           fit: BoxFit.contain,
//                         ),
//                         const SizedBox(height: 8),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 8),

//               DrawerItem(
//                 title: "Dashboard",
//                 assetPath: 'assets/images/dashboard.png',
//                 isActive: currentIndex == 0,
//                 onTap: () {
//                   print('Navigating to Dashboard (/home)');
//                   onNavigate(0);
//                   Navigator.pop(context);
//                 },
//               ),

//               ExpandableDrawerItem(
//                 title: "Setup",
//                 assetPath: 'assets/images/settings.png',
//                 subItems: const [
//                   'Account Heads', // index 4
//                   'Parties', // index 5
//                   'Locations', // index 6
//                   'Categories', // index 7
//                   'Products', // index 8
//                   'Units', // index 9
//                   'Expiry', // index 10
//                   'Settings', // ← NEW line (will map to index 27)
//                 ],
//                 onNavigate: (index) {
//                   const indices = [4, 5, 6, 7, 8, 9, 10, 27];
//                   onNavigate(indices[index]);
//                 },
//                 currentIndex: currentIndex,
//               ),

//               ExpandableDrawerItem(
//                 title: "Daily Transation",
//                 assetPath: 'assets/images/transaction-history.png',
//                 subItems: const [
//                   'Sales', // index 2
//                   'Sales Return', // index 12
//                   'Purchase', // index 1
//                   'Purchase Return', // index 11
//                 ],
//                 onNavigate: (index) {
//                   final indices = [2, 12, 1, 11];
//                   onNavigate(indices[index]);
//                 },
//                 currentIndex: currentIndex,
//               ),

//               ExpandableDrawerItem(
//                 title: "Receivable",
//                 assetPath: 'assets/images/receivable.png',
//                 subItems: const [
//                   'Khata',
//                   'Create Khata',
//                 ],
//                 onNavigate: (index) {
//                   // TODO: replace with real indices when you add those screens
//                   final indices = [22, 23]; // ← change these numbers later
//                   onNavigate(indices[index]);
//                 },
//                 currentIndex: currentIndex,
//               ),

//               ExpandableDrawerItem(
//                 title: "Reports",
//                 assetPath: 'assets/images/report.png',
//                 subItems: [
//                   ExpandableDrawerItem(
//                     title: "Transaction Reports",
//                     assetPath: 'assets/images/transactional-data.png',
//                     subItems: const [
//                       'Voucher', // index 13
//                       'Receipt', // index 14
//                       'Payment', // index 15
//                       'Day Closing', // index 17
//                       "Product Report", // index 18
//                     ],
//                     onNavigate: (index) {
//                       final indices = [13, 14, 15, 17, 18];
//                       onNavigate(indices[index]);
//                     },
//                     currentIndex: currentIndex,
//                   ),
//                   ExpandableDrawerItem(
//                     title: "Accounting Reports",
//                     assetPath: 'assets/images/accounting.png',
//                     subItems: const [
//                       "Ledger Report", // index 19
//                       "Stock-Ledger", // index 20
//                       "Trial Balance", // index 21
//                       "Balance Sheet",
//                       "Profit & Loss",
//                       "Log Summary",
//                     ],
//                     onNavigate: (index) {
//                       final indices = [
//                         19,
//                         20,
//                         21,
//                         24,
//                         25,
//                         26
//                       ]; // ← extend when you add routes
//                       onNavigate(indices[index]);
//                     },
//                     currentIndex: currentIndex,
//                   ),
//                 ],
//                 onNavigate: (index) {
//                   final indices = [17];
//                   onNavigate(indices[index]);
//                 },
//                 currentIndex: currentIndex,
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
//   final String? assetPath;
//   final IconData? icon;
//   final bool isActive;

//   const DrawerItem({
//     required this.title,
//     required this.onTap,
//     this.assetPath,
//     this.icon,
//     required this.isActive,
//     super.key,
//   }) : assert(
//           assetPath == null || icon == null,
//           'Provide either assetPath or icon, not both',
//         );

//   @override
//   Widget build(BuildContext context) {
//     final color = isActive ? const Color(0xFFFFA133) : const Color(0xFF464E57);
//     final fontWeight = isActive ? FontWeight.w600 : FontWeight.normal;

//     Widget iconWidget;

//     if (assetPath != null) {
//       iconWidget = Image.asset(
//         assetPath!,
//         width: 24,
//         height: 24,
//         fit: BoxFit.contain,
//         color: color, // ← changed: now uses active color
//         errorBuilder: (context, error, stackTrace) => const Icon(
//           Icons.error_outline,
//           size: 24,
//         ),
//       );
//     } else if (icon != null) {
//       iconWidget = Icon(
//         icon,
//         size: 24,
//         color: color,
//       );
//     } else {
//       iconWidget = const SizedBox(width: 24);
//     }

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         InkWell(
//           onTap: onTap,
//           splashColor: Colors.blueAccent,
//           highlightColor: Colors.transparent,
//           child: Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             child: Row(
//               children: [
//                 iconWidget,
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontFamily: 'Inter',
//                       fontWeight: fontWeight, // ← changed
//                       color: color, // ← changed
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const Divider(
//           height: 1,
//           thickness: 1,
//           color: Colors.transparent,
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
//   final String? assetPath;
//   final List<dynamic> subItems;
//   final Function(int) onNavigate;
//   final int currentIndex;

//   const ExpandableDrawerItem({
//     required this.title,
//     this.icon,
//     this.assetPath,
//     required this.subItems,
//     required this.onNavigate,
//     required this.currentIndex,
//     super.key,
//   });

//   @override
//   _ExpandableDrawerItemState createState() => _ExpandableDrawerItemState();
// }

// class _ExpandableDrawerItemState extends State<ExpandableDrawerItem> {
//   bool _isExpanded = false;

//   @override
//   Widget build(BuildContext context) {
//     // Check if this section has active child → color parent orange too
//     bool sectionActive = false;
//     for (var i = 0; i < widget.subItems.length; i++) {
//       final globalIdx = _getGlobalIndex(i);
//       if (globalIdx != null && widget.currentIndex == globalIdx) {
//         sectionActive = true;
//         break;
//       }
//     }

//     final headerColor =
//         sectionActive ? const Color(0xFFFFA133) : const Color(0xFF464E57);

//     Widget iconWidget;

//     if (widget.assetPath != null) {
//       iconWidget = Image.asset(
//         widget.assetPath!,
//         width: 24,
//         height: 24,
//         fit: BoxFit.contain,
//         color: headerColor,
//         errorBuilder: (context, error, stackTrace) => const Icon(
//           Icons.error_outline,
//           size: 24,
//         ),
//       );
//     } else if (widget.icon != null) {
//       iconWidget = Icon(
//         widget.icon,
//         size: 24,
//         color: headerColor,
//       );
//     } else {
//       iconWidget = const SizedBox(width: 24);
//     }

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         InkWell(
//           onTap: () => setState(() => _isExpanded = !_isExpanded),
//           splashColor: Colors.blueAccent,
//           highlightColor: Colors.transparent,
//           child: Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     iconWidget,
//                     const SizedBox(width: 16),
//                     Text(
//                       widget.title,
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontFamily: 'Inter',
//                         fontWeight: FontWeight.normal,
//                         color: headerColor,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Icon(
//                   _isExpanded ? Icons.expand_less : Icons.expand_more,
//                   color: const Color(0xFF687582),
//                   size: 18,
//                 ),
//               ],
//             ),
//           ),
//         ),
//         if (_isExpanded)
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: List.generate(widget.subItems.length, (index) {
//               final item = widget.subItems[index];
//               if (item is ExpandableDrawerItem) {
//                 return Padding(
//                   padding: const EdgeInsets.only(left: 16),
//                   child: item,
//                 );
//               }

//               final subTitle = item.toString();
//               final globalIndex = _getGlobalIndex(index);
//               final isActive =
//                   globalIndex != null && widget.currentIndex == globalIndex;

//               final subColor =
//                   isActive ? const Color(0xFFFFA133) : const Color(0xFF687582);

//               return InkWell(
//                 onTap: () {
//                   print('Navigating to $subTitle (index: $index)');
//                   widget.onNavigate(index);
//                   Navigator.pop(context);
//                 },
//                 child: Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.only(
//                       left: 55, right: 16, top: 8, bottom: 8),
//                   child: Text(
//                     subTitle,
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontFamily: 'Inter',
//                       fontWeight:
//                           isActive ? FontWeight.w600 : FontWeight.normal,
//                       color: subColor,
//                     ),
//                   ),
//                 ),
//               );
//             }),
//           ),
//         const Divider(
//           height: 1,
//           thickness: 1,
//           color: Colors.transparent,
//           indent: 16,
//           endIndent: 16,
//         ),
//       ],
//     );
//   }

//   int? _getGlobalIndex(int subIndex) {
//     switch (widget.title) {
//       case 'Setup':
//         const setupIndices = [4, 5, 6, 7, 8, 9, 10, 27]; // ← Settings = 27
//         return subIndex < setupIndices.length ? setupIndices[subIndex] : null;

//       case 'Daily Transation':
//         const indices = [2, 12, 1, 11];
//         return subIndex < indices.length ? indices[subIndex] : null;

//       case 'Receivable':
//         const indices = [22, 23]; // ← replace with your real indices
//         return subIndex < indices.length ? indices[subIndex] : null;

//       case 'Transaction Reports':
//         const indices = [13, 14, 15, 17, 18];
//         return subIndex < indices.length ? indices[subIndex] : null;

//       case 'Accounting Reports':
//         const indices = [19, 20, 21, 24, 25, 26]; // ← extend when needed
//         return subIndex < indices.length ? indices[subIndex] : null;

//       default:
//         return null;
//     }
//   }
// }
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final Function(int) onNavigate;
  final int currentIndex;

  const AppDrawer({
    super.key,
    required this.onNavigate,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Stack(
                children: [
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Image.asset(
                      'assets/images/drawer_header.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/images/sales_up_logo.png',
                          height: 60,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              DrawerItem(
                title: "Dashboard",
                assetPath: 'assets/images/dashboard.png',
                isActive: currentIndex == 0,
                onTap: () {
                  onNavigate(0);
                  Navigator.pop(context);
                },
              ),

              ExpandableDrawerItem(
                title: "Setup",
                assetPath: 'assets/images/settings.png',
                subItems: const [
                  'Account Heads',
                  'Parties',
                  'Locations',
                  'Categories',
                  'Products',
                  'Units',
                  'Expiry',
                  'Settings',
                ],
                onNavigate: (index) {
                  const indices = [4, 5, 6, 7, 8, 9, 10, 27];
                  onNavigate(indices[index]);
                },
                currentIndex: currentIndex,
              ),

              ExpandableDrawerItem(
                title: "Daily Transation",
                assetPath: 'assets/images/transaction-history.png',
                subItems: const [
                  'Sales',
                  'Sales Return',
                  'Purchase',
                  'Purchase Return'
                ],
                onNavigate: (index) {
                  const indices = [2, 12, 1, 11];
                  onNavigate(indices[index]);
                },
                currentIndex: currentIndex,
              ),

              ExpandableDrawerItem(
                title: "Receivable",
                assetPath: 'assets/images/receivable.png',
                subItems: const ['Khata', 'Create Khata'],
                onNavigate: (index) {
                  const indices = [22, 23];
                  onNavigate(indices[index]);
                },
                currentIndex: currentIndex,
              ),

              ExpandableDrawerItem(
                title: "Reports",
                assetPath: 'assets/images/report.png',
                subItems: [
                  ExpandableDrawerItem(
                    title: "Transaction Reports",
                    assetPath: 'assets/images/transactional-data.png',
                    subItems: const [
                      'Voucher',
                      'Receipt',
                      'Payment',
                      'Day Closing',
                      "Product Report"
                    ],
                    onNavigate: (index) {
                      const indices = [13, 14, 15, 17, 18];
                      onNavigate(indices[index]);
                    },
                    currentIndex: currentIndex,
                  ),
                  ExpandableDrawerItem(
                    title: "Accounting Reports",
                    assetPath: 'assets/images/accounting.png',
                    subItems: const [
                      "Ledger Report",
                      "Stock-Ledger",
                      "Trial Balance",
                      "Balance Sheet",
                      "Profit & Loss",
                      "Log Summary",
                    ],
                    onNavigate: (index) {
                      const indices = [19, 20, 21, 24, 25, 26];
                      onNavigate(indices[index]);
                    },
                    currentIndex: currentIndex,
                  ),
                ],
                onNavigate: (index) => onNavigate(17),
                currentIndex: currentIndex,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== DrawerItem (unchanged) ====================
class DrawerItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final String? assetPath;
  final bool isActive;

  const DrawerItem({
    required this.title,
    required this.onTap,
    this.assetPath,
    required this.isActive,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFFFFA133) : const Color(0xFF464E57);
    final fontWeight = isActive ? FontWeight.w600 : FontWeight.normal;

    final iconWidget = assetPath != null
        ? Image.asset(
            assetPath!,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
            color: color,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.error_outline, size: 24),
          )
        : const SizedBox(width: 24);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                iconWidget,
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: fontWeight,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(
            height: 1,
            thickness: 1,
            color: Colors.transparent,
            indent: 16,
            endIndent: 16),
      ],
    );
  }
}

// ==================== ExpandableDrawerItem - ONLY THIS PART IS FIXED ====================
class ExpandableDrawerItem extends StatefulWidget {
  final String title;
  final String? assetPath;
  final List<dynamic> subItems;
  final Function(int) onNavigate;
  final int currentIndex;

  const ExpandableDrawerItem({
    required this.title,
    this.assetPath,
    required this.subItems,
    required this.onNavigate,
    required this.currentIndex,
    super.key,
  });

  @override
  State<ExpandableDrawerItem> createState() => _ExpandableDrawerItemState();
}

class _ExpandableDrawerItemState extends State<ExpandableDrawerItem> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = _shouldBeExpanded();
  }

  @override
  void didUpdateWidget(covariant ExpandableDrawerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      setState(() {
        _isExpanded = _shouldBeExpanded();
      });
    }
  }

  bool _shouldBeExpanded() {
    for (int i = 0; i < widget.subItems.length; i++) {
      final globalIdx = _getGlobalIndex(i);
      if (globalIdx != null && widget.currentIndex == globalIdx) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final bool sectionActive = _shouldBeExpanded();

    final headerColor =
        sectionActive ? const Color(0xFFFFA133) : const Color(0xFF464E57);

    final iconWidget = widget.assetPath != null
        ? Image.asset(
            widget.assetPath!,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
            color: headerColor,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.error_outline, size: 24),
          )
        : const SizedBox(width: 24);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    iconWidget,
                    const SizedBox(width: 16),
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Inter',
                        color: headerColor,
                      ),
                    ),
                  ],
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: const Color(0xFF687582),
                  size: 18,
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
                return Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: item,
                );
              }

              final subTitle = item.toString();
              final globalIndex = _getGlobalIndex(index);
              final isActive =
                  globalIndex != null && widget.currentIndex == globalIndex;

              final subColor =
                  isActive ? const Color(0xFFFFA133) : const Color(0xFF687582);

              return InkWell(
                onTap: () {
                  widget.onNavigate(index);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                      left: 55, right: 16, top: 8, bottom: 8),
                  child: Text(
                    subTitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                      color: subColor,
                    ),
                  ),
                ),
              );
            }),
          ),
        const Divider(
          height: 1,
          thickness: 1,
          color: Colors.transparent,
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }

  int? _getGlobalIndex(int subIndex) {
    switch (widget.title) {
      case 'Setup':
        const indices = [4, 5, 6, 7, 8, 9, 10, 27];
        return subIndex < indices.length ? indices[subIndex] : null;

      case 'Daily Transation':
        const indices = [2, 12, 1, 11];
        return subIndex < indices.length ? indices[subIndex] : null;

      case 'Receivable':
        const indices = [22, 23];
        return subIndex < indices.length ? indices[subIndex] : null;

      case 'Transaction Reports':
        const indices = [13, 14, 15, 17, 18];
        return subIndex < indices.length ? indices[subIndex] : null;

      case 'Accounting Reports':
        const indices = [19, 20, 21, 24, 25, 26];
        return subIndex < indices.length ? indices[subIndex] : null;

      default:
        return null;
    }
  }
}
