// lib/core/network/auth_token_cache.dart

class AuthTokenCache {
  static final AuthTokenCache _instance = AuthTokenCache._internal();
  factory AuthTokenCache() => _instance;
  AuthTokenCache._internal();

  String? _currentToken;

  String? get currentToken => _currentToken;

  void setToken(String? token) {
    _currentToken = token;
  }
}
