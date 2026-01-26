

import '../utils/api_client.dart';

class JornadaRepository {
  // ============================================
  // 1. INICIAR JORNADA (POR MESA)
  // ============================================
  static Future<Map<String, dynamic>> iniciarJornada({
    required String mesa,
    String? usuarioUsername,
    String? usuarioNombre,
  }) async {
    print('🟢 [JORNADA] Iniciando jornada (mesa=$mesa) usuario=${usuarioUsername ?? "-"}');

    try {
      final res = await ApiClient.post(
        '/api/jornada/iniciar/',
        auth: true,
        body: {'mesa': mesa},
      );

      final status = res['status'] as int;
      final responseData = res['data'] as Map<String, dynamic>;

      print('📥 Código: $status');
      print('📥 Respuesta: $responseData');

      if (status == 201) {
        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData['data'],
        };
      }

      // backend puede responder 400/409 con jornada activa en "data"
      if (status == 409 || status == 400) {
        return {
          'success': false,
          'message': responseData['error'] ?? 'No se pudo iniciar jornada',
          'data': responseData['data'],
        };
      }

      return {
        'success': false,
        'message': responseData['error'] ?? 'Error al iniciar jornada ($status)',
      };
    } catch (e) {
      print('💥 ERROR: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // ============================================
  // 2. FINALIZAR JORNADA (POR MESA)
  // ============================================
  static Future<Map<String, dynamic>> finalizarJornada({
    required String mesa,
    String? usuarioUsername,
  }) async {
    print('🔴 [JORNADA] Finalizando jornada (mesa=$mesa) usuario=${usuarioUsername ?? "-"}');

    try {
      final res = await ApiClient.post(
        '/api/jornada/finalizar/',
        auth: true,
        body: {'mesa': mesa},
      );

      final status = res['status'] as int;
      final responseData = res['data'] as Map<String, dynamic>;

      print('📥 Código: $status');
      print('📥 Respuesta: $responseData');

      if (status == 200) {
        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData['data'],
        };
      }

      return {
        'success': false,
        'message': responseData['error'] ?? 'Error al finalizar jornada ($status)',
      };
    } catch (e) {
      print('💥 ERROR: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // ============================================
  // 3. OBTENER JORNADA ACTUAL (POR MESA)
  // ============================================
  static Future<Map<String, dynamic>> obtenerJornadaActual({
    required String mesa,
    String? usuarioUsername,
  }) async {
    print('📊 [JORNADA] Obteniendo jornada actual (mesa=$mesa) usuario=${usuarioUsername ?? "-"}');

    try {
      final res = await ApiClient.get(
        '/api/jornada/actual/',
        auth: true,
        query: {'mesa': mesa},
      );

      final status = res['status'] as int;
      final responseData = res['data'] as Map<String, dynamic>;

      print('📥 Código: $status');
      print('📥 Respuesta: $responseData');

      if (status == 200) {
        return {'success': true, 'data': responseData['data']};
      }

      return {
        'success': false,
        'message': responseData['error'] ?? 'Error al obtener jornada actual ($status)',
      };
    } catch (e) {
      print('💥 ERROR: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // ============================================
  // 4. OBTENER HISTORIAL (POR MESA)
  // ============================================
  static Future<Map<String, dynamic>> obtenerHistorialJornadas({
    required String mesa,
    int limit = 30,
    String? usuarioUsername,
  }) async {
    print('📊 [JORNADA] Obteniendo historial (mesa=$mesa) usuario=${usuarioUsername ?? "-"}');

    try {
      final res = await ApiClient.get(
        '/api/jornada/historial/',
        auth: true,
        query: {'mesa': mesa, 'limit': '$limit'},
      );

      final status = res['status'] as int;
      final responseData = res['data'] as Map<String, dynamic>;

      print('📥 Código: $status');
      print('📥 Respuesta: $responseData');

      if (status == 200) {
        return {'success': true, 'data': responseData['data']};
      }

      return {
        'success': false,
        'message': responseData['error'] ?? 'Error al obtener historial ($status)',
      };
    } catch (e) {
      print('💥 ERROR: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }
}
