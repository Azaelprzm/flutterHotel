import 'dart:convert';
import 'package:http/http.dart' as http;

class ClienteService {
  final String apiUrl = 'https://apihotel-nodejs.onrender.com/api/clientes';
  final String? token;

  ClienteService(this.token);

  // Encabezados con el token de autorización
  Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Obtener todos los clientes
  Future<List<dynamic>> fetchClientes() async {
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: getHeaders());
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            jsonDecode(response.body)['message'] ?? 'Error al obtener los clientes');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener clientes: $e');
    }
  }

  // Crear un nuevo cliente
  Future<void> createCliente(Map<String, dynamic> clienteData) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: getHeaders(),
        body: jsonEncode(clienteData),
      );

      if (response.statusCode != 201) {
        throw Exception(
            jsonDecode(response.body)['message'] ?? 'Error al crear el cliente');
      }
    } catch (e) {
      throw Exception('Error de conexión al crear cliente: $e');
    }
  }

  // Actualizar un cliente
  Future<void> updateCliente(int id, Map<String, dynamic> clienteData) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: getHeaders(),
        body: jsonEncode(clienteData),
      );

      if (response.statusCode != 200) {
        throw Exception(
            jsonDecode(response.body)['message'] ?? 'Error al actualizar el cliente');
      }
    } catch (e) {
      throw Exception('Error de conexión al actualizar cliente: $e');
    }
  }

  // Eliminar un cliente
  Future<void> deleteCliente(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/$id'),
        headers: getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception(
            jsonDecode(response.body)['message'] ?? 'Error al eliminar el cliente');
      }
    } catch (e) {
      throw Exception('Error de conexión al eliminar cliente: $e');
    }
  }
}
