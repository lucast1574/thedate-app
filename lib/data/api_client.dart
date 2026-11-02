import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../app_config.dart';

class ApiException implements Exception {
  const ApiException(this.message, [this.status = 0]);
  final String message;
  final int status;
  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client}) : client = client ?? http.Client();
  final http.Client client;
  String? token;
  Future<dynamic> request(
    String path, {
    String method = 'GET',
    Object? body,
  }) async {
    final uri = Uri.parse('${AppConfig.api}$path');
    final request = http.Request(method, uri)
      ..headers.addAll({
        'Accept': 'application/json',
        'User-Agent': '${AppConfig.product}/${Platform.operatingSystem}/1.0',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });
    if (body != null) request.body = jsonEncode(body);
    return _send(request);
  }

  Future<dynamic> uploadPhoto(Uint8List bytes) async {
    final request =
        http.MultipartRequest(
            'POST',
            Uri.parse('${AppConfig.api}/profile/avatar'),
          )
          ..headers.addAll({
            'Accept': 'application/json',
            'User-Agent':
                '${AppConfig.product}/${Platform.operatingSystem}/1.0',
            if (token != null) 'Authorization': 'Bearer $token',
          })
          ..files.add(
            http.MultipartFile.fromBytes(
              'photo',
              bytes,
              filename: 'profile-photo.png',
            ),
          );
    return _send(request);
  }

  Future<dynamic> _send(http.BaseRequest request) async {
    try {
      final response = await http.Response.fromStream(
        await client.send(request).timeout(const Duration(seconds: 20)),
      ).timeout(const Duration(seconds: 20));
      dynamic result;
      try {
        result = jsonDecode(response.body);
      } catch (_) {
        result = null;
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = switch (response.statusCode) {
          401 => 'Tu sesión terminó. Vuelve a entrar.',
          403 => 'Tu cuenta no tiene acceso a esta información.',
          429 => 'Espera un momento y vuelve a intentarlo.',
          _ => 'No pudimos cargar la información. Inténtalo de nuevo.',
        };
        throw ApiException(message, response.statusCode);
      }
      return result;
    } on TimeoutException {
      throw const ApiException(
        'La conexión tardó demasiado. Vuelve a intentarlo.',
      );
    } on SocketException {
      throw const ApiException(
        'Sin conexión. Revisa tu internet y vuelve a intentarlo.',
      );
    } on http.ClientException {
      throw const ApiException('No pudimos conectar. Vuelve a intentarlo.');
    }
  }
}
