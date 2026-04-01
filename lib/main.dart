import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:saleup_app/routes/router.dart';
import 'package:saleup_app/screen/accountHead/bloc/account_head_bloc.dart';
import 'package:saleup_app/screen/accountHead/bloc/account_head_event.dart';
import 'package:saleup_app/screen/chat/bloc/chat_bloc.dart';
import 'package:saleup_app/screen/purchase/bloc/purchase_bloc.dart';
import 'package:saleup_app/screen/voucher/bloc/voucher_bloc.dart';
import 'package:saleup_app/screen/voucher/bloc/voucher_event.dart';
import 'package:saleup_app/services/session_manager.dart';
import 'package:saleup_app/services/user_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Check session on start
  final shouldAutoLogin = await SessionManager().shouldAutoLogin();
  log('App startup → shouldAutoLogin: $shouldAutoLogin');

  runApp(
    ChangeNotifierProvider(
      create: (context) => UserServices(),
      child: MyApp(shouldAutoLogin: shouldAutoLogin),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool shouldAutoLogin;
  const MyApp({super.key, required this.shouldAutoLogin});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _router = buildRouter(widget.shouldAutoLogin);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkSession();
    }
  }

  Future<void> _checkSession() async {
    final sessionManager = SessionManager();
    final isValid = await sessionManager.shouldAutoLogin();
    if (!isValid && mounted) {
      log('Session expired on resume, refreshing router...');
      _router.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ... (existing providers)
        BlocProvider<AccountHeadBloc>(
          create: (context) =>
              AccountHeadBloc()..add(const FetchAccountHeads()),
        ),
        BlocProvider<ChatBloc>(
          create: (context) => ChatBloc(),
        ),
        BlocProvider<PurchaseBloc>(
          create: (context) => PurchaseBloc(),
        ),
        BlocProvider<VoucherBloc>(
          create: (context) => VoucherBloc()..add(const FetchVouchers()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Sales Shop App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          useMaterial3: true,
        ),
        routerConfig: _router,
      ),
    );
  }
}
