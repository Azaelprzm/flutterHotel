import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    AuthService? authService,
    FlutterSecureStorage? secureStorage,
  })  : _authService = authService ?? AuthService(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';

  final AuthService _authService;
  final FlutterSecureStorage _secureStorage;

  String? _token;

  String? get token => _token;
  bool get isAuthenticated => _token != null;

  Future<void> restoreSession() async {
    try {
      final savedToken = await _secureStorage.read(key: _tokenKey);
      if (savedToken != null && !_isExpired(savedToken)) {
        _token = savedToken;
      } else if (savedToken != null) {
        await _secureStorage.delete(key: _tokenKey);
      }
    } catch (_) {
      _token = null;
    }
  }

  Future<void> login(String email, String password) async {
    final token = await _authService.login(email.trim(), password);
    await _secureStorage.write(key: _tokenKey, value: token);
    _token = token;
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    notifyListeners();
    try {
      await _secureStorage.delete(key: _tokenKey);
    } catch (_) {
      // La sesión local ya fue eliminada de memoria.
    }
  }

  bool _isExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return true;
      }

      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      if (payload is! Map<String, dynamic> || payload['exp'] is! num) {
        return true;
      }

      final expiresAt = DateTime.fromMillisecondsSinceEpoch(
        (payload['exp'] as num).toInt() * 1000,
      );
      return !expiresAt.isAfter(DateTime.now());
    } catch (_) {
      return true;
    }
  }
}
