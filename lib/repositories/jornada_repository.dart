// repositories/jornada_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class JornadaRepository {
  static const String _baseUrl = "http://10.0.2.2:8000";

  static final Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  // ============================================
  // 1. INICIAR JORNADA
  // ============================================
  static Future<Map<String, dynamic>> iniciarJornada({
    required String usuarioUsername,
    required String usuarioNombre,
    required String mesa,
  }) async {
    final url = Uri.parse('$_baseUrl/api/jornada/iniciar/');

    print('🟢 [JORNADA] Iniciando jornada para $usuarioUsername');
    print('🔗 URL: $url');

    try {
      final body = jsonEncode({
        'usuario_username': usuarioUsername,
        'usuario_nombre': usuarioNombre,
        'mesa': mesa,
      });

      final response = await http.post(url, headers: _headers, body: body);

      print('📥 Código: ${response.statusCode}');
      print('📥 Respuesta: ${response.body}');

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 201) {
        print('✅ Jornada iniciada correctamente');
        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData['data'],
        };
      } else if (response.statusCode == 400) {
        print('❌ Error 400: ${responseData['error']}');
        return {
          'success': false,
          'message': responseData['error'],
          'data': responseData['jornada_actual'] ?? null,
        };
      } else {
        print('⚠️ ERROR: ${response.statusCode}');
        return {'success': false, 'message': 'Error al iniciar jornada'};
      }
    } catch (e) {
      print('💥 ERROR: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // ============================================
  // 2. FINALIZAR JORNADA
  // ============================================
  static Future<Map<String, dynamic>> finalizarJornada({
    required String usuarioUsername,
  }) async {
    final url = Uri.parse('$_baseUrl/api/jornada/finalizar/');

    print('🔴 [JORNADA] Finalizando jornada para $usuarioUsername');
    print('🔗 URL: $url');

    try {
      final body = jsonEncode({'usuario_username': usuarioUsername});

      final response = await http.post(url, headers: _headers, body: body);

      print('📥 Código: ${response.statusCode}');
      print('📥 Respuesta: ${response.body}');

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        print('✅ Jornada finalizada correctamente');
        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData['data'],
        };
      } else if (response.statusCode == 400) {
        print('❌ Error 400: ${responseData['error']}');
        return {'success': false, 'message': responseData['error']};
      } else {
        print('⚠️ ERROR: ${response.statusCode}');
        return {'success': false, 'message': 'Error al finalizar jornada'};
      }
    } catch (e) {
      print('💥 ERROR: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // ============================================
  // 3. OBTENER JORNADA ACTUAL
  // ============================================
  static Future<Map<String, dynamic>> obtenerJornadaActual({
    required String usuarioUsername,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/api/jornada/actual/?usuario_username=$usuarioUsername',
    );

    print('📊 [JORNADA] Obteniendo jornada actual de $usuarioUsername');
    print('🔗 URL: $url');

    try {
      final response = await http.get(url, headers: _headers);

      print('📥 Código: ${response.statusCode}');
      print('📥 Respuesta: ${response.body}');

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        print('✅ Jornada actual obtenida correctamente');
        return {'success': true, 'data': responseData['data']};
      } else {
        print('⚠️ ERROR: ${response.statusCode}');
        return {'success': false, 'message': 'Error al obtener jornada actual'};
      }
    } catch (e) {
      print('💥 ERROR: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // ============================================
  // 4. OBTENER HISTORIAL DE JORNADAS
  // ============================================
  static Future<Map<String, dynamic>> obtenerHistorialJornadas({
    required String usuarioUsername,
    int limit = 30,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/api/jornada/historial/?usuario_username=$usuarioUsername&limit=$limit',
    );

    print('📊 [JORNADA] Obteniendo historial de $usuarioUsername');
    print('🔗 URL: $url');

    try {
      final response = await http.get(url, headers: _headers);

      print('📥 Código: ${response.statusCode}');
      print('📥 Respuesta: ${response.body}');

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        print('✅ Historial obtenido correctamente');
        return {'success': true, 'data': responseData['data']};
      } else {
        print('⚠️ ERROR: ${response.statusCode}');
        return {'success': false, 'message': 'Error al obtener historial'};
      }
    } catch (e) {
      print('💥 ERROR: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }
}
