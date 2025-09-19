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
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _firstNameKey = 'first_name';
  static const _lastNameKey = 'last_name';
  static const _emailKey = 'email';
  static const _usernameKey = 'username';
  static const _phoneKey = 'phone';

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
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<int?> getUserId() async {
    final userId = await _storage.read(key: _userIdKey);
    return userId != null ? int.tryParse(userId) : null;
  }

  Future<String?> getFirstName() async {
    return await _storage.read(key: _firstNameKey);
  }

  Future<String?> getLastName() async {
    return await _storage.read(key: _lastNameKey);
  }

  Future<String?> getEmail() async {
    return await _storage.read(key: _emailKey);
  }

  Future<String?> getUsername() async {
    return await _storage.read(key: _usernameKey);
  }

  Future<String?> getPhone() async {
    return await _storage.read(key: _phoneKey);
  }

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

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _firstNameKey),
      _storage.delete(key: _lastNameKey),
      _storage.delete(key: _emailKey),
      _storage.delete(key: _usernameKey),
      _storage.delete(key: _phoneKey),
    ]);
  }
}
