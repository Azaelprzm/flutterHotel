import 'dart:convert';
import 'package:http/http.dart' as http;

class ReservaService {
  final String apiUrl = 'http://172.20.10.3:3002/api/reservas'; 
  final String? token;

  ReservaService(this.token);

  // Encabezados con el token de autorización
  Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Obtener todas las reservas
  Future<List<dynamic>> fetchReservas() async {
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: getHeaders());
      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Devuelve una lista de reservas
      } else {
        throw Exception(
            'Error al obtener las reservas: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener reservas: $e');
    }
  }

  // Crear una nueva reserva
  Future<void> createReserva(Map<String, dynamic> reservaData) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: getHeaders(),
        body: jsonEncode(reservaData),
      );

      if (response.statusCode != 201) {
        throw Exception(
            'Error al crear la reserva: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión al crear reserva: $e');
    }
  }

  // Actualizar una reserva
  Future<void> updateReserva(int id, Map<String, dynamic> reservaData) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: getHeaders(),
        body: jsonEncode(reservaData),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Error al actualizar la reserva: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión al actualizar reserva: $e');
    }
  }

  // Eliminar una reserva
  Future<void> deleteReserva(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/$id'),
        headers: getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Error al eliminar la reserva: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión al eliminar reserva: $e');
    }
  }
}
