import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('${Constants.apiBaseUrl}/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      // Login exitoso
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      // Credenciales incorrectas
      throw Exception('Credenciales incorrectas.');
    } else {
      // Otro error
      throw Exception('Error de servidor: ${response.statusCode}');
    }
  }
}
