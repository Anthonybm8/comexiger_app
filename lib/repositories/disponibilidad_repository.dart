

import '../utils/api_client.dart';
import '../models/disponibilidad_model.dart';

class DisponibilidadRepository {
  // ============================================
  // 1. OBTENER TODAS LAS DISPONIBILIDADES
  // ============================================
  static Future<Map<String, dynamic>> obtenerTodasDisponibilidades({
    String? fecha,
    String? desde,
    String? hasta,
    String? ordenar,
    bool? reciente,
  }) async {
    final queryParams = <String, String>{};

    if (fecha != null && fecha.isNotEmpty) queryParams['fecha'] = fecha;

    if (desde != null && hasta != null && desde.isNotEmpty && hasta.isNotEmpty) {
      queryParams['desde'] = desde;
      queryParams['hasta'] = hasta;
    }

    if (ordenar != null && ordenar.isNotEmpty) {
      queryParams['ordenar'] = ordenar;
      if (reciente != null) queryParams['reciente'] = reciente.toString();
    }

    try {
      final res = await ApiClient.get(
        '/api/disponibilidades/',
        auth: true,
        query: queryParams.isEmpty ? null : queryParams,
      );

      final status = res['status'] as int;
      final data = res['data'] as Map<String, dynamic>;

      // Tu backend aquí devuelve LISTA (no objeto), así que ApiClient lo empaqueta como {'data': [...]}
      final rawList = data['data'];

      if (status == 200 && rawList is List) {
        return {
          'success': true,
          'disponibilidades': rawList.map((d) => DisponibilidadModel.fromJson(d)).toList(),
          'count': rawList.length,
        };
      }

      return {
        'success': false,
        'message': data['error'] ?? 'Error al obtener disponibilidades ($status)',
        'raw': data,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // ============================================
  // 2. OBTENER ESTADÍSTICAS
  // ============================================
  static Future<Map<String, dynamic>> obtenerEstadisticas() async {
    try {
      final res = await ApiClient.get('/api/disponibilidades/stats/', auth: true);

      final status = res['status'] as int;
      final data = res['data'] as Map<String, dynamic>;

      if (status == 200) {
        // aquí tu backend devuelve objeto, no lista
        final raw = data['data'] ?? data;
        return {
          'success': true,
          'estadisticas': EstadisticasDisponibilidad.fromJson(raw),
        };
      }

      return {
        'success': false,
        'message': data['error'] ?? 'Error al obtener estadísticas ($status)',
        'raw': data,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // ============================================
  // 3. OBTENER DISPONIBILIDADES POR MESA
  // ============================================
  static Future<Map<String, dynamic>> obtenerDisponibilidadesPorMesa(String mesa) async {
    try {
      final res = await ApiClient.get(
        '/api/disponibilidad/por_mesa/',
        auth: true,
        query: {'mesa': mesa},
      );

      final status = res['status'] as int;
      final data = res['data'] as Map<String, dynamic>;
      final rawList = data['data'];

      if (status == 200 && rawList is List) {
        return {
          'success': true,
          'disponibilidades': rawList.map((d) => DisponibilidadModel.fromJson(d)).toList(),
          'count': rawList.length,
        };
      }

      return {
        'success': false,
        'message': data['error'] ?? 'Error al obtener disponibilidades por mesa ($status)',
        'raw': data,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // ============================================
  // 4. OBTENER DISPONIBILIDADES ACTIVAS
  // ============================================
  static Future<Map<String, dynamic>> obtenerDisponibilidadesActivas() async {
    try {
      final res = await ApiClient.get('/api/disponibilidad/activos/', auth: true);

      final status = res['status'] as int;
      final data = res['data'] as Map<String, dynamic>;
      final rawList = data['data'];

      if (status == 200 && rawList is List) {
        return {
          'success': true,
          'disponibilidades': rawList.map((d) => DisponibilidadModel.fromJson(d)).toList(),
          'count': rawList.length,
        };
      }

      return {
        'success': false,
        'message': data['error'] ?? 'Error al obtener disponibilidades activas ($status)',
        'raw': data,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // ============================================
  // 5. REGISTRAR SALIDA (RESTAR STOCK)
  // ============================================
  static Future<Map<String, dynamic>> registrarSalida({
    required String qrId,
    required String variedad,
    required String medida,
  }) async {
    try {
      final res = await ApiClient.post(
        '/api/disponibilidades/salida/',
        auth: true,
        body: {
          'qr_id': qrId,
          'variedad': variedad,
          'medida': medida,
        },
      );

      final status = res['status'] as int;
      final data = res['data'] as Map<String, dynamic>;

      // tu backend aquí devuelve objeto de disponibilidad
      final raw = data['data'] ?? data;

      if (status == 200) {
        return {
          'success': true,
          'message': 'Stock actualizado correctamente',
          'disponibilidad': DisponibilidadModel.fromJson(raw),
        };
      }

      if (status == 409) {
        return {
          'success': false,
          'message': data['error'] ?? 'Este QR ya fue utilizado',
        };
      }

      if (status == 400) {
        return {
          'success': false,
          'message': data['error'] ?? 'Datos incompletos',
        };
      }

      return {
        'success': false,
        'message': data['error'] ?? 'Error al registrar salida ($status)',
        'raw': data,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }
}
