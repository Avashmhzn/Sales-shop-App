import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:saleup_app/routes/router.dart';
import 'package:saleup_app/screen/accountHead/bloc/account_head_bloc.dart';
import 'package:saleup_app/screen/accountHead/bloc/account_head_event.dart';
import 'package:saleup_app/screen/chat/bloc/chat_bloc.dart';
import 'package:saleup_app/services/auth_service.dart'; // ← add this import
import 'package:saleup_app/services/user_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Clear tokens on every cold start (prevents stale token 401 errors)
  // Remove this line after testing if you don't want it in production
  await AuthService().clearTokens();
  log('Cleared tokens on app cold start (prevents stale auth issues)');

  // Optional: log current token state
  final hasToken = await AuthService().getAccessToken() != null;
  log('App startup → has valid access token? $hasToken');

  runApp(
    ChangeNotifierProvider(
      create: (context) => UserServices(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AccountHeadBloc>(
          create: (context) =>
              AccountHeadBloc()..add(const FetchAccountHeads()),
        ),
        BlocProvider<ChatBloc>(
          create: (context) => ChatBloc(),
        ),
        // Add more Blocs here if needed in the future
      ],
      child: MaterialApp.router(
        title: 'Sales Shop App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          useMaterial3: true,
        ),
        routerConfig: router, // Your GoRouter config
      ),
    );
  }
}
