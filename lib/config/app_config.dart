class AppConfig {
  AppConfig._();

  static const String _defaultApiBaseUrl =
      'https://apihotel-nodejs.onrender.com/api';

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultApiBaseUrl,
  );
}
