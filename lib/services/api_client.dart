import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../config/app_config.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String? bearerToken;
  void Function()? onUnauthorized;

  Uri uri(String path) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('${AppConfig.apiBaseUrl}$cleanPath');
  }

  Map<String, String> _headers({bool jsonBody = true}) => {
        'Accept': 'application/json',
        if (jsonBody) 'Content-Type': 'application/json',
        if (bearerToken != null) 'Authorization': 'Bearer $bearerToken',
      };

  Future<Map<String, dynamic>> get(String path) async =>
      _decode(await _client.get(uri(path), headers: _headers()).timeout(const Duration(seconds: 20)));

  Future<Map<String, dynamic>> post(String path, [Map<String, dynamic>? body]) async => _decode(
        await _client
            .post(uri(path), headers: _headers(), body: jsonEncode(body ?? const {}))
            .timeout(const Duration(seconds: 20)),
      );

  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body) async => _decode(
        await _client
            .patch(uri(path), headers: _headers(), body: jsonEncode(body))
            .timeout(const Duration(seconds: 20)),
      );

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async => _decode(
        await _client
            .put(uri(path), headers: _headers(), body: jsonEncode(body))
            .timeout(const Duration(seconds: 20)),
      );

  Future<Map<String, dynamic>> delete(String path) async =>
      _decode(await _client.delete(uri(path), headers: _headers()).timeout(const Duration(seconds: 20)));

  Future<Map<String, dynamic>> multipart(
    String path,
    Map<String, String> fields, {
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    final request = http.MultipartRequest('POST', uri(path));
    request.headers.addAll(_headers(jsonBody: false));
    request.fields.addAll(fields);
    if (fileBytes != null && fileName != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'certificado',
        fileBytes,
        filename: fileName,
        contentType: MediaType('application', 'pdf'),
      ));
    }
    final streamed = await _client.send(request).timeout(const Duration(seconds: 30));
    return _decode(await http.Response.fromStream(streamed));
  }

  Map<String, dynamic> _decode(http.Response response) {
    dynamic decoded;
    try {
      decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      decoded = <String, dynamic>{'message': response.body};
    }
    final data = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{'data': decoded};
    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.statusCode == 401) onUnauthorized?.call();
      final raw = data['message'] ?? data['error'] ?? 'No fue posible completar la solicitud.';
      final message = raw is List ? raw.join('\n') : raw.toString();
      throw ApiException(message, statusCode: response.statusCode);
    }
    return data;
  }
}
