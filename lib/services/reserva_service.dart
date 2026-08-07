import 'api_client.dart';
import 'api_exception.dart';

class ReservaService {
  ReservaService(String token) : _apiClient = ApiClient(token: token);

  final ApiClient _apiClient;

  Future<List<dynamic>> fetchReservas() async {
    final response = await _apiClient.get('/reservas');
    if (response is List<dynamic>) {
      return response;
    }
    throw const ApiException(
        'La lista de reservas no tiene un formato válido.');
  }

  Future<void> createReserva(Map<String, dynamic> reservaData) async {
    await _apiClient.post('/reservas', body: reservaData);
  }

  Future<void> updateReserva(int id, Map<String, dynamic> reservaData) async {
    await _apiClient.put('/reservas/$id', body: reservaData);
  }

  Future<void> deleteReserva(int id) async {
    await _apiClient.delete('/reservas/$id');
  }
}
