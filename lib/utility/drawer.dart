// import 'package:flutter/material.dart';
// import 'package:saleup_app/core/navigation/app_routes.dart';

// // ─── Data class ───────────────────────────────────────────────────────────────

// class DrawerSectionItem {
//   final String label;
//   final String route;
//   const DrawerSectionItem(this.label, this.route);
// }

// // ─── Root drawer ──────────────────────────────────────────────────────────────

// class AppDrawer extends StatelessWidget {
//   final String currentRoute;
//   final void Function(String route) onNavigate;

//   const AppDrawer({
//     super.key,
//     required this.currentRoute,
//     required this.onNavigate,
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
//                     child: Image.asset(
//                       'assets/images/sales_up_logo.png',
//                       height: 60,
//                       fit: BoxFit.contain,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),

//               // Dashboard
//               DrawerItem(
//                 title: 'Dashboard',
//                 assetPath: 'assets/images/dashboard.png',
//                 isActive: currentRoute == AppRoutes.home,
//                 onTap: () {
//                   onNavigate(AppRoutes.home);
//                   Navigator.pop(context);
//                 },
//               ),

//               // Setup
//               DrawerSection(
//                 title: 'Setup',
//                 assetPath: 'assets/images/settings.png',
//                 currentRoute: currentRoute,
//                 items: const [
//                   DrawerSectionItem('Account Heads', AppRoutes.accountHeads),
//                   DrawerSectionItem('Parties', AppRoutes.parties),
//                   DrawerSectionItem('Locations', AppRoutes.locations),
//                   DrawerSectionItem('Categories', AppRoutes.categories),
//                   DrawerSectionItem('Products', AppRoutes.products),
//                   DrawerSectionItem('Units', AppRoutes.units),
//                   DrawerSectionItem('Expiry', AppRoutes.expiry),
//                   DrawerSectionItem('Bill Payment', AppRoutes.billOptions),
//                   DrawerSectionItem('Settings', AppRoutes.settings),
//                 ],
//                 onNavigate: (route) {
//                   onNavigate(route);
//                   Navigator.pop(context);
//                 },
//               ),

//               // Daily Transaction
//               DrawerSection(
//                 title: 'Daily Transaction',
//                 assetPath: 'assets/images/transaction-history.png',
//                 currentRoute: currentRoute,
//                 items: const [
//                   DrawerSectionItem('Sales', AppRoutes.sales),
//                   DrawerSectionItem('Sales Return', AppRoutes.salesReturn),
//                   DrawerSectionItem('Purchase', AppRoutes.purchase),
//                   DrawerSectionItem(
//                       'Purchase Return', AppRoutes.purchaseReturn),
//                 ],
//                 onNavigate: (route) {
//                   onNavigate(route);
//                   Navigator.pop(context);
//                 },
//               ),

//               // Reports (nested)
//               DrawerNestedSection(
//                 title: 'Reports',
//                 assetPath: 'assets/images/report.png',
//                 currentRoute: currentRoute,
//                 children: [
//                   DrawerSection(
//                     title: 'Transaction Reports',
//                     assetPath: 'assets/images/transactional-data.png',
//                     currentRoute: currentRoute,
//                     items: const [
//                       DrawerSectionItem('Voucher', AppRoutes.voucher),
//                       DrawerSectionItem('Receipt', AppRoutes.receipt),
//                       DrawerSectionItem('Payment', AppRoutes.payment),
//                       DrawerSectionItem('Day Closing', AppRoutes.dayClosing),
//                       DrawerSectionItem(
//                           'Product Report', AppRoutes.productReport),
//                     ],
//                     onNavigate: (route) {
//                       onNavigate(route);
//                       Navigator.pop(context);
//                     },
//                   ),
//                   DrawerSection(
//                     title: 'Accounting Reports',
//                     assetPath: 'assets/images/accounting.png',
//                     currentRoute: currentRoute,
//                     items: const [
//                       DrawerSectionItem(
//                           'Ledger Report', AppRoutes.ledgerReport),
//                       DrawerSectionItem('Stock Ledger', AppRoutes.stockLedger),
//                       DrawerSectionItem(
//                           'Trial Balance', AppRoutes.trialBalance),
//                       // TODO: add Balance Sheet, P&L, Log Summary once screens exist
//                     ],
//                     onNavigate: (route) {
//                       onNavigate(route);
//                       Navigator.pop(context);
//                     },
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

// // ─── Simple leaf item ─────────────────────────────────────────────────────────

// class DrawerItem extends StatelessWidget {
//   final String title;
//   final VoidCallback onTap;
//   final String? assetPath;
//   final bool isActive;

//   const DrawerItem({
//     required this.title,
//     required this.onTap,
//     required this.isActive,
//     this.assetPath,
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final color = isActive ? const Color(0xFFFFA133) : const Color(0xFF464E57);

//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         child: Row(
//           children: [
//             if (assetPath != null)
//               Image.asset(
//                 assetPath!,
//                 width: 24,
//                 height: 24,
//                 color: color,
//                 errorBuilder: (_, __, ___) =>
//                     const Icon(Icons.error_outline, size: 24),
//               )
//             else
//               const SizedBox(width: 24),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontFamily: 'Inter',
//                   fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
//                   color: color,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─── Expandable section (flat list of route items) ────────────────────────────

// class DrawerSection extends StatefulWidget {
//   final String title;
//   final String? assetPath;
//   final String currentRoute;
//   final List<DrawerSectionItem> items;
//   final void Function(String route) onNavigate;

//   const DrawerSection({
//     required this.title,
//     required this.currentRoute,
//     required this.items,
//     required this.onNavigate,
//     this.assetPath,
//     super.key,
//   });

//   bool get hasActiveItem => items.any((i) => i.route == currentRoute);

//   @override
//   State<DrawerSection> createState() => _DrawerSectionState();
// }

// class _DrawerSectionState extends State<DrawerSection> {
//   late bool _isExpanded;

//   @override
//   void initState() {
//     super.initState();
//     _isExpanded = widget.hasActiveItem;
//   }

//   @override
//   void didUpdateWidget(covariant DrawerSection old) {
//     super.didUpdateWidget(old);
//     if (widget.currentRoute != old.currentRoute) {
//       setState(() => _isExpanded = widget.hasActiveItem);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isActive = widget.hasActiveItem;
//     final headerColor =
//         isActive ? const Color(0xFFFFA133) : const Color(0xFF464E57);

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
//                     if (widget.assetPath != null)
//                       Image.asset(
//                         widget.assetPath!,
//                         width: 24,
//                         height: 24,
//                         color: headerColor,
//                         errorBuilder: (_, __, ___) =>
//                             const Icon(Icons.error_outline, size: 24),
//                       )
//                     else
//                       const SizedBox(width: 24),
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
//             children: widget.items.map((item) {
//               final isItemActive = item.route == widget.currentRoute;
//               final color = isItemActive
//                   ? const Color(0xFFFFA133)
//                   : const Color(0xFF687582);
//               return InkWell(
//                 onTap: () => widget.onNavigate(item.route),
//                 child: Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.only(
//                       left: 55, right: 16, top: 8, bottom: 8),
//                   child: Text(
//                     item.label,
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontFamily: 'Inter',
//                       fontWeight:
//                           isItemActive ? FontWeight.w600 : FontWeight.normal,
//                       color: color,
//                     ),
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//       ],
//     );
//   }
// }

// // ─── Nested section (contains DrawerSection children, e.g. Reports) ──────────

// class DrawerNestedSection extends StatefulWidget {
//   final String title;
//   final String? assetPath;
//   final String currentRoute;
//   final List<DrawerSection> children;

//   const DrawerNestedSection({
//     required this.title,
//     required this.currentRoute,
//     required this.children,
//     this.assetPath,
//     super.key,
//   });

//   bool get hasActiveChild => children.any((c) => c.hasActiveItem);

//   @override
//   State<DrawerNestedSection> createState() => _DrawerNestedSectionState();
// }

// class _DrawerNestedSectionState extends State<DrawerNestedSection> {
//   late bool _isExpanded;

//   @override
//   void initState() {
//     super.initState();
//     _isExpanded = widget.hasActiveChild;
//   }

//   @override
//   void didUpdateWidget(covariant DrawerNestedSection old) {
//     super.didUpdateWidget(old);
//     if (widget.currentRoute != old.currentRoute) {
//       setState(() => _isExpanded = widget.hasActiveChild);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isActive = widget.hasActiveChild;
//     final headerColor =
//         isActive ? const Color(0xFFFFA133) : const Color(0xFF464E57);

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
//                     if (widget.assetPath != null)
//                       Image.asset(
//                         widget.assetPath!,
//                         width: 24,
//                         height: 24,
//                         color: headerColor,
//                         errorBuilder: (_, __, ___) =>
//                             const Icon(Icons.error_outline, size: 24),
//                       )
//                     else
//                       const SizedBox(width: 24),
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
//           Padding(
//             padding: const EdgeInsets.only(left: 16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: widget.children,
//             ),
//           ),
//       ],
//     );
//   }
// }

// lib/widgets/app_drawer.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saleup_app/core/navigation/app_routes.dart';
import 'package:saleup_app/services/session_manager.dart'; // ← Added for logout

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

  // Logout Dialog
  Future<void> _showLogoutDialog(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon at top
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.red.shade400,
                  size: 32,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Are you sure you want to log out? You will need to sign in again to access your account.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Inter',
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF4B5563),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.red.shade400,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldLogout == true && context.mounted) {
      await SessionManager().logout();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          // Changed to Column for fixed bottom
          children: [
            // Your original scrollable content
            Expanded(
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
                        DrawerSectionItem(
                            'Account Heads', AppRoutes.accountHeads),
                        DrawerSectionItem('Parties', AppRoutes.parties),
                        DrawerSectionItem('Locations', AppRoutes.locations),
                        DrawerSectionItem('Categories', AppRoutes.categories),
                        DrawerSectionItem('Products', AppRoutes.products),
                        DrawerSectionItem('Units', AppRoutes.units),
                        DrawerSectionItem('Expiry', AppRoutes.expiry),
                        DrawerSectionItem(
                            'Bill Payment', AppRoutes.billOptions),
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
                        DrawerSectionItem(
                            'Sales Return', AppRoutes.salesReturn),
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
                            DrawerSectionItem(
                                'Day Closing', AppRoutes.dayClosing),
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
                            DrawerSectionItem(
                                'Stock Ledger', AppRoutes.stockLedger),
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

            // ====================== LOGOUT BUTTON AT BOTTOM ======================
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: DrawerItem(
                title: 'Logout',
                assetPath: 'assets/images/logout.png', // Assuming this exists or using icon
                isActive: false,
                onTap: () => _showLogoutDialog(context),
              ),
            ),
            const SizedBox(height: 10),
          ],
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
                width: 20, // Smaller icon to match design better
                height: 20,
                color: title == 'Logout' ? Colors.red.shade400 : color,
                errorBuilder: (_, __, ___) => Icon(
                  title == 'Logout' ? Icons.logout : Icons.error_outline,
                  size: 20,
                  color: title == 'Logout' ? Colors.red.shade400 : color,
                ),
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
                  color: title == 'Logout' ? Colors.red.shade400 : color,
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
