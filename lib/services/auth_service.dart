// // lib/services/auth_service.dart

// import 'dart:developer' as developer;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class AuthService {
//   static const FlutterSecureStorage _storage = FlutterSecureStorage();

//   static const String _accessTokenKey = 'access_token';
//   static const String _refreshTokenKey = 'refresh_token';
//   static const String _userIdKey = 'user_id';
//   static const String _firstNameKey = 'first_name';
//   static const String _lastNameKey = 'last_name';
//   static const String _emailKey = 'email';
//   static const String _usernameKey = 'username';
//   static const String _phoneKey = 'phone';
//   static const String _rememberMeKey = 'remember_me';
//   static const String _lastLoginTimeKey = 'last_login_time'; // ← Added

//   /// Save all tokens and user data after login
//   Future<void> saveTokens({
//     required String accessToken,
//     required String refreshToken,
//     required int userId,
//     String? email,
//     String? username,
//     String? firstName,
//     String? lastName,
//     String? phone,
//   }) async {
//     developer.log('saveTokens() started', name: 'AuthService');

//     await Future.wait([
//       _storage.write(key: _accessTokenKey, value: accessToken),
//       _storage.write(key: _refreshTokenKey, value: refreshToken),
//       _storage.write(key: _userIdKey, value: userId.toString()),
//       if (email != null) _storage.write(key: _emailKey, value: email),
//       if (username != null) _storage.write(key: _usernameKey, value: username),
//       if (firstName != null)
//         _storage.write(key: _firstNameKey, value: firstName),
//       if (lastName != null) _storage.write(key: _lastNameKey, value: lastName),
//       if (phone != null) _storage.write(key: _phoneKey, value: phone),
//     ]);

//     developer.log('saveTokens() completed successfully', name: 'AuthService');
//   }

//   // ====================== REMEMBER ME (New) ======================
//   Future<void> setRememberMe(bool value) async {
//     await _storage.write(key: _rememberMeKey, value: value.toString());
//     developer.log('Remember Me set to: $value', name: 'AuthService');
//   }

//   Future<bool> getRememberMe() async {
//     final value = await _storage.read(key: _rememberMeKey);
//     final remember = value == 'true';
//     developer.log('getRememberMe() → $remember', name: 'AuthService');
//     return remember;
//   }

//   // ====================== SESSION TIME (New) ======================
//   Future<void> setLastLoginTime(DateTime time) async {
//     await _storage.write(key: _lastLoginTimeKey, value: time.toIso8601String());
//     developer.log('Last Login Time set to: ${time.toIso8601String()}',
//         name: 'AuthService');
//   }

//   Future<DateTime?> getLastLoginTime() async {
//     final value = await _storage.read(key: _lastLoginTimeKey);
//     if (value == null) return null;
//     try {
//       final time = DateTime.parse(value);
//       developer.log('getLastLoginTime() → $time', name: 'AuthService');
//       return time;
//     } catch (e) {
//       developer.log('Error parsing last login time: $e', name: 'AuthService');
//       return null;
//     }
//   }

//   // ====================== EXISTING METHODS ======================
//   Future<String?> getAccessToken() async {
//     final token = await _storage.read(key: _accessTokenKey);
//     developer.log('getAccessToken() → ${token != null ? "YES" : "NULL"}',
//         name: 'AuthService');
//     return token;
//   }

//   Future<String?> getRefreshToken() async {
//     final token = await _storage.read(key: _refreshTokenKey);
//     developer.log('getRefreshToken() → ${token != null ? "YES" : "NULL"}',
//         name: 'AuthService');
//     return token;
//   }

//   Future<int?> getUserId() async {
//     final userIdStr = await _storage.read(key: _userIdKey);
//     final userId = userIdStr != null ? int.tryParse(userIdStr) : null;
//     developer.log('getUserId() → $userId', name: 'AuthService');
//     return userId;
//   }

//   Future<String?> getFirstName() async =>
//       await _storage.read(key: _firstNameKey);
//   Future<String?> getLastName() async => await _storage.read(key: _lastNameKey);
//   Future<String?> getEmail() async => await _storage.read(key: _emailKey);
//   Future<String?> getUsername() async => await _storage.read(key: _usernameKey);
//   Future<String?> getPhone() async => await _storage.read(key: _phoneKey);

//   Future<void> updateUserData({
//     String? firstName,
//     String? lastName,
//     String? phone,
//   }) async {
//     await Future.wait([
//       if (firstName != null)
//         _storage.write(key: _firstNameKey, value: firstName),
//       if (lastName != null) _storage.write(key: _lastNameKey, value: lastName),
//       if (phone != null) _storage.write(key: _phoneKey, value: phone),
//     ]);
//   }

//   /// Clear everything when user logs out
//   Future<void> clearTokens() async {
//     developer.log('clearTokens() started - Logging out user',
//         name: 'AuthService');

//     await Future.wait([
//       _storage.delete(key: _accessTokenKey),
//       _storage.delete(key: _refreshTokenKey),
//       _storage.delete(key: _userIdKey),
//       _storage.delete(key: _firstNameKey),
//       _storage.delete(key: _lastNameKey),
//       _storage.delete(key: _emailKey),
//       _storage.delete(key: _usernameKey),
//       _storage.delete(key: _phoneKey),
//       _storage.delete(key: _rememberMeKey),
//       _storage.delete(key: _lastLoginTimeKey), // ← Important
//     ]);

//     developer.log('clearTokens() completed - All data cleared',
//         name: 'AuthService');
//   }
// }
// lib/services/auth_service.dart

import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:saleup_app/core/network/api_endpoints.dart';
import 'package:saleup_app/core/network/auth_token_cache.dart';

class AuthService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _firstNameKey = 'first_name';
  static const String _lastNameKey = 'last_name';
  static const String _emailKey = 'email';
  static const String _usernameKey = 'username';
  static const String _phoneKey = 'phone';
  static const String _rememberMeKey = 'remember_me';
  static const String _lastLoginTimeKey = 'last_login_time';

  // ★ In-memory cache for Remember Me (avoids async reads in interceptors)
  bool _rememberMeCache = false;
  bool get rememberMeSync => _rememberMeCache;

  /// Save all tokens and user data after login
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int userId,
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    developer.log('saveTokens() started', name: 'AuthService');

    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
      _storage.write(key: _userIdKey, value: userId.toString()),
      if (email != null) _storage.write(key: _emailKey, value: email),
      if (username != null) _storage.write(key: _usernameKey, value: username),
      if (firstName != null)
        _storage.write(key: _firstNameKey, value: firstName),
      if (lastName != null) _storage.write(key: _lastNameKey, value: lastName),
      if (phone != null) _storage.write(key: _phoneKey, value: phone),
    ]);

    // ★ Update in-memory cache
    AuthTokenCache().setToken(accessToken);

    developer.log('saveTokens() completed successfully', name: 'AuthService');
  }

  // ====================== REMEMBER ME ======================
  Future<void> setRememberMe(bool value) async {
    _rememberMeCache = value;
    await _storage.write(key: _rememberMeKey, value: value.toString());
    developer.log('Remember Me set to: $value', name: 'AuthService');
  }

  Future<bool> getRememberMe() async {
    final value = await _storage.read(key: _rememberMeKey);
    _rememberMeCache = value == 'true';
    developer.log('getRememberMe() → $_rememberMeCache', name: 'AuthService');
    return _rememberMeCache;
  }

  // ====================== SESSION TIME ======================
  Future<void> setLastLoginTime(DateTime time) async {
    await _storage.write(key: _lastLoginTimeKey, value: time.toIso8601String());
  }

  Future<DateTime?> getLastLoginTime() async {
    final value = await _storage.read(key: _lastLoginTimeKey);
    if (value == null) return null;
    try {
      return DateTime.parse(value);
    } catch (e) {
      return null;
    }
  }

  // ====================== TOKEN READERS ======================
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<int?> getUserId() async {
    final userIdStr = await _storage.read(key: _userIdKey);
    return userIdStr != null ? int.tryParse(userIdStr) : null;
  }

  Future<String?> getFirstName() async =>
      await _storage.read(key: _firstNameKey);
  Future<String?> getLastName() async => await _storage.read(key: _lastNameKey);
  Future<String?> getEmail() async => await _storage.read(key: _emailKey);
  Future<String?> getUsername() async => await _storage.read(key: _usernameKey);
  Future<String?> getPhone() async => await _storage.read(key: _phoneKey);

  Future<void> updateUserData({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    await Future.wait([
      if (firstName != null)
        _storage.write(key: _firstNameKey, value: firstName),
      if (lastName != null) _storage.write(key: _lastNameKey, value: lastName),
      if (phone != null) _storage.write(key: _phoneKey, value: phone),
    ]);
  }

  // ═══════════════════════════════════════════════════════════════
  // ★ KEY: Try to refresh on app startup
  // ═══════════════════════════════════════════════════════════════
  Future<bool> tryRefreshOnStartup() async {
    try {
      developer.log('🔄 Startup: Checking if we can refresh tokens...',
          name: 'AuthService');

      final refreshToken = await getRefreshToken();
      final rememberMe = await getRememberMe();

      if (refreshToken == null || refreshToken.isEmpty || !rememberMe) {
        developer.log('❌ Startup: No refresh token or Remember Me off',
            name: 'AuthService');
        return false;
      }

      // Create a PLAIN Dio instance for this one-time refresh call
      final refreshDio = Dio(BaseOptions(
        baseUrl: Api.currentBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 600,
      ));

      final response = await refreshDio.post(
        '/auth/refresh/',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        dynamic responseData = response.data;
        Map<String, dynamic>? tokenData;
        if (responseData is Map<String, dynamic>) {
          if (responseData['success'] == true && responseData['data'] != null) {
            tokenData = responseData['data'] as Map<String, dynamic>;
          } else if (responseData['access_token'] != null) {
            tokenData = responseData;
          }
        }

        if (tokenData != null) {
          final newAccessToken =
              tokenData['access_token'] ?? tokenData['accessToken'];
          final newRefreshToken = tokenData['refresh_token'] ??
              tokenData['refreshToken'] ??
              refreshToken;

          if (newAccessToken != null) {
            await saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
              userId: await getUserId() ?? 0,
            );
            developer.log('✅ Startup: Token refreshed — user stays logged in',
                name: 'AuthService');
            return true;
          }
        }
      }
      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        developer.log('🚨 Startup: Refresh token EXPIRED → need login',
            name: 'AuthService');
        await clearTokens();
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ★ KEY: Check if user is authenticated (with auto-refresh)
  // ═══════════════════════════════════════════════════════════════
  Future<bool> isAuthenticated() async {
    final accessToken = await getAccessToken();

    // Fast path: access token exists (might be expired, interceptor handles it)
    if (accessToken != null && accessToken.isNotEmpty) {
      AuthTokenCache().setToken(accessToken);
      return true;
    }

    // No access token → try refresh if Remember Me is on
    return await tryRefreshOnStartup();
  }

  /// Clear everything when user logs out
  Future<void> clearTokens() async {
    developer.log('clearTokens() started - Logging out user',
        name: 'AuthService');

    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _firstNameKey),
      _storage.delete(key: _lastNameKey),
      _storage.delete(key: _emailKey),
      _storage.delete(key: _usernameKey),
      _storage.delete(key: _phoneKey),
      _storage.delete(key: _rememberMeKey),
      _storage.delete(key: _lastLoginTimeKey),
    ]);

    // ★ Clear in-memory caches
    AuthTokenCache().setToken(null);
    _rememberMeCache = false;

    developer.log('clearTokens() completed - All data cleared',
        name: 'AuthService');
  }
}
