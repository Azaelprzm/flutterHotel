import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({
    this.token,
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? _sharedClient,
        _baseUrl = _normalizeBaseUrl(baseUrl ?? AppConfig.apiBaseUrl);

  static const Duration _timeout = Duration(seconds: 20);
  static final http.Client _sharedClient = http.Client();

  final String? token;
  final http.Client _client;
  final String _baseUrl;

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (token != null && token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<dynamic> get(String path) {
    return _send(() => _client.get(_uri(path), headers: _headers));
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) {
    return _send(
      () => _client.post(
        _uri(path),
        headers: _headers,
        body: body == null ? null : jsonEncode(body),
      ),
    );
  }

  Future<dynamic> put(String path, {required Map<String, dynamic> body}) {
    return _send(
      () => _client.put(
        _uri(path),
        headers: _headers,
        body: jsonEncode(body),
      ),
    );
  }

  Future<dynamic> delete(String path) {
    return _send(() => _client.delete(_uri(path), headers: _headers));
  }

  Uri _uri(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$_baseUrl$normalizedPath');
  }

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(_timeout);
      final body = _decodeBody(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      }

      throw ApiException(
        _errorMessage(body, response.statusCode),
        statusCode: response.statusCode,
      );
    } on TimeoutException {
      throw const ApiException(
        'El servidor tardó demasiado en responder. Inténtalo nuevamente.',
      );
    } on http.ClientException {
      throw const ApiException(
        'No fue posible conectarse con el servidor. Verifica tu conexión.',
      );
    } on FormatException {
      throw const ApiException('El servidor devolvió una respuesta no válida.');
    }
  }

  static dynamic _decodeBody(String responseBody) {
    if (responseBody.trim().isEmpty) {
      return null;
    }
    return jsonDecode(responseBody);
  }

  static String _errorMessage(dynamic body, int statusCode) {
    if (body is Map<String, dynamic>) {
      final message = body['message'] ?? body['error'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    if (statusCode == 401) {
      return 'Tu sesión no es válida o ha expirado.';
    }
    if (statusCode == 403) {
      return 'No tienes permiso para realizar esta acción.';
    }
    if (statusCode == 404) {
      return 'No se encontró el recurso solicitado.';
    }

    return 'El servidor no pudo completar la solicitud ($statusCode).';
  }

  static String _normalizeBaseUrl(String value) {
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }
}
