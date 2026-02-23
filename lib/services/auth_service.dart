// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class AuthService {
//   static const _storage = FlutterSecureStorage();

//   static const _accessTokenKey = 'access_token';
//   static const _refreshTokenKey = 'refresh_token';
//   static const _userIdKey = 'user_id';
//   static const _firstNameKey = 'first_name';
//   static const _lastNameKey = 'last_name';
//   static const _emailKey = 'email';
//   static const _usernameKey = 'username';
//   static const _phoneKey = 'phone';

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
//   }

//   Future<String?> getAccessToken() async {
//     return await _storage.read(key: _accessTokenKey);
//   }

//   Future<String?> getRefreshToken() async {
//     return await _storage.read(key: _refreshTokenKey);
//   }

//   Future<int?> getUserId() async {
//     final userId = await _storage.read(key: _userIdKey);
//     return userId != null ? int.tryParse(userId) : null;
//   }

//   Future<String?> getFirstName() async {
//     return await _storage.read(key: _firstNameKey);
//   }

//   Future<String?> getLastName() async {
//     return await _storage.read(key: _lastNameKey);
//   }

//   Future<String?> getEmail() async {
//     return await _storage.read(key: _emailKey);
//   }

//   Future<String?> getUsername() async {
//     return await _storage.read(key: _usernameKey);
//   }

//   Future<String?> getPhone() async {
//     return await _storage.read(key: _phoneKey);
//   }

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

//   Future<void> clearTokens() async {
//     await Future.wait([
//       _storage.delete(key: _accessTokenKey),
//       _storage.delete(key: _refreshTokenKey),
//       _storage.delete(key: _userIdKey),
//       _storage.delete(key: _firstNameKey),
//       _storage.delete(key: _lastNameKey),
//       _storage.delete(key: _emailKey),
//       _storage.delete(key: _usernameKey),
//       _storage.delete(key: _phoneKey),
//     ]);
//   }
// }

import 'dart:developer' as developer;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
      _storage.write(key: _accessTokenKey, value: accessToken).then((_) {
        developer.log('Saved access_token (length: ${accessToken.length})',
            name: 'AuthService');
      }),
      _storage.write(key: _refreshTokenKey, value: refreshToken).then((_) {
        developer.log('Saved refresh_token (length: ${refreshToken.length})',
            name: 'AuthService');
      }),
      _storage.write(key: _userIdKey, value: userId.toString()).then((_) {
        developer.log('Saved user_id: $userId', name: 'AuthService');
      }),
      if (email != null)
        _storage.write(key: _emailKey, value: email).then((_) {
          developer.log('Saved email: $email', name: 'AuthService');
        }),
      if (username != null)
        _storage.write(key: _usernameKey, value: username).then((_) {
          developer.log('Saved username: $username', name: 'AuthService');
        }),
      if (firstName != null)
        _storage.write(key: _firstNameKey, value: firstName).then((_) {
          developer.log('Saved first_name: $firstName', name: 'AuthService');
        }),
      if (lastName != null)
        _storage.write(key: _lastNameKey, value: lastName).then((_) {
          developer.log('Saved last_name: $lastName', name: 'AuthService');
        }),
      if (phone != null)
        _storage.write(key: _phoneKey, value: phone).then((_) {
          developer.log('Saved phone: $phone', name: 'AuthService');
        }),
    ]);

    developer.log('saveTokens() completed successfully', name: 'AuthService');
  }

  /// Read access token
  Future<String?> getAccessToken() async {
    final token = await _storage.read(key: _accessTokenKey);
    developer.log(
      'getAccessToken() → ${token != null ? "YES (length: ${token.length}, starts with: ${token.substring(0, 10)}...)" : "NULL"}',
      name: 'AuthService',
    );
    return token;
  }

  /// Read refresh token
  Future<String?> getRefreshToken() async {
    final token = await _storage.read(key: _refreshTokenKey);
    developer.log(
      'getRefreshToken() → ${token != null ? "YES" : "NULL"}',
      name: 'AuthService',
    );
    return token;
  }

  /// Read user ID
  Future<int?> getUserId() async {
    final userIdStr = await _storage.read(key: _userIdKey);
    final userId = userIdStr != null ? int.tryParse(userIdStr) : null;
    developer.log('getUserId() → $userId (raw: $userIdStr)',
        name: 'AuthService');
    return userId;
  }

  /// Read first name
  Future<String?> getFirstName() async {
    final value = await _storage.read(key: _firstNameKey);
    developer.log('getFirstName() → $value', name: 'AuthService');
    return value;
  }

  /// Read last name
  Future<String?> getLastName() async {
    final value = await _storage.read(key: _lastNameKey);
    developer.log('getLastName() → $value', name: 'AuthService');
    return value;
  }

  /// Read email
  Future<String?> getEmail() async {
    final value = await _storage.read(key: _emailKey);
    developer.log('getEmail() → $value', name: 'AuthService');
    return value;
  }

  /// Read username
  Future<String?> getUsername() async {
    final value = await _storage.read(key: _usernameKey);
    developer.log('getUsername() → $value', name: 'AuthService');
    return value;
  }

  /// Read phone
  Future<String?> getPhone() async {
    final value = await _storage.read(key: _phoneKey);
    developer.log('getPhone() → $value', name: 'AuthService');
    return value;
  }

  /// Update only non-token user data
  Future<void> updateUserData({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    developer.log('updateUserData() started', name: 'AuthService');

    await Future.wait([
      if (firstName != null)
        _storage.write(key: _firstNameKey, value: firstName).then((_) {
          developer.log('Updated first_name: $firstName', name: 'AuthService');
        }),
      if (lastName != null)
        _storage.write(key: _lastNameKey, value: lastName).then((_) {
          developer.log('Updated last_name: $lastName', name: 'AuthService');
        }),
      if (phone != null)
        _storage.write(key: _phoneKey, value: phone).then((_) {
          developer.log('Updated phone: $phone', name: 'AuthService');
        }),
    ]);

    developer.log('updateUserData() completed', name: 'AuthService');
  }

  /// Clear all stored auth/user data
  Future<void> clearTokens() async {
    developer.log('clearTokens() started', name: 'AuthService');

    await Future.wait([
      _storage.delete(key: _accessTokenKey).then((_) {
        developer.log('Deleted access_token', name: 'AuthService');
      }),
      _storage.delete(key: _refreshTokenKey).then((_) {
        developer.log('Deleted refresh_token', name: 'AuthService');
      }),
      _storage.delete(key: _userIdKey).then((_) {
        developer.log('Deleted user_id', name: 'AuthService');
      }),
      _storage.delete(key: _firstNameKey).then((_) {
        developer.log('Deleted first_name', name: 'AuthService');
      }),
      _storage.delete(key: _lastNameKey).then((_) {
        developer.log('Deleted last_name', name: 'AuthService');
      }),
      _storage.delete(key: _emailKey).then((_) {
        developer.log('Deleted email', name: 'AuthService');
      }),
      _storage.delete(key: _usernameKey).then((_) {
        developer.log('Deleted username', name: 'AuthService');
      }),
      _storage.delete(key: _phoneKey).then((_) {
        developer.log('Deleted phone', name: 'AuthService');
      }),
    ]);

    developer.log('clearTokens() completed - all keys deleted',
        name: 'AuthService');
  }
}
