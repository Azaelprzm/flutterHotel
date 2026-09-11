import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:movil_hotel/services/api_client.dart';
import 'package:movil_hotel/services/api_exception.dart';

void main() {
  group('ApiClient', () {
    test('decodifica respuestas exitosas', () async {
      final client = ApiClient(
        baseUrl: 'https://example.com/api',
        client: MockClient(
          (_) async => http.Response('{"id":1,"nombre":"Hotel Lux"}', 200),
        ),
      );

      final response = await client.get('/hoteles/1');

      expect(response, {'id': 1, 'nombre': 'Hotel Lux'});
    });

    test('envía el token de autorización', () async {
      final client = ApiClient(
        token: 'token-de-prueba',
        baseUrl: 'https://example.com/api',
        client: MockClient((request) async {
          expect(request.headers['authorization'], 'Bearer token-de-prueba');
          return http.Response('[]', 200);
        }),
      );

      await client.get('/hoteles');
    });

    test('convierte errores del servidor en mensajes legibles', () async {
      final client = ApiClient(
        baseUrl: 'https://example.com/api',
        client: MockClient(
          (_) async => http.Response('{"message":"No autorizado"}', 401),
        ),
      );

      expect(
        () => client.get('/hoteles'),
        throwsA(
          isA<ApiException>()
              .having((error) => error.statusCode, 'statusCode', 401)
              .having((error) => error.message, 'message', 'No autorizado'),
        ),
      );
    });
  });
}
