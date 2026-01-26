// lib/utils/api_client.dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'usuario_preferences.dart';

class ApiClient {
  ApiClient._();

  static const String baseUrl = "http://10.198.32.101:8000";

  static const Map<String, String> _baseHeaders = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  static Uri _u(String path, [Map<String, String>? query]) {
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$p').replace(queryParameters: query);
  }

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final h = Map<String, String>.from(_baseHeaders);
    if (!auth) return h;

    final token = await UsuarioPreferences.obtenerAccessToken();
    if (token != null && token.trim().isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  static Map<String, dynamic> _decode(http.Response r) {
    try {
      final txt = utf8.decode(r.bodyBytes);
      final d = jsonDecode(txt);
      return d is Map<String, dynamic> ? d : {'data': d};
    } catch (_) {
      return {'raw': utf8.decode(r.bodyBytes)};
    }
  }

  // POST /api/token/refresh/
  static Future<bool> _refreshToken() async {
    final refresh = await UsuarioPreferences.obtenerRefreshToken();
    if (refresh == null || refresh.isEmpty) return false;

    final url = _u('/api/token/refresh/');

    try {
      final r = await http.post(
        url,
        headers: _baseHeaders,
        body: jsonEncode({'refresh': refresh}),
      );

      final data = _decode(r);
      final access = (data['access'] ?? '').toString();

      if (r.statusCode == 200 && access.isNotEmpty) {
        await UsuarioPreferences.guardarTokens(access: access, refresh: refresh);
        print('✅ Token refrescado');
        return true;
      }

      print('❌ Refresh falló: ${r.statusCode} - $data');
      return false;
    } catch (e) {
      print('❌ Error refresh: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> request(
    String method,
    String path, {
    bool auth = true,
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) async {
    final url = _u(path, query);
    var h = await _headers(auth: auth);

    Future<http.Response> callWithHeaders(Map<String, String> headers) async {
      switch (method.toUpperCase()) {
        case 'GET':
          return http.get(url, headers: headers);
        case 'POST':
          return http.post(url, headers: headers, body: jsonEncode(body ?? {}));
        case 'PUT':
          return http.put(url, headers: headers, body: jsonEncode(body ?? {}));
        case 'PATCH':
          return http.patch(url, headers: headers, body: jsonEncode(body ?? {}));
        case 'DELETE':
          return http.delete(url, headers: headers);
        default:
          throw Exception('Método HTTP no soportado: $method');
      }
    }

    var r = await callWithHeaders(h);
    var data = _decode(r);

    // 401/403 -> refresh 1 vez y reintenta
    if (auth && (r.statusCode == 401 || r.statusCode == 403)) {
      final ok = await _refreshToken();
      if (ok) {
        h = await _headers(auth: auth);
        r = await callWithHeaders(h);
        data = _decode(r);
      }
    }

    return {
      'ok': r.statusCode >= 200 && r.statusCode < 300,
      'status': r.statusCode,
      'data': data,
    };
  }

  static Future<Map<String, dynamic>> get(
    String path, {
    bool auth = true,
    Map<String, String>? query,
  }) =>
      request('GET', path, auth: auth, query: query);

  static Future<Map<String, dynamic>> post(
    String path, {
    bool auth = true,
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) =>
      request('POST', path, auth: auth, query: query, body: body);
}
