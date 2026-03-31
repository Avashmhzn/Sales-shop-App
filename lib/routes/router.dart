// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:saleup_app/auth/view/companySelect/view/select_company_screen.dart';
// import 'package:saleup_app/auth/view/forgetpasword/view/forget_pasword.dart';
// import 'package:saleup_app/auth/view/login/view/login_screen.dart';
// import 'package:saleup_app/auth/view/signup/view/sign_up_screen.dart';
// import 'package:saleup_app/core/network/dio_client.dart';
// import 'package:saleup_app/screen/accountHead/view/account_head.dart';
// import 'package:saleup_app/screen/bill_option/bloc/bill_bloc.dart';
// import 'package:saleup_app/screen/bill_option/screen/bill_option_screen.dart';
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
// import 'package:saleup_app/screen/purchaseReturn/view/add_purchase_return_screen.dart';
// import 'package:saleup_app/screen/purchaseReturn/view/purchase_return_screen.dart';
// import 'package:saleup_app/screen/productReport/view/product_report.dart';
// import 'package:saleup_app/screen/receipts/bloc/receipt_bloc.dart';
// import 'package:saleup_app/screen/receipts/bloc/receipt_event.dart';
// import 'package:saleup_app/screen/receipts/view/receipt_screen.dart';
// import 'package:saleup_app/screen/sales/bloc/sale_bloc.dart';
// import 'package:saleup_app/screen/sales/view/add_sale_screen.dart';
// import 'package:saleup_app/screen/sales/view/sales_screen.dart';
// import 'package:saleup_app/screen/salesReturn/bloc/sale_return_bloc.dart';
// import 'package:saleup_app/screen/salesReturn/view/sale_return_screen.dart';
// import 'package:saleup_app/screen/dayClosing/view/day_closing.dart';
// import 'package:saleup_app/screen/setting/bloc/profile_bloc.dart';
// import 'package:saleup_app/screen/setting/bloc/profile_event.dart';
// import 'package:saleup_app/screen/setting/view/setting_screen.dart';
// import 'package:saleup_app/screen/stockLedger/view/stock_ledger_screen.dart';
// import 'package:saleup_app/screen/trialBalance/view/trial_balance_screen.dart';
// import 'package:saleup_app/screen/units/bloc/unit_bloc.dart';
// import 'package:saleup_app/screen/units/view/unit_screen.dart';
// import 'package:saleup_app/screen/voucher/bloc/voucher_bloc.dart';
// import 'package:saleup_app/screen/voucher/bloc/voucher_event.dart';
// import 'package:saleup_app/screen/voucher/view/post_voucher_screen.dart';
// import 'package:saleup_app/screen/voucher/view/voucher_screen.dart';
// import 'package:saleup_app/theme/custom_app_bar.dart';
// import 'package:saleup_app/utility/bottomnav.dart';
// import 'package:saleup_app/utility/drawer.dart';
// import 'package:saleup_app/utility/splash_screen.dart';

// final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
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

//   int _getIndexForRoute(String uriString) {
//     final path = Uri.parse(uriString).path;

//     switch (path) {
//       // Bottom nav
//       case '/home':
//         return 0;
//       case '/purchase':
//         return 1;
//       case '/sales':
//         return 2;
//       case '/settings':
//         return 3;

//       // Setup
//       case '/account-heads':
//         return 4;
//       case '/parties':
//         return 5;
//       case '/locations':
//         return 6;
//       case '/categories':
//         return 7;
//       case '/products':
//         return 8;
//       case '/units':
//         return 9;
//       case '/expiry':
//         return 10;
//       case '/bill-options':
//         return 11;

//       // Daily Transaction
//       case '/purchase-return':
//         return 12;
//       case '/sales-return':
//         return 13;

//       // Transaction Reports
//       case '/voucher':
//         return 14;
//       case '/receipt':
//         return 15;
//       case '/payment':
//         return 16;
//       case '/day-closing':
//         return 18;
//       case '/product-report':
//         return 19;

//       // Accounting Reports
//       case '/ledger-report':
//         return 20;
//       case '/stock-ledger-report':
//         return 21;
//       case '/trial-balace-report':
//         return 22;

//       default:
//         return -1;
//     }
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;

//       final uri = GoRouterState.of(context).uri.toString();
//       final index = _getIndexForRoute(uri);

//       setState(() {
//         _currentIndex = index >= 0 ? index : 0; // fallback to 0 instead of -1
//         _selectedIndex = (index >= 0 && index <= 3) ? index : _selectedIndex;
//         _isBottomNavVisible = index >= 0 && index <= 3;
//       });
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

//     Widget body = NotificationListener<ScrollNotification>(
//       onNotification: _handleScrollNotification,
//       child: widget.child,
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
//       backgroundColor: Colors.white,
//       extendBodyBehindAppBar: true,
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(120),
//         child: CustomAppBar(
//           onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
//           notificationCount: _notificationCount,
//           onNotificationTap: () async {
//             final result = await Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const NotificationsScreen(),
//               ),
//             );
//             if (result != null && result is int) {
//               setState(() => _notificationCount = result);
//             }
//           },
//         ),
//       ),
//       drawer: AppDrawer(
//         onNavigate: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//           handleNavigation(context, index);
//         },
//         currentIndex: _currentIndex,
//       ),
//       body: NotificationListener<ScrollNotification>(
//         onNotification: _handleScrollNotification,
//         child: widget.child,
//       ),
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
//       route = '/bill-options';
//       break;
//     case 12:
//       route = '/purchase-return';
//       break;
//     case 13:
//       route = '/sales-return';
//       break;
//     case 14:
//       route = '/voucher';
//       break;
//     case 15:
//       route = '/receipt';
//       break;
//     case 16:
//       route = '/payment';
//       break;
//     case 17:
//       route = '/chat';
//       break;
//     case 18:
//       route = '/day-closing';
//       break;
//     case 19:
//       route = '/product-report';
//       break;
//     case 20:
//       route = '/ledger-report';
//       break;
//     case 21:
//       route = '/stock-ledger-report';
//       break;
//     case 22:
//       route = '/trial-balace-report';
//       break;
//     case 27:
//       route = '/settings';
//       break;
//     case 23:
//       route = '/voucher/create';
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
//   navigatorKey: rootNavigatorKey,
//   routes: [
//     GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
//     GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
//     GoRoute(
//       path: '/onboarding',
//       builder: (context, state) => const OnboardingScreen(),
//     ),
//     GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),
//     GoRoute(
//         path: '/forgot-password',
//         builder: (context, state) => const ForgotPasswordScreen()),
//     GoRoute(
//       path: '/select_company',
//       builder: (context, state) => const CompanySelectionScreen(),
//     ),
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
//           path: '/add-sales',
//           builder: (context, state) =>
//               const AddSaleScreen(), // ← your new add sales screen
//         ),
//         GoRoute(
//           path: '/settings',
//           builder: (context, state) => BlocProvider<ProfileBloc>(
//             create: (context) => ProfileBloc(
//               dio: DioClient().dio,
//             )
//               ..add(const LoadProfile())
//               ..add(const LoadManagers()),
//             child: const SettingsScreen(),
//           ),
//         ),
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
//             create: (context) => PurchaseReturnBloc(
//               dio: DioClient().dio,
//             ),
//             child: const PurchaseReturnScreen(),
//           ),
//         ),
//         GoRoute(
//           path: '/add-purchase-return',
//           builder: (context, state) => BlocProvider(
//             create: (context) => PurchaseReturnBloc(
//               dio: DioClient().dio,
//             ),
//             child: const AddPurchaseReturnScreen(),
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
//           routes: [
//             GoRoute(
//               path: 'create',
//               builder: (context, state) => BlocProvider.value(
//                 value: BlocProvider.of<VoucherBloc>(context),
//                 child: const PostVoucherScreen(),
//               ),
//             ),
//           ],
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
//         GoRoute(
//           path: '/bill-options',
//           builder: (context, state) => BlocProvider<BillBloc>(
//             create: (context) => BillBloc(
//               dio: DioClient().dio,
//             ),
//             child: const BillOptionScreen(),
//           ),
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
import 'package:saleup_app/auth/view/companyCreate/view/create_company_page.dart';
import 'package:saleup_app/auth/view/companySelect/view/select_company_screen.dart';
import 'package:saleup_app/auth/view/forgetpasword/view/forget_pasword.dart';
import 'package:saleup_app/auth/view/login/view/login_screen.dart';
import 'package:saleup_app/auth/view/signup/view/sign_up_screen.dart';
import 'package:saleup_app/core/navigation/app_routes.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/screen/accountHead/view/account_head.dart';
import 'package:saleup_app/screen/bill_option/bloc/bill_bloc.dart';
import 'package:saleup_app/screen/bill_option/screen/bill_option_screen.dart';
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
import 'package:saleup_app/screen/productReport/view/product_report.dart';
import 'package:saleup_app/screen/purchase/bloc/purchase_bloc.dart';
import 'package:saleup_app/screen/purchase/view/purchase_screen.dart';
import 'package:saleup_app/screen/purchaseReturn/bloc/purchase_return_bloc.dart';
import 'package:saleup_app/screen/purchaseReturn/view/add_purchase_return_screen.dart';
import 'package:saleup_app/screen/purchaseReturn/view/purchase_return_screen.dart';
import 'package:saleup_app/screen/receipts/bloc/receipt_bloc.dart';
import 'package:saleup_app/screen/receipts/bloc/receipt_event.dart';
import 'package:saleup_app/screen/receipts/view/receipt_screen.dart';
import 'package:saleup_app/screen/sales/bloc/sale_bloc.dart';
import 'package:saleup_app/screen/sales/view/add_sale_screen.dart';
import 'package:saleup_app/screen/sales/view/sales_screen.dart';
import 'package:saleup_app/screen/salesReturn/bloc/sale_return_bloc.dart';
import 'package:saleup_app/screen/salesReturn/view/sale_return_screen.dart';
import 'package:saleup_app/screen/dayClosing/view/day_closing.dart';
import 'package:saleup_app/screen/setting/bloc/profile_bloc.dart';
import 'package:saleup_app/screen/setting/bloc/profile_event.dart';
import 'package:saleup_app/screen/setting/view/setting_screen.dart';
import 'package:saleup_app/screen/stockLedger/view/stock_ledger_screen.dart';
import 'package:saleup_app/screen/trialBalance/view/trial_balance_screen.dart';
import 'package:saleup_app/screen/units/bloc/unit_bloc.dart';
import 'package:saleup_app/screen/units/view/unit_screen.dart';
import 'package:saleup_app/screen/voucher/bloc/voucher_bloc.dart';
import 'package:saleup_app/screen/voucher/bloc/voucher_event.dart';
import 'package:saleup_app/screen/voucher/view/post_voucher_screen.dart';
import 'package:saleup_app/screen/voucher/view/voucher_screen.dart';
import 'package:saleup_app/theme/custom_app_bar.dart';
import 'package:saleup_app/utility/bottomnav.dart';
import 'package:saleup_app/utility/drawer.dart';
import 'package:saleup_app/utility/splash_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

const List<String> _bottomNavRoutes = [
  AppRoutes.home,
  AppRoutes.purchase,
  AppRoutes.sales,
  AppRoutes.settings,
];

class ShellScaffold extends StatefulWidget {
  final Widget child;
  const ShellScaffold({super.key, required this.child});

  @override
  State<ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends State<ShellScaffold> {
  int _notificationCount = 3;
  bool _isBottomNavVisible = true;
  int _selectedIndex = 0;

  int _bottomNavIndex(String path) => _bottomNavRoutes.indexOf(path);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final path = GoRouterState.of(context).uri.path;
      final idx = _bottomNavIndex(path);
      setState(() {
        if (idx >= 0) _selectedIndex = idx;
        _isBottomNavVisible = idx >= 0;
      });
    });
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    final path = GoRouterState.of(context).uri.path;
    final isBottomNavRoute = _bottomNavIndex(path) >= 0;

    if (notification is ScrollUpdateNotification &&
        notification.scrollDelta != null) {
      final delta = notification.scrollDelta!;
      if (delta > 5 && _isBottomNavVisible && isBottomNavRoute) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _isBottomNavVisible = false);
        });
      } else if (delta < -5 && !_isBottomNavVisible && isBottomNavRoute) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _isBottomNavVisible = true);
        });
      }
    } else if (notification is ScrollEndNotification &&
        notification.metrics.pixels <= 0 &&
        isBottomNavRoute &&
        !_isBottomNavVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _isBottomNavVisible = true);
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: CustomAppBar(
          onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
          notificationCount: _notificationCount,
          onNotificationTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotificationsScreen(),
              ),
            );
            if (result is int) {
              setState(() => _notificationCount = result);
            }
          },
        ),
      ),
      drawer: AppDrawer(
        currentRoute: GoRouterState.of(context).uri.path,
        onNavigate: (route) => context.go(route),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: widget.child,
      ),
      bottomNavigationBar: _isBottomNavVisible
          ? SizedBox(
              height: 80,
              child: BottomNav(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() => _selectedIndex = index);
                  context.go(_bottomNavRoutes[index]);
                },
              ),
            )
          : null,
    );
  }
}

final GoRouter router = GoRouter(
  initialLocation: AppRoutes.splash,
  navigatorKey: rootNavigatorKey,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (_, __) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      builder: (_, __) => const SignUpScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (_, __) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.selectCompany,
      builder: (_, __) => const CompanySelectionScreen(),
    ),
    GoRoute(
      path: AppRoutes.createCompany,
      builder: (_, __) => const CreateCompanyPage(),
    ),
    ShellRoute(
      builder: (context, state, child) => ShellScaffold(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (context, _) => BlocProvider(
            create: (_) => DashboardBloc()..add(const FetchDashboardData()),
            child: const DashboardScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.purchase,
          builder: (context, _) => BlocProvider(
            create: (_) => PurchaseBloc(),
            child: const PurchaseScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.sales,
          builder: (context, _) => BlocProvider(
            create: (_) => SaleBloc(),
            child: const SaleScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.addSales,
          builder: (_, __) => const AddSaleScreen(),
        ),
        GoRoute(
          path: AppRoutes.settings,
          builder: (context, _) => BlocProvider<ProfileBloc>(
            create: (_) => ProfileBloc(dio: DioClient().dio)
              ..add(const LoadProfile())
              ..add(const LoadManagers()),
            child: const SettingsScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.accountHeads,
          builder: (_, __) => const AccountHead(),
        ),
        GoRoute(
          path: AppRoutes.parties,
          builder: (context, _) => BlocProvider(
            create: (_) => PartyBloc(),
            child: const PartiesScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.locations,
          builder: (context, _) => BlocProvider(
            create: (_) => LocationBloc(),
            child: const LocationsScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.categories,
          builder: (context, _) => BlocProvider(
            create: (_) => CategoryBloc(),
            child: const CategoriesScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.products,
          builder: (context, _) => BlocProvider(
            create: (_) => ProductBloc(),
            child: const ProductsScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.units,
          builder: (context, _) => BlocProvider(
            create: (_) => UnitBloc(),
            child: const UnitsScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.expiry,
          builder: (context, _) => BlocProvider(
            create: (_) => ExpiryBloc(),
            child: const ExpiryScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.billOptions,
          builder: (context, _) => BlocProvider<BillBloc>(
            create: (_) => BillBloc(dio: DioClient().dio),
            child: const BillOptionScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.purchaseReturn,
          builder: (context, _) => BlocProvider(
            create: (_) => PurchaseReturnBloc(dio: DioClient().dio),
            child: const PurchaseReturnScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.addPurchaseReturn,
          builder: (context, _) => BlocProvider(
            create: (_) => PurchaseReturnBloc(dio: DioClient().dio),
            child: const AddPurchaseReturnScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.salesReturn,
          builder: (context, _) => BlocProvider(
            create: (_) => SaleReturnBloc(),
            child: const SaleReturnScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.voucher,
          builder: (context, _) => BlocProvider(
            create: (_) => VoucherBloc()..add(const FetchVouchers()),
            child: const VoucherScreen(),
          ),
          routes: [
            GoRoute(
              path: 'create',
              builder: (context, _) => BlocProvider.value(
                value: BlocProvider.of<VoucherBloc>(context),
                child: const PostVoucherScreen(),
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.receipt,
          builder: (context, _) => BlocProvider(
            create: (_) => ReceiptBloc()..add(const FetchReceipts()),
            child: const ReceiptScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.payment,
          builder: (context, _) => BlocProvider(
            create: (_) => PaymentBloc()..add(const FetchPayments()),
            child: const PaymentScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.chat,
          builder: (context, _) => BlocProvider(
            create: (_) => ChatBloc(),
            child: const ChatScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.dayClosing,
          builder: (_, __) => const DayClosing(),
        ),
        GoRoute(
          path: AppRoutes.productReport,
          builder: (_, __) => const ProductReport(),
        ),
        GoRoute(
          path: AppRoutes.ledgerReport,
          builder: (_, __) => const LedgerReportScreen(),
        ),
        GoRoute(
          path: AppRoutes.stockLedger,
          builder: (_, __) => const StockLedgerScreen(),
        ),
        GoRoute(
          path: AppRoutes.trialBalance,
          builder: (_, __) => const TrialBalanceScreen(),
        ),
      ],
    ),
  ],
  errorBuilder: (_, state) => Scaffold(
    body: Center(child: Text('Route not found: ${state.uri}')),
  ),
);
