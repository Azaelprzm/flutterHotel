import 'api_client.dart';
import 'api_exception.dart';

class HabitacionService {
  HabitacionService(String token) : _apiClient = ApiClient(token: token);

  final ApiClient _apiClient;

  Future<List<dynamic>> fetchHabitaciones() async {
    final response = await _apiClient.get('/habitaciones');
    if (response is List<dynamic>) {
      return response;
    }
    throw const ApiException(
      'La lista de habitaciones no tiene un formato válido.',
    );
  }

  Future<void> createHabitacion(Map<String, dynamic> habitacionData) async {
    await _apiClient.post('/habitaciones', body: habitacionData);
  }

  Future<void> updateHabitacion(
    int id,
    Map<String, dynamic> habitacionData,
  ) async {
    await _apiClient.put('/habitaciones/$id', body: habitacionData);
  }

  Future<void> deleteHabitacion(int id) async {
    await _apiClient.delete('/habitaciones/$id');
  }

  Future<void> registrarPago(Map<String, dynamic> pagoData) async {
    await _apiClient.post('/pagos', body: pagoData);
  }
}
