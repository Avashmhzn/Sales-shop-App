// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:saleup_app/auth/view/forgetpasword/view/forget_pasword.dart';
// import 'package:saleup_app/auth/view/login/view/login_screen.dart';
// import 'package:saleup_app/screen/accountHead/view/account_head.dart';
// import 'package:saleup_app/screen/categories/bloc/category_bloc.dart';
// import 'package:saleup_app/screen/categories/view/categories_screen.dart';
// import 'package:saleup_app/screen/chat/bloc/chat_bloc.dart';
// import 'package:saleup_app/screen/chat/view/chat_screen.dart';
// import 'package:saleup_app/screen/dashboard/bloc/dashboard_bloc.dart';
// import 'package:saleup_app/screen/dashboard/bloc/dashboard_event.dart';
// import 'package:saleup_app/screen/dashboard/view/dashboard_screen.dart';
// import 'package:saleup_app/screen/expiry/bloc/expiry_bloc.dart';
// import 'package:saleup_app/screen/expiry/view/expiry_screen.dart';
// import 'package:saleup_app/screen/ledger/view/ledger_report_screen.dart';
// import 'package:saleup_app/screen/location/bloc/location_bloc.dart';
// import 'package:saleup_app/screen/location/view/location_screen.dart';
// import 'package:saleup_app/screen/notification/view/notification_screen.dart';
// import 'package:saleup_app/screen/onboarding/view/onboarding_screen.dart';
// import 'package:saleup_app/screen/parties/bloc/party_bloc.dart';
// import 'package:saleup_app/screen/parties/view/parties_screen.dart';
// import 'package:saleup_app/screen/payment/bloc/payment_bloc.dart';
// import 'package:saleup_app/screen/payment/bloc/payment_event.dart';
// import 'package:saleup_app/screen/payment/view/payment_screen.dart';
// import 'package:saleup_app/screen/product/bloc/product_bloc.dart';
// import 'package:saleup_app/screen/product/view/products_screen.dart';
// import 'package:saleup_app/screen/purchase/bloc/purchase_bloc.dart';
// import 'package:saleup_app/screen/purchase/view/purchase_screen.dart';
// import 'package:saleup_app/screen/purchaseReturn/bloc/purchase_return_bloc.dart';
// import 'package:saleup_app/screen/purchaseReturn/view/purchase_return_screen.dart';
// import 'package:saleup_app/screen/productReport/view/product_report.dart';
// import 'package:saleup_app/screen/receipts/bloc/receipt_bloc.dart';
// import 'package:saleup_app/screen/receipts/bloc/receipt_event.dart';
// import 'package:saleup_app/screen/receipts/view/receipt_screen.dart';
// import 'package:saleup_app/screen/sales/bloc/sale_bloc.dart';
// import 'package:saleup_app/screen/sales/view/sales_screen.dart';
// import 'package:saleup_app/screen/salesReturn/bloc/sale_return_bloc.dart';
// import 'package:saleup_app/screen/salesReturn/view/sale_return_screen.dart';
// import 'package:saleup_app/screen/dayClosing/view/day_closing.dart';
// import 'package:saleup_app/screen/setting/view/setting_screen.dart';
// import 'package:saleup_app/screen/stockLedger/view/stock_ledger_screen.dart';
// import 'package:saleup_app/screen/trialBalance/view/trial_balance_screen.dart';
// import 'package:saleup_app/screen/units/bloc/unit_bloc.dart';
// import 'package:saleup_app/screen/units/view/unit_screen.dart';
// import 'package:saleup_app/screen/voucher/bloc/voucher_bloc.dart';
// import 'package:saleup_app/screen/voucher/bloc/voucher_event.dart';
// import 'package:saleup_app/screen/voucher/view/voucher_screen.dart';
// import 'package:saleup_app/theme/custom_app_bar.dart';
// import 'package:saleup_app/utility/bottomnav.dart';
// import 'package:saleup_app/utility/drawer.dart';
// import 'package:saleup_app/utility/splash_screen.dart';

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

// class ShellScaffold extends StatefulWidget {
//   final Widget child;
//   const ShellScaffold({super.key, required this.child});

//   @override
//   State<ShellScaffold> createState() => _ShellScaffoldState();
// }

// class _ShellScaffoldState extends State<ShellScaffold> {
//   int _currentIndex = 0;
//   int _notificationCount = 3;
//   bool _isBottomNavVisible = true;
//   int _selectedIndex = 0;

//   int _getIndexForRoute(String route) {
//     switch (route) {
//       case '/home':
//         return 0;
//       case '/purchase':
//         return 1;
//       case '/sales':
//         return 2;
//       case '/settings':
//         return 3;
//       default:
//         return -1;
//     }
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         final route = GoRouterState.of(context).uri.toString();
//         setState(() {
//           _currentIndex = _getIndexForRoute(route);
//           _selectedIndex = _currentIndex;
//           _isBottomNavVisible = _getIndexForRoute(route) != -1;
//         });
//       }
//     });
//   }

//   bool _handleScrollNotification(ScrollNotification notification) {
//     if (notification is ScrollUpdateNotification &&
//         notification.scrollDelta != null) {
//       final delta = notification.scrollDelta!;
//       final currentRoute = GoRouterState.of(context).uri.toString();
//       final isMainRoute = _getIndexForRoute(currentRoute) != -1;

//       if (delta > 5 && _isBottomNavVisible && isMainRoute) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (mounted) setState(() => _isBottomNavVisible = false);
//         });
//       } else if (delta < -5 && !_isBottomNavVisible && isMainRoute) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (mounted) setState(() => _isBottomNavVisible = true);
//         });
//       }
//     } else if (notification is ScrollEndNotification &&
//         notification.metrics.pixels <= 0 &&
//         _getIndexForRoute(GoRouterState.of(context).uri.toString()) != -1) {
//       if (!_isBottomNavVisible) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (mounted) setState(() => _isBottomNavVisible = true);
//         });
//       }
//     }
//     return false;
//   }

//   Future<void> _refresh() async {}

//   @override
//   Widget build(BuildContext context) {
//     const double bottomNavHeight = 80.0;
//     final currentRoute = GoRouterState.of(context).uri.toString();

//     Widget body = Column(
//       children: [
//         const Divider(thickness: 1, height: 1, color: Colors.grey),
//         Expanded(child: widget.child),
//       ],
//     );

//     body = RefreshIndicator(
//       onRefresh: _refresh,
//       child: NotificationListener<ScrollNotification>(
//         onNotification: _handleScrollNotification,
//         child: body,
//       ),
//     );

//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: CustomAppBar(
//         onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
//         notificationCount: _notificationCount,
//         onNotificationTap: () async {
//           final result = await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const NotificationsScreen(),
//             ),
//           );
//           if (result != null && result is int) {
//             setState(() => _notificationCount = result);
//           }
//         },
//       ),
//       drawer:
//           AppDrawer(onNavigate: (index) => handleNavigation(context, index)),
//       backgroundColor: Colors.white,
//       body: SafeArea(child: body),
//       bottomNavigationBar: _isBottomNavVisible
//           ? SizedBox(
//               height: bottomNavHeight,
//               child: BottomNav(
//                 currentIndex: _selectedIndex,
//                 onTap: (index) {
//                   setState(() {
//                     _selectedIndex = index;
//                     _currentIndex = index;
//                     handleNavigation(context, index);
//                   });
//                 },
//               ),
//             )
//           : null,
//     );
//   }
// }

// // ✅ FIXED: removed '/error' invalid route reference
// void handleNavigation(BuildContext context, int index) {
//   String? route;
//   switch (index) {
//     case 0:
//       route = '/home';
//       break;
//     case 1:
//       route = '/purchase';
//       break;
//     case 2:
//       route = '/sales';
//       break;
//     case 3:
//       route = '/settings';
//       break;
//     case 4:
//       route = '/account-heads';
//       break;
//     case 5:
//       route = '/parties';
//       break;
//     case 6:
//       route = '/locations';
//       break;
//     case 7:
//       route = '/categories';
//       break;
//     case 8:
//       route = '/products';
//       break;
//     case 9:
//       route = '/units';
//       break;
//     case 10:
//       route = '/expiry';
//       break;
//     case 11:
//       route = '/purchase-return';
//       break;
//     case 12:
//       route = '/sales-return';
//       break;
//     case 13:
//       route = '/voucher';
//       break;
//     case 14:
//       route = '/receipt';
//       break;
//     case 15:
//       route = '/payment';
//       break;
//     case 16:
//       route = '/chat';
//       break;
//     case 17:
//       route = '/day-closing';
//       break;
//     case 18:
//       route = '/product-report';
//       break;
//     case 19:
//       route = '/ledger-report';
//       break;
//     case 20:
//       route = '/stock-ledger-report';
//       break;
//     case 21:
//       route = '/trial-balace-report';
//       break;
//     default:
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Invalid navigation index: $index')),
//       );
//       return;
//   }
//   context.go(route);
// }

// final GoRouter router = GoRouter(
//   initialLocation: '/splash',
//   navigatorKey: navigatorKey,
//   routes: [
//     GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
//     GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
//     GoRoute(
//         path: '/signup', builder: (context, state) => const OnboardingScreen()),
//     GoRoute(
//         path: '/forgot-password',
//         builder: (context, state) => const ForgotPasswordScreen()),
//     ShellRoute(
//       builder: (context, state, child) => ShellScaffold(child: child),
//       routes: [
//         GoRoute(
//           path: '/home',
//           builder: (context, state) => BlocProvider(
//             create: (context) =>
//                 DashboardBloc()..add(const FetchDashboardData()),
//             child: const DashboardScreen(),
//           ),
//         ),
//         GoRoute(
//           path: '/purchase',
//           builder: (context, state) => BlocProvider(
//             create: (context) => PurchaseBloc(),
//             child: const PurchaseScreen(),
//           ),
//         ),
//         GoRoute(
//           path: '/sales',
//           builder: (context, state) => BlocProvider(
//             create: (context) => SaleBloc(),
//             child: const SaleScreen(),
//           ),
//         ),
//         GoRoute(
//             path: '/settings',
//             builder: (context, state) => const SettingsScreen()),
//         GoRoute(
//             path: '/account-heads',
//             builder: (context, state) => const AccountHead()),
//         GoRoute(
//           path: '/parties',
//           builder: (context, state) => BlocProvider(
//             create: (context) => PartyBloc(),
//             child: const PartiesScreen(),
//           ),
//         ),
//         GoRoute(
//           path: '/locations',
//           builder: (context, state) => BlocProvider(
//             create: (context) => LocationBloc(),
//             child: const LocationsScreen(),
//           ),
//         ),
//         GoRoute(
//           path: '/categories',
//           builder: (context, state) => BlocProvider(
//             create: (context) => CategoryBloc(),
//             child: const CategoriesScreen(),
//           ),
//         ),
//         GoRoute(
//           path: '/products',
//           builder: (context, state) => BlocProvider(
//             create: (context) => ProductBloc(),
//             child: const ProductsScreen(),
//           ),
//         ),
//         GoRoute(
//           path: '/units',
//           builder: (context, state) => BlocProvider(
//             create: (context) => UnitBloc(),
//             child: const UnitsScreen(),
//           ),
//         ),
//         GoRoute(
//           path: '/expiry',
//           builder: (context, state) => BlocProvider(
//             create: (context) => ExpiryBloc(),
//             child: const ExpiryScreen(),
//           ),
//         ),
//         GoRoute(
//           path: '/purchase-return',
//           builder: (context, state) => BlocProvider(
//             create: (context) => PurchaseReturnBloc(),
//             child: const PurchaseReturnScreen(),
//           ),
//         ),
//         GoRoute(
//           path: '/sales-return',
//           builder: (context, state) => BlocProvider(
//             create: (context) => SaleReturnBloc(),
//             child: const SaleReturnScreen(),
//           ),
//         ),
//         GoRoute(
//           path: '/voucher',
//           builder: (context, state) => BlocProvider(
//             create: (context) => VoucherBloc()..add(const FetchVouchers()),
//             child: const VoucherScreen(),
//           ),
//         ),
//         GoRoute(
//           path: '/receipt',
//           builder: (context, state) => BlocProvider(
//             create: (context) => ReceiptBloc()..add(const FetchReceipts()),
//             child: const ReceiptScreen(),
//           ),
//         ),
//         GoRoute(
//           path: '/payment',
//           builder: (context, state) => BlocProvider(
//             create: (context) => PaymentBloc()..add(const FetchPayments()),
//             child: const PaymentScreen(),
//           ),
//         ),
//         GoRoute(
//           path: '/chat',
//           builder: (context, state) => BlocProvider(
//             create: (context) => ChatBloc(),
//             child: const ChatScreen(),
//           ),
//         ),
//         GoRoute(
//           path: '/ledger-report',
//           builder: (context, state) => const LedgerReportScreen(),
//         ),
//         GoRoute(
//           path: '/day-closing',
//           builder: (context, state) => const DayClosing(),
//         ),
//         GoRoute(
//           path: '/product-report',
//           builder: (context, state) => const ProductReport(),
//         ),
//         GoRoute(
//           path: '/stock-ledger-report',
//           builder: (context, state) => const StockLedgerScreen(),
//         ),
//         GoRoute(
//           path: '/trial-balace-report',
//           builder: (context, state) => const TrialBalanceScreen(),
//         ),
//       ],
//     ),
//   ],
//   errorBuilder: (context, state) =>
//       Scaffold(body: Center(child: Text('Route not found: ${state.uri}'))),
// );
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:saleup_app/auth/view/forgetpasword/view/forget_pasword.dart';
import 'package:saleup_app/auth/view/login/view/login_screen.dart';
import 'package:saleup_app/screen/accountHead/view/account_head.dart';
import 'package:saleup_app/screen/categories/bloc/category_bloc.dart';
import 'package:saleup_app/screen/categories/view/categories_screen.dart';
import 'package:saleup_app/screen/chat/bloc/chat_bloc.dart';
import 'package:saleup_app/screen/chat/view/chat_screen.dart';
import 'package:saleup_app/screen/dashboard/bloc/dashboard_bloc.dart';
import 'package:saleup_app/screen/dashboard/bloc/dashboard_event.dart';
import 'package:saleup_app/screen/dashboard/view/dashboard_screen.dart';
import 'package:saleup_app/screen/expiry/bloc/expiry_bloc.dart';
import 'package:saleup_app/screen/expiry/view/expiry_screen.dart';
import 'package:saleup_app/screen/ledger/view/ledger_report_screen.dart';
import 'package:saleup_app/screen/location/bloc/location_bloc.dart';
import 'package:saleup_app/screen/location/view/location_screen.dart';
import 'package:saleup_app/screen/notification/view/notification_screen.dart';
import 'package:saleup_app/screen/onboarding/view/onboarding_screen.dart';
import 'package:saleup_app/screen/parties/bloc/party_bloc.dart';
import 'package:saleup_app/screen/parties/view/parties_screen.dart';
import 'package:saleup_app/screen/payment/bloc/payment_bloc.dart';
import 'package:saleup_app/screen/payment/bloc/payment_event.dart';
import 'package:saleup_app/screen/payment/view/payment_screen.dart';
import 'package:saleup_app/screen/product/bloc/product_bloc.dart';
import 'package:saleup_app/screen/product/view/products_screen.dart';
import 'package:saleup_app/screen/purchase/bloc/purchase_bloc.dart';
import 'package:saleup_app/screen/purchase/view/purchase_screen.dart';
import 'package:saleup_app/screen/purchaseReturn/bloc/purchase_return_bloc.dart';
import 'package:saleup_app/screen/purchaseReturn/view/purchase_return_screen.dart';
import 'package:saleup_app/screen/productReport/view/product_report.dart';
import 'package:saleup_app/screen/receipts/bloc/receipt_bloc.dart';
import 'package:saleup_app/screen/receipts/bloc/receipt_event.dart';
import 'package:saleup_app/screen/receipts/view/receipt_screen.dart';
import 'package:saleup_app/screen/sales/bloc/sale_bloc.dart';
import 'package:saleup_app/screen/sales/view/sales_screen.dart';
import 'package:saleup_app/screen/salesReturn/bloc/sale_return_bloc.dart';
import 'package:saleup_app/screen/salesReturn/view/sale_return_screen.dart';
import 'package:saleup_app/screen/dayClosing/view/day_closing.dart';
import 'package:saleup_app/screen/setting/view/setting_screen.dart';
import 'package:saleup_app/screen/stockLedger/view/stock_ledger_screen.dart';
import 'package:saleup_app/screen/trialBalance/view/trial_balance_screen.dart';
import 'package:saleup_app/screen/units/bloc/unit_bloc.dart';
import 'package:saleup_app/screen/units/view/unit_screen.dart';
import 'package:saleup_app/screen/voucher/bloc/voucher_bloc.dart';
import 'package:saleup_app/screen/voucher/bloc/voucher_event.dart';
import 'package:saleup_app/screen/voucher/view/voucher_screen.dart';
import 'package:saleup_app/theme/custom_app_bar.dart';
import 'package:saleup_app/utility/bottomnav.dart';
import 'package:saleup_app/utility/drawer.dart';
import 'package:saleup_app/utility/splash_screen.dart';

// ──────────────────────────────────────────────────────────────
// ROOT NAVIGATOR KEY — THIS IS THE ONLY NEW LINE
// ──────────────────────────────────────────────────────────────
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class ShellScaffold extends StatefulWidget {
  final Widget child;
  const ShellScaffold({super.key, required this.child});

  @override
  State<ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends State<ShellScaffold> {
  int _currentIndex = 0;
  int _notificationCount = 3;
  bool _isBottomNavVisible = true;
  int _selectedIndex = 0;

  int _getIndexForRoute(String route) {
    switch (route) {
      case '/home':
        return 0;
      case '/purchase':
        return 1;
      case '/sales':
        return 2;
      case '/settings':
        return 3;
      default:
        return -1;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final route = GoRouterState.of(context).uri.toString();
        setState(() {
          _currentIndex = _getIndexForRoute(route);
          _selectedIndex = _currentIndex;
          _isBottomNavVisible = _getIndexForRoute(route) != -1;
        });
      }
    });
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification &&
        notification.scrollDelta != null) {
      final delta = notification.scrollDelta!;
      final currentRoute = GoRouterState.of(context).uri.toString();
      final isMainRoute = _getIndexForRoute(currentRoute) != -1;

      if (delta > 5 && _isBottomNavVisible && isMainRoute) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _isBottomNavVisible = false);
        });
      } else if (delta < -5 && !_isBottomNavVisible && isMainRoute) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _isBottomNavVisible = true);
        });
      }
    } else if (notification is ScrollEndNotification &&
        notification.metrics.pixels <= 0 &&
        _getIndexForRoute(GoRouterState.of(context).uri.toString()) != -1) {
      if (!_isBottomNavVisible) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _isBottomNavVisible = true);
        });
      }
    }
    return false;
  }

  Future<void> _refresh() async {}

  @override
  Widget build(BuildContext context) {
    const double bottomNavHeight = 80.0;
    final currentRoute = GoRouterState.of(context).uri.toString();

    Widget body = Column(
      children: [
        const Divider(thickness: 1, height: 1, color: Colors.grey),
        Expanded(child: widget.child),
      ],
    );

    body = RefreshIndicator(
      onRefresh: _refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: body,
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
        notificationCount: _notificationCount,
        onNotificationTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationsScreen(),
            ),
          );
          if (result != null && result is int) {
            setState(() => _notificationCount = result);
          }
        },
      ),
      drawer:
          AppDrawer(onNavigate: (index) => handleNavigation(context, index)),
      backgroundColor: Colors.white,
      body: SafeArea(child: body),
      bottomNavigationBar: _isBottomNavVisible
          ? SizedBox(
              height: bottomNavHeight,
              child: BottomNav(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                    _currentIndex = index;
                    handleNavigation(context, index);
                  });
                },
              ),
            )
          : null,
    );
  }
}

// FIXED: removed '/error' invalid route reference
void handleNavigation(BuildContext context, int index) {
  String? route;
  switch (index) {
    case 0:
      route = '/home';
      break;
    case 1:
      route = '/purchase';
      break;
    case 2:
      route = '/sales';
      break;
    case 3:
      route = '/settings';
      break;
    case 4:
      route = '/account-heads';
      break;
    case 5:
      route = '/parties';
      break;
    case 6:
      route = '/locations';
      break;
    case 7:
      route = '/categories';
      break;
    case 8:
      route = '/products';
      break;
    case 9:
      route = '/units';
      break;
    case 10:
      route = '/expiry';
      break;
    case 11:
      route = '/purchase-return';
      break;
    case 12:
      route = '/sales-return';
      break;
    case 13:
      route = '/voucher';
      break;
    case 14:
      route = '/receipt';
      break;
    case 15:
      route = '/payment';
      break;
    case 16:
      route = '/chat';
      break;
    case 17:
      route = '/day-closing';
      break;
    case 18:
      route = '/product-report';
      break;
    case 19:
      route = '/ledger-report';
      break;
    case 20:
      route = '/stock-ledger-report';
      break;
    case 21:
      route = '/trial-balace-report';
      break;
    default:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid navigation index: $index')),
      );
      return;
  }
  context.go(route);
}

// ──────────────────────────────────────────────────────────────
// ONLY CHANGE: navigatorKey → _rootNavigatorKey
// ──────────────────────────────────────────────────────────────
final GoRouter router = GoRouter(
  initialLocation: '/splash',
  navigatorKey: rootNavigatorKey, // ← CHANGED THIS LINE
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
        path: '/signup', builder: (context, state) => const OnboardingScreen()),
    GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen()),
    ShellRoute(
      builder: (context, state, child) => ShellScaffold(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => BlocProvider(
            create: (context) =>
                DashboardBloc()..add(const FetchDashboardData()),
            child: const DashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/purchase',
          builder: (context, state) => BlocProvider(
            create: (context) => PurchaseBloc(),
            child: const PurchaseScreen(),
          ),
        ),
        GoRoute(
          path: '/sales',
          builder: (context, state) => BlocProvider(
            create: (context) => SaleBloc(),
            child: const SaleScreen(),
          ),
        ),
        GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen()),
        GoRoute(
            path: '/account-heads',
            builder: (context, state) => const AccountHead()),
        GoRoute(
          path: '/parties',
          builder: (context, state) => BlocProvider(
            create: (context) => PartyBloc(),
            child: const PartiesScreen(),
          ),
        ),
        GoRoute(
          path: '/locations',
          builder: (context, state) => BlocProvider(
            create: (context) => LocationBloc(),
            child: const LocationsScreen(),
          ),
        ),
        GoRoute(
          path: '/categories',
          builder: (context, state) => BlocProvider(
            create: (context) => CategoryBloc(),
            child: const CategoriesScreen(),
          ),
        ),
        GoRoute(
          path: '/products',
          builder: (context, state) => BlocProvider(
            create: (context) => ProductBloc(),
            child: const ProductsScreen(),
          ),
        ),
        GoRoute(
          path: '/units',
          builder: (context, state) => BlocProvider(
            create: (context) => UnitBloc(),
            child: const UnitsScreen(),
          ),
        ),
        GoRoute(
          path: '/expiry',
          builder: (context, state) => BlocProvider(
            create: (context) => ExpiryBloc(),
            child: const ExpiryScreen(),
          ),
        ),
        GoRoute(
          path: '/purchase-return',
          builder: (context, state) => BlocProvider(
            create: (context) => PurchaseReturnBloc(),
            child: const PurchaseReturnScreen(),
          ),
        ),
        GoRoute(
          path: '/sales-return',
          builder: (context, state) => BlocProvider(
            create: (context) => SaleReturnBloc(),
            child: const SaleReturnScreen(),
          ),
        ),
        GoRoute(
          path: '/voucher',
          builder: (context, state) => BlocProvider(
            create: (context) => VoucherBloc()..add(const FetchVouchers()),
            child: const VoucherScreen(),
          ),
        ),
        GoRoute(
          path: '/receipt',
          builder: (context, state) => BlocProvider(
            create: (context) => ReceiptBloc()..add(const FetchReceipts()),
            child: const ReceiptScreen(),
          ),
        ),
        GoRoute(
          path: '/payment',
          builder: (context, state) => BlocProvider(
            create: (context) => PaymentBloc()..add(const FetchPayments()),
            child: const PaymentScreen(),
          ),
        ),
        GoRoute(
          path: '/chat',
          builder: (context, state) => BlocProvider(
            create: (context) => ChatBloc(),
            child: const ChatScreen(),
          ),
        ),
        GoRoute(
          path: '/ledger-report',
          builder: (context, state) => const LedgerReportScreen(),
        ),
        GoRoute(
          path: '/day-closing',
          builder: (context, state) => const DayClosing(),
        ),
        GoRoute(
          path: '/product-report',
          builder: (context, state) => const ProductReport(),
        ),
        GoRoute(
          path: '/stock-ledger-report',
          builder: (context, state) => const StockLedgerScreen(),
        ),
        GoRoute(
          path: '/trial-balace-report',
          builder: (context, state) => const TrialBalanceScreen(),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Route not found: ${state.uri}'))),
);
