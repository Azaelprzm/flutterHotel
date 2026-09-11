import 'api_client.dart';
import 'api_exception.dart';

class HotelService {
  HotelService(String token) : _apiClient = ApiClient(token: token);

  final ApiClient _apiClient;

  Future<List<dynamic>> fetchHoteles() async {
    final response = await _apiClient.get('/hoteles');
    if (response is List<dynamic>) {
      return response;
    }
    throw const ApiException('La lista de hoteles no tiene un formato válido.');
  }

  Future<void> createHotel(Map<String, dynamic> hotelData) async {
    await _apiClient.post('/hoteles', body: hotelData);
  }

  Future<void> updateHotel(int id, Map<String, dynamic> hotelData) async {
    await _apiClient.put('/hoteles/$id', body: hotelData);
  }

  Future<void> deleteHotel(int id) async {
    await _apiClient.delete('/hoteles/$id');
  }
}
