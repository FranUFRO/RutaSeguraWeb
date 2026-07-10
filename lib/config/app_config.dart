class AppConfig {
  const AppConfig._();

  static const _configuredApiUrl = String.fromEnvironment('API_URL', defaultValue: '/api');

  static String get apiBaseUrl {
    var value = _configuredApiUrl.trim();
    while (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }
    if (!value.endsWith('/api')) {
      value = '$value/api';
    }
    return value;
  }

  static bool get usesExternalApi => Uri.tryParse(apiBaseUrl)?.hasAbsolutePath == true &&
      Uri.tryParse(apiBaseUrl)?.hasScheme == true;
}
