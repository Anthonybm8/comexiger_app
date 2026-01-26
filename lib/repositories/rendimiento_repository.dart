// lib/repositories/rendimiento_repository.dart
// ignore_for_file: avoid_print

import '../utils/api_client.dart';
import '../models/rendimiento_model.dart';

class RendimientoRepository {
  // ============================================
  // 1. OBTENER TODOS LOS RENDIMIENTOS (CON FILTROS)
  // ============================================
  static Future<Map<String, dynamic>> obtenerTodosRendimientos({
    String? fecha,
    String? desde,
    String? hasta,
    String? ordenar,
    bool? reciente,
    String? mesa, // filtro por mesa
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

    if (mesa != null && mesa.isNotEmpty) queryParams['mesa'] = mesa;

    print('📊 [REPOSITORY] Obteniendo rendimientos');
    print('🧾 Query: $queryParams');

    try {
      final res = await ApiClient.get(
        '/api/rendimientos/',
        auth: true,
        query: queryParams.isEmpty ? null : queryParams,
      );

      final status = res['status'] as int;
      final data = res['data'];

      print('📥 Código: $status');
      print('📥 Respuesta: $data');

      // ✅ Tu backend aquí devuelve LISTA (no objeto)
      // ApiClient la envuelve como: {'data': [ ... ]}
      if (status == 200) {
        final rawList = (data is Map<String, dynamic>) ? data['data'] : null;

        if (rawList is List) {
          return {
            'success': true,
            'rendimientos': rawList.map((r) => RendimientoModel.fromJson(r)).toList(),
            'count': rawList.length,
          };
        }

        // si por alguna razón no viene envuelto
        if (data is List) {
          return {
            'success': true,
            'rendimientos': data.map((r) => RendimientoModel.fromJson(r)).toList(),
            'count': data.length,
          };
        }
      }

      // si falla
      final msg = (data is Map<String, dynamic>) ? (data['error'] ?? 'Error ($status)') : 'Error ($status)';
      return {'success': false, 'message': msg, 'raw': data};
    } catch (e) {
      return {'success': false, 'message': 'Error al obtener rendimientos: $e'};
    }
  }

  // ============================================
  // 2. OBTENER ESTADÍSTICAS
  // ============================================
  static Future<Map<String, dynamic>> obtenerEstadisticas() async {
    print('📈 [REPOSITORY] Obteniendo estadísticas de rendimientos');

    try {
      final res = await ApiClient.get('/api/rendimientos/stats/', auth: true);

      final status = res['status'] as int;
      final data = res['data'] as Map<String, dynamic>;

      print('📥 Código: $status');
      print('📥 Respuesta: $data');

      if (status == 200) {
        final raw = data['data'] ?? data;
        return {
          'success': true,
          'estadisticas': EstadisticasRendimiento.fromJson(raw),
        };
      }

      return {
        'success': false,
        'message': data['error'] ?? 'Error al obtener estadísticas ($status)',
        'raw': data,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error al obtener estadísticas: $e'};
    }
  }

  // ============================================
  // 3. OBTENER RENDIMIENTOS POR MESA
  // ============================================
  static Future<Map<String, dynamic>> obtenerRendimientosPorMesa(String mesa) async {
    print('📊 [REPOSITORY] Obteniendo rendimientos por mesa: $mesa');

    try {
      final res = await ApiClient.get(
        '/api/rendimiento/por_mesa/',
        auth: true,
        query: {'mesa': mesa},
      );

      final status = res['status'] as int;
      final data = res['data'];

      print('📥 Código: $status');
      print('📥 Respuesta: $data');

      if (status == 200) {
        final rawList = (data is Map<String, dynamic>) ? data['data'] : null;

        if (rawList is List) {
          return {
            'success': true,
            'rendimientos': rawList.map((r) => RendimientoModel.fromJson(r)).toList(),
            'count': rawList.length,
          };
        }

        if (data is List) {
          return {
            'success': true,
            'rendimientos': data.map((r) => RendimientoModel.fromJson(r)).toList(),
            'count': data.length,
          };
        }
      }

      final msg = (data is Map<String, dynamic>) ? (data['error'] ?? 'Error ($status)') : 'Error ($status)';
      return {'success': false, 'message': msg, 'raw': data};
    } catch (e) {
      return {'success': false, 'message': 'Error al obtener rendimientos por mesa: $e'};
    }
  }

  // ============================================
  // 4. OBTENER RENDIMIENTOS ACTIVOS
  // ============================================
  static Future<Map<String, dynamic>> obtenerRendimientosActivos() async {
    print('📊 [REPOSITORY] Obteniendo rendimientos activos');

    try {
      final res = await ApiClient.get('/api/rendimiento/activos/', auth: true);

      final status = res['status'] as int;
      final data = res['data'];

      print('📥 Código: $status');
      print('📥 Respuesta: $data');

      if (status == 200) {
        final rawList = (data is Map<String, dynamic>) ? data['data'] : null;

        if (rawList is List) {
          return {
            'success': true,
            'rendimientos': rawList.map((r) => RendimientoModel.fromJson(r)).toList(),
            'count': rawList.length,
          };
        }

        if (data is List) {
          return {
            'success': true,
            'rendimientos': data.map((r) => RendimientoModel.fromJson(r)).toList(),
            'count': data.length,
          };
        }
      }

      final msg = (data is Map<String, dynamic>) ? (data['error'] ?? 'Error ($status)') : 'Error ($status)';
      return {'success': false, 'message': msg, 'raw': data};
    } catch (e) {
      return {'success': false, 'message': 'Error al obtener rendimientos activos: $e'};
    }
  }

  // ============================================
  // 5. CREAR NUEVO RENDIMIENTO (QR)
  // ============================================
  static Future<Map<String, dynamic>> crearRendimientoQR({
    required String qrId,
    required String numeroMesa,
    String? fechaEntrada,
  }) async {
    print('📊 [REPOSITORY] Creando rendimiento desde QR');
    print('📋 QR: $qrId, Mesa: $numeroMesa');

    try {
      final body = <String, dynamic>{
        'qr_id': qrId,
        'numero_mesa': numeroMesa,
        if (fechaEntrada != null && fechaEntrada.isNotEmpty) 'fecha_entrada': fechaEntrada,
      };

      final res = await ApiClient.post(
        '/api/rendimientos/',
        auth: true,
        body: body,
      );

      final status = res['status'] as int;
      final data = res['data'];

      print('📥 Código: $status');
      print('📥 Respuesta: $data');

      // Tu backend aquí parece devolver un objeto rendimiento directo
      // ApiClient lo envuelve como {'data': {...}} o te devuelve {...}
      if (status == 201 || status == 200) {
        final raw = (data is Map<String, dynamic>) ? (data['data'] ?? data) : data;

        if (raw is Map<String, dynamic>) {
          return {
            'success': true,
            'rendimiento': RendimientoModel.fromJson(raw),
            'message': status == 201 ? 'Nuevo rendimiento creado' : 'Rendimiento actualizado',
          };
        }

        return {
          'success': true,
          'message': status == 201 ? 'Nuevo rendimiento creado' : 'Rendimiento actualizado',
        };
      }

      if (status == 409) {
        return {'success': false, 'message': 'Este QR ya fue utilizado anteriormente'};
      }

      if (status == 400) {
        final msg = (data is Map<String, dynamic>) ? (data['error'] ?? 'Datos incompletos') : 'Datos incompletos';
        return {'success': false, 'message': msg};
      }

      final msg = (data is Map<String, dynamic>) ? (data['error'] ?? 'Error ($status)') : 'Error ($status)';
      return {'success': false, 'message': msg, 'raw': data};
    } catch (e) {
      return {'success': false, 'message': 'Error al crear rendimiento: $e'};
    }
  }
}
