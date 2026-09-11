import 'api_client.dart';
import 'api_exception.dart';

class ClienteService {
  ClienteService(String token) : _apiClient = ApiClient(token: token);

  final ApiClient _apiClient;

  Future<List<dynamic>> fetchClientes() async {
    final response = await _apiClient.get('/clientes');
    if (response is List<dynamic>) {
      return response;
    }
    throw const ApiException(
        'La lista de clientes no tiene un formato válido.');
  }

  Future<void> createCliente(Map<String, dynamic> clienteData) async {
    await _apiClient.post('/clientes', body: clienteData);
  }

  Future<void> updateCliente(
    int id,
    Map<String, dynamic> clienteData,
  ) async {
    await _apiClient.put('/clientes/$id', body: clienteData);
  }

  Future<void> deleteCliente(int id) async {
    await _apiClient.delete('/clientes/$id');
  }
}
