// repositories/jornada_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class JornadaRepository {
  static const String _baseUrl = "http://192.168.0.109:8000";

  static final Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  // ============================================
  // 1. INICIAR JORNADA  (POR MESA)
  // ============================================
  static Future<Map<String, dynamic>> iniciarJornada({
    required String mesa,
    String? usuarioUsername, // opcional (solo logs / UI)
    String? usuarioNombre,   // opcional (solo logs / UI)
  }) async {
    final url = Uri.parse('$_baseUrl/api/jornada/iniciar/');

    print('🟢 [JORNADA] Iniciando jornada (mesa=$mesa) usuario=${usuarioUsername ?? "-"}');
    print('🔗 URL: $url');

    try {
      final body = jsonEncode({
        'mesa': mesa, // ✅ lo que necesita el backend
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
          'message': responseData['error'] ?? 'No se pudo iniciar jornada',
          'data': responseData['data'], // ✅ aquí viene la jornada activa
        };
      } else {
        print('⚠️ ERROR: ${response.statusCode}');
        return {
          'success': false,
          'message': responseData['error'] ?? 'Error al iniciar jornada',
        };
      }
    } catch (e) {
      print('💥 ERROR: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // ============================================
  // 2. FINALIZAR JORNADA  (POR MESA)
  // ============================================
  static Future<Map<String, dynamic>> finalizarJornada({
    required String mesa,
    String? usuarioUsername, // opcional
  }) async {
    final url = Uri.parse('$_baseUrl/api/jornada/finalizar/');

    print('🔴 [JORNADA] Finalizando jornada (mesa=$mesa) usuario=${usuarioUsername ?? "-"}');
    print('🔗 URL: $url');

    try {
      final body = jsonEncode({'mesa': mesa}); // ✅ backend pide mesa

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
        return {
          'success': false,
          'message': responseData['error'] ?? 'Error al finalizar jornada',
        };
      }
    } catch (e) {
      print('💥 ERROR: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // ============================================
  // 3. OBTENER JORNADA ACTUAL  (POR MESA)
  // ============================================
  static Future<Map<String, dynamic>> obtenerJornadaActual({
    required String mesa,
    String? usuarioUsername, // opcional
  }) async {
    final url = Uri.parse('$_baseUrl/api/jornada/actual/')
        .replace(queryParameters: {'mesa': mesa});

    print('📊 [JORNADA] Obteniendo jornada actual (mesa=$mesa) usuario=${usuarioUsername ?? "-"}');
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
        return {
          'success': false,
          'message': responseData['error'] ?? 'Error al obtener jornada actual',
        };
      }
    } catch (e) {
      print('💥 ERROR: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // ============================================
  // 4. OBTENER HISTORIAL DE JORNADAS  (POR MESA)
  // ============================================
  static Future<Map<String, dynamic>> obtenerHistorialJornadas({
    required String mesa,
    int limit = 30,
    String? usuarioUsername, // opcional
  }) async {
    final url = Uri.parse('$_baseUrl/api/jornada/historial/')
        .replace(queryParameters: {'mesa': mesa, 'limit': '$limit'});

    print('📊 [JORNADA] Obteniendo historial (mesa=$mesa) usuario=${usuarioUsername ?? "-"}');
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
        return {
          'success': false,
          'message': responseData['error'] ?? 'Error al obtener historial',
        };
      }
    } catch (e) {
      print('💥 ERROR: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }
}
