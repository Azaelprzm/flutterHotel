import 'dart:convert';
import 'package:http/http.dart' as http;

class HabitacionService {
  final String apiUrl = 'https://apihotel-nodejs.onrender.com/api/habitaciones';
  final String? token;

  HabitacionService(this.token);

  // Encabezados con el token de autorización
  Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Obtener todas las habitaciones
  Future<List<dynamic>> fetchHabitaciones() async {
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: getHeaders());
      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Devuelve una lista de habitaciones
      } else {
        throw Exception(
            'Error al obtener las habitaciones: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener habitaciones: $e');
    }
  }

  // Crear una nueva habitación
  Future<void> createHabitacion(Map<String, dynamic> habitacionData) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: getHeaders(),
        body: jsonEncode(habitacionData),
      );

      if (response.statusCode != 201) {
        throw Exception(
            'Error al crear la habitación: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión al crear habitación: $e');
    }
  }

  // Actualizar una habitación
  Future<void> updateHabitacion(int id, Map<String, dynamic> habitacionData) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: getHeaders(),
        body: jsonEncode(habitacionData),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Error al actualizar la habitación: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión al actualizar habitación: $e');
    }
  }

  // Eliminar una habitación
  Future<void> deleteHabitacion(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/$id'),
        headers: getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Error al eliminar la habitación: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión al eliminar habitación: $e');
    }
  }

// Registrar un pago
Future<void> registrarPago(Map<String, dynamic> pagoData) async {
  try {
    final apiUrlPagos = 'https://apihotel-nodejs.onrender.com/api/pagos';
    final response = await http.post(
      Uri.parse(apiUrlPagos),
      headers: getHeaders(),
      body: jsonEncode(pagoData),
    );

    if (response.statusCode != 201) {
      throw Exception(
          'Error al registrar el pago: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    throw Exception('Error de conexión al registrar el pago: $e');
  }
}

}
