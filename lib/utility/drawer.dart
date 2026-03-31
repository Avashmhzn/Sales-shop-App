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
//               // Header
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
//                   onNavigate(0);
//                   Navigator.pop(context);
//                 },
//               ),

//               ExpandableDrawerItem(
//                 title: "Setup",
//                 assetPath: 'assets/images/settings.png',
//                 subItems: const [
//                   'Account Heads',
//                   'Parties',
//                   'Locations',
//                   'Categories',
//                   'Products',
//                   'Units',
//                   'Expiry',
//                   'Bill Payment',
//                   'Settings',
//                 ],
//                 onNavigate: (index) {
//                   const indices = [4, 5, 6, 7, 8, 9, 10, 11, 27];
//                   onNavigate(indices[index]);
//                 },
//                 currentIndex: currentIndex,
//               ),

//               ExpandableDrawerItem(
//                 title: "Daily Transation",
//                 assetPath: 'assets/images/transaction-history.png',
//                 subItems: const [
//                   'Sales',
//                   'Sales Return',
//                   'Purchase',
//                   'Purchase Return'
//                 ],
//                 onNavigate: (index) {
//                   const indices = [2, 13, 1, 12];
//                   onNavigate(indices[index]);
//                 },
//                 currentIndex: currentIndex,
//               ),

//               ExpandableDrawerItem(
//                 title: "Receivable",
//                 assetPath: 'assets/images/receivable.png',
//                 subItems: const ['Khata', 'Create Khata'],
//                 onNavigate: (index) {
//                   const indices = [22, 23];
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
//                       'Voucher',
//                       'Receipt',
//                       'Payment',
//                       'Day Closing',
//                       "Product Report"
//                     ],
//                     onNavigate: (index) {
//                       const indices = [14, 15, 16, 18, 19];
//                       onNavigate(indices[index]);
//                     },
//                     currentIndex: currentIndex,
//                   ),
//                   ExpandableDrawerItem(
//                     title: "Accounting Reports",
//                     assetPath: 'assets/images/accounting.png',
//                     subItems: const [
//                       "Ledger Report",
//                       "Stock-Ledger",
//                       "Trial Balance",
//                       "Balance Sheet",
//                       "Profit & Loss",
//                       "Log Summary",
//                     ],
//                     onNavigate: (index) {
//                       const indices = [20, 21, 24, 25, 26, 28];
//                       onNavigate(indices[index]);
//                     },
//                     currentIndex: currentIndex,
//                   ),
//                 ],
//                 onNavigate: (index) => onNavigate(17),
//                 currentIndex: currentIndex,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ==================== DrawerItem (unchanged) ====================
// class DrawerItem extends StatelessWidget {
//   final String title;
//   final VoidCallback onTap;
//   final String? assetPath;
//   final bool isActive;

//   const DrawerItem({
//     required this.title,
//     required this.onTap,
//     this.assetPath,
//     required this.isActive,
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final color = isActive ? const Color(0xFFFFA133) : const Color(0xFF464E57);
//     final fontWeight = isActive ? FontWeight.w600 : FontWeight.normal;

//     final iconWidget = assetPath != null
//         ? Image.asset(
//             assetPath!,
//             width: 24,
//             height: 24,
//             fit: BoxFit.contain,
//             color: color,
//             errorBuilder: (_, __, ___) =>
//                 const Icon(Icons.error_outline, size: 24),
//           )
//         : const SizedBox(width: 24);

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         InkWell(
//           onTap: onTap,
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
//                       fontWeight: fontWeight,
//                       color: color,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const Divider(
//             height: 1,
//             thickness: 1,
//             color: Colors.transparent,
//             indent: 16,
//             endIndent: 16),
//       ],
//     );
//   }
// }

// // ==================== ExpandableDrawerItem - ONLY THIS PART IS FIXED ====================
// class ExpandableDrawerItem extends StatefulWidget {
//   final String title;
//   final String? assetPath;
//   final List<dynamic> subItems;
//   final Function(int) onNavigate;
//   final int currentIndex;

//   const ExpandableDrawerItem({
//     required this.title,
//     this.assetPath,
//     required this.subItems,
//     required this.onNavigate,
//     required this.currentIndex,
//     super.key,
//   });

//   @override
//   State<ExpandableDrawerItem> createState() => _ExpandableDrawerItemState();
// }

// class _ExpandableDrawerItemState extends State<ExpandableDrawerItem> {
//   bool _isExpanded = false;

//   @override
//   void initState() {
//     super.initState();
//     _isExpanded = _shouldBeExpanded();
//   }

//   @override
//   void didUpdateWidget(covariant ExpandableDrawerItem oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.currentIndex != oldWidget.currentIndex) {
//       setState(() {
//         _isExpanded = _shouldBeExpanded();
//       });
//     }
//   }

//   bool _shouldBeExpanded() {
//     for (int i = 0; i < widget.subItems.length; i++) {
//       final globalIdx = _getGlobalIndex(i);
//       if (globalIdx != null && widget.currentIndex == globalIdx) {
//         return true;
//       }
//     }
//     return false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool sectionActive = _shouldBeExpanded();

//     final headerColor =
//         sectionActive ? const Color(0xFFFFA133) : const Color(0xFF464E57);

//     final iconWidget = widget.assetPath != null
//         ? Image.asset(
//             widget.assetPath!,
//             width: 24,
//             height: 24,
//             fit: BoxFit.contain,
//             color: headerColor,
//             errorBuilder: (_, __, ___) =>
//                 const Icon(Icons.error_outline, size: 24),
//           )
//         : const SizedBox(width: 24);

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         InkWell(
//           onTap: () => setState(() => _isExpanded = !_isExpanded),
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
//         const indices = [4, 5, 6, 7, 8, 9, 10, 11, 27];
//         return subIndex < indices.length ? indices[subIndex] : null;

//       case 'Daily Transation':
//         const indices = [2, 13, 1, 12];
//         return subIndex < indices.length ? indices[subIndex] : null;

//       case 'Receivable':
//         const indices = [22, 23];
//         return subIndex < indices.length ? indices[subIndex] : null;

//       case 'Transaction Reports':
//         const indices = [14, 15, 16, 18, 19];
//         return subIndex < indices.length ? indices[subIndex] : null;

//       case 'Accounting Reports':
//         const indices = [20, 21, 24, 25, 26, 28];
//         return subIndex < indices.length ? indices[subIndex] : null;

//       default:
//         return null;
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:saleup_app/core/navigation/app_routes.dart';

// ─── Data class ───────────────────────────────────────────────────────────────

class DrawerSectionItem {
  final String label;
  final String route;
  const DrawerSectionItem(this.label, this.route);
}

// ─── Root drawer ──────────────────────────────────────────────────────────────

class AppDrawer extends StatelessWidget {
  final String currentRoute;
  final void Function(String route) onNavigate;

  const AppDrawer({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
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
                    child: Image.asset(
                      'assets/images/sales_up_logo.png',
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Dashboard
              DrawerItem(
                title: 'Dashboard',
                assetPath: 'assets/images/dashboard.png',
                isActive: currentRoute == AppRoutes.home,
                onTap: () {
                  onNavigate(AppRoutes.home);
                  Navigator.pop(context);
                },
              ),

              // Setup
              DrawerSection(
                title: 'Setup',
                assetPath: 'assets/images/settings.png',
                currentRoute: currentRoute,
                items: const [
                  DrawerSectionItem('Account Heads', AppRoutes.accountHeads),
                  DrawerSectionItem('Parties', AppRoutes.parties),
                  DrawerSectionItem('Locations', AppRoutes.locations),
                  DrawerSectionItem('Categories', AppRoutes.categories),
                  DrawerSectionItem('Products', AppRoutes.products),
                  DrawerSectionItem('Units', AppRoutes.units),
                  DrawerSectionItem('Expiry', AppRoutes.expiry),
                  DrawerSectionItem('Bill Payment', AppRoutes.billOptions),
                  DrawerSectionItem('Settings', AppRoutes.settings),
                ],
                onNavigate: (route) {
                  onNavigate(route);
                  Navigator.pop(context);
                },
              ),

              // Daily Transaction
              DrawerSection(
                title: 'Daily Transaction',
                assetPath: 'assets/images/transaction-history.png',
                currentRoute: currentRoute,
                items: const [
                  DrawerSectionItem('Sales', AppRoutes.sales),
                  DrawerSectionItem('Sales Return', AppRoutes.salesReturn),
                  DrawerSectionItem('Purchase', AppRoutes.purchase),
                  DrawerSectionItem(
                      'Purchase Return', AppRoutes.purchaseReturn),
                ],
                onNavigate: (route) {
                  onNavigate(route);
                  Navigator.pop(context);
                },
              ),

              // Reports (nested)
              DrawerNestedSection(
                title: 'Reports',
                assetPath: 'assets/images/report.png',
                currentRoute: currentRoute,
                children: [
                  DrawerSection(
                    title: 'Transaction Reports',
                    assetPath: 'assets/images/transactional-data.png',
                    currentRoute: currentRoute,
                    items: const [
                      DrawerSectionItem('Voucher', AppRoutes.voucher),
                      DrawerSectionItem('Receipt', AppRoutes.receipt),
                      DrawerSectionItem('Payment', AppRoutes.payment),
                      DrawerSectionItem('Day Closing', AppRoutes.dayClosing),
                      DrawerSectionItem(
                          'Product Report', AppRoutes.productReport),
                    ],
                    onNavigate: (route) {
                      onNavigate(route);
                      Navigator.pop(context);
                    },
                  ),
                  DrawerSection(
                    title: 'Accounting Reports',
                    assetPath: 'assets/images/accounting.png',
                    currentRoute: currentRoute,
                    items: const [
                      DrawerSectionItem(
                          'Ledger Report', AppRoutes.ledgerReport),
                      DrawerSectionItem('Stock Ledger', AppRoutes.stockLedger),
                      DrawerSectionItem(
                          'Trial Balance', AppRoutes.trialBalance),
                      // TODO: add Balance Sheet, P&L, Log Summary once screens exist
                    ],
                    onNavigate: (route) {
                      onNavigate(route);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Simple leaf item ─────────────────────────────────────────────────────────

class DrawerItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final String? assetPath;
  final bool isActive;

  const DrawerItem({
    required this.title,
    required this.onTap,
    required this.isActive,
    this.assetPath,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFFFFA133) : const Color(0xFF464E57);

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            if (assetPath != null)
              Image.asset(
                assetPath!,
                width: 24,
                height: 24,
                color: color,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.error_outline, size: 24),
              )
            else
              const SizedBox(width: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Expandable section (flat list of route items) ────────────────────────────

class DrawerSection extends StatefulWidget {
  final String title;
  final String? assetPath;
  final String currentRoute;
  final List<DrawerSectionItem> items;
  final void Function(String route) onNavigate;

  const DrawerSection({
    required this.title,
    required this.currentRoute,
    required this.items,
    required this.onNavigate,
    this.assetPath,
    super.key,
  });

  bool get hasActiveItem => items.any((i) => i.route == currentRoute);

  @override
  State<DrawerSection> createState() => _DrawerSectionState();
}

class _DrawerSectionState extends State<DrawerSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.hasActiveItem;
  }

  @override
  void didUpdateWidget(covariant DrawerSection old) {
    super.didUpdateWidget(old);
    if (widget.currentRoute != old.currentRoute) {
      setState(() => _isExpanded = widget.hasActiveItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.hasActiveItem;
    final headerColor =
        isActive ? const Color(0xFFFFA133) : const Color(0xFF464E57);

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
                    if (widget.assetPath != null)
                      Image.asset(
                        widget.assetPath!,
                        width: 24,
                        height: 24,
                        color: headerColor,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.error_outline, size: 24),
                      )
                    else
                      const SizedBox(width: 24),
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
            children: widget.items.map((item) {
              final isItemActive = item.route == widget.currentRoute;
              final color = isItemActive
                  ? const Color(0xFFFFA133)
                  : const Color(0xFF687582);
              return InkWell(
                onTap: () => widget.onNavigate(item.route),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                      left: 55, right: 16, top: 8, bottom: 8),
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight:
                          isItemActive ? FontWeight.w600 : FontWeight.normal,
                      color: color,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

// ─── Nested section (contains DrawerSection children, e.g. Reports) ──────────

class DrawerNestedSection extends StatefulWidget {
  final String title;
  final String? assetPath;
  final String currentRoute;
  final List<DrawerSection> children;

  const DrawerNestedSection({
    required this.title,
    required this.currentRoute,
    required this.children,
    this.assetPath,
    super.key,
  });

  bool get hasActiveChild => children.any((c) => c.hasActiveItem);

  @override
  State<DrawerNestedSection> createState() => _DrawerNestedSectionState();
}

class _DrawerNestedSectionState extends State<DrawerNestedSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.hasActiveChild;
  }

  @override
  void didUpdateWidget(covariant DrawerNestedSection old) {
    super.didUpdateWidget(old);
    if (widget.currentRoute != old.currentRoute) {
      setState(() => _isExpanded = widget.hasActiveChild);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.hasActiveChild;
    final headerColor =
        isActive ? const Color(0xFFFFA133) : const Color(0xFF464E57);

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
                    if (widget.assetPath != null)
                      Image.asset(
                        widget.assetPath!,
                        width: 24,
                        height: 24,
                        color: headerColor,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.error_outline, size: 24),
                      )
                    else
                      const SizedBox(width: 24),
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
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.children,
            ),
          ),
      ],
    );
  }
}
