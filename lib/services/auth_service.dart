import 'api_client.dart';
import 'api_exception.dart';

class AuthService {
  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<String> login(String email, String password) async {
    final response = await _apiClient.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );

    if (response is! Map<String, dynamic> || response['token'] is! String) {
      throw const ApiException('El servidor no devolvió una sesión válida.');
    }

    return response['token'] as String;
  }
}
