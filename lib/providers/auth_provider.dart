import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthProvider extends ChangeNotifier {
  String? _token;

  String? get token => _token;

  bool get isAuthenticated => _token != null;

  Future<void> login(String email, String password) async {
    final url = Uri.parse('http://172.20.10.3:3002/api/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        notifyListeners();
      } else {
        throw Exception('Credenciales incorrectas');
      }
    } catch (e) {
      print('Error durante el inicio de sesión: $e');
      rethrow;
    }
  }

  void logout() {
    _token = null;
    notifyListeners();
  }
}
