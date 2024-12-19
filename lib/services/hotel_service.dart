import 'dart:convert';
import 'package:http/http.dart' as http;

class HotelService {
  final String apiUrl = 'https://apihotel-nodejs.onrender.com/api/hoteles';
  final String? token;

  HotelService(this.token);

  // Encabezados con el token de autorización
  Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Obtener todos los hoteles
  Future<List<dynamic>> fetchHoteles() async {
    final response = await http.get(Uri.parse(apiUrl), headers: getHeaders());
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener los hoteles');
    }
  }

  // Crear un nuevo hotel
  Future<void> createHotel(Map<String, dynamic> hotelData) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: getHeaders(),
      body: jsonEncode(hotelData),
    );
    if (response.statusCode != 201) {
      throw Exception('Error al crear el hotel');
    }
  }

  // Actualizar un hotel
  Future<void> updateHotel(int id, Map<String, dynamic> hotelData) async {
    final response = await http.put(
      Uri.parse('$apiUrl/$id'),
      headers: getHeaders(),
      body: jsonEncode(hotelData),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el hotel');
    }
  }

  // Eliminar un hotel
  Future<void> deleteHotel(int id) async {
    final response = await http.delete(
      Uri.parse('$apiUrl/$id'),
      headers: getHeaders(),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar el hotel');
    }
  }
}
