// // lib/services/session_manager.dart

// import 'dart:developer' as developer;
// import 'package:saleup_app/services/auth_service.dart';

// class SessionManager {
//   static final SessionManager _instance = SessionManager._internal();
//   factory SessionManager() => _instance;
//   SessionManager._internal();

//   final AuthService _authService = AuthService();

//   /// Check if user should automatically login on app start
//   Future<bool> shouldAutoLogin() async {
//     final rememberMe = await _authService.getRememberMe();
//     final token = await _authService.getAccessToken();
//     final hasToken = token != null && token.isNotEmpty;
//     final lastLogin = await _authService.getLastLoginTime();

//     if (!rememberMe || !hasToken || lastLogin == null) {
//       developer.log(
//         'SessionManager: shouldAutoLogin → false (Rem: $rememberMe, Token: $hasToken, Time: $lastLogin)',
//         name: 'SessionManager',
//       );
//       return false;
//     }

//     // Check if 1 day (24 hours) has passed
//     final isExpired = DateTime.now().difference(lastLogin).inHours >= 24;

//     if (isExpired) {
//       developer.log('SessionManager: Session expired (>24h). Logging out...',
//           name: 'SessionManager');
//       await logout();
//       return false;
//     }

//     developer.log('SessionManager: shouldAutoLogin → true',
//         name: 'SessionManager');
//     return true;
//   }

//   /// Call this after successful login
//   Future<void> loginSuccess({required bool rememberMe}) async {
//     await _authService.setRememberMe(rememberMe);
//     await _authService.setLastLoginTime(DateTime.now());
//     developer.log(
//         'SessionManager: Login successful. RememberMe: $rememberMe, Time: ${DateTime.now()}',
//         name: 'SessionManager');
//   }

//   /// Logout user completely
//   Future<void> logout() async {
//     await _authService.clearTokens();
//     developer.log('SessionManager: User logged out successfully',
//         name: 'SessionManager');
//   }
// }

// lib/services/session_manager.dart

import 'dart:developer' as developer;
import 'package:saleup_app/services/auth_service.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  final AuthService _authService = AuthService();

  /// Check if user should automatically login on app start
  Future<bool> shouldAutoLogin() async {
    developer.log('SessionManager: shouldAutoLogin() called',
        name: 'SessionManager');

    // Use isAuthenticated() which tries refresh if access token is missing
    final isAuthenticated = await _authService.isAuthenticated();

    if (isAuthenticated) {
      developer.log('SessionManager: shouldAutoLogin → true (session valid)',
          name: 'SessionManager');
      return true;
    }

    developer.log('SessionManager: shouldAutoLogin → false (session expired)',
        name: 'SessionManager');
    return false;
  }

  /// Call this after successful login
  Future<void> loginSuccess({required bool rememberMe}) async {
    await _authService.setRememberMe(rememberMe);
    await _authService.setLastLoginTime(DateTime.now());
    developer.log('SessionManager: Login successful. RememberMe: $rememberMe',
        name: 'SessionManager');
  }

  /// Logout user completely
  Future<void> logout() async {
    await _authService.clearTokens();
    developer.log('SessionManager: User logged out successfully',
        name: 'SessionManager');
  }
}
