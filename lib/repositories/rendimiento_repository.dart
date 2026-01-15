// repositories/rendimiento_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/rendimiento_model.dart';

class RendimientoRepository {
  static const String _baseUrl = "http://10.0.2.2:8000";

  static final Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  // ============================================
  // 1. OBTENER TODOS LOS RENDIMIENTOS
  // ============================================
  static Future<Map<String, dynamic>> obtenerTodosRendimientos({
    String? fecha,
    String? desde,
    String? hasta,
    String? ordenar,
    bool? reciente,
  }) async {
    String url = '$_baseUrl/api/rendimientos/';
    final Map<String, String> queryParams = {};

    if (fecha != null && fecha.isNotEmpty) {
      queryParams['fecha'] = fecha;
    }
    if (desde != null &&
        hasta != null &&
        desde.isNotEmpty &&
        hasta.isNotEmpty) {
      queryParams['desde'] = desde;
      queryParams['hasta'] = hasta;
    }
    if (ordenar != null && ordenar.isNotEmpty) {
      queryParams['ordenar'] = ordenar;
      if (reciente != null) {
        queryParams['reciente'] = reciente.toString();
      }
    }

    if (queryParams.isNotEmpty) {
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      url = uri.toString();
    }

    print('📊 [REPOSITORY] Obteniendo rendimientos');
    print('🔗 URL: $url');

    try {
      final response = await http.get(Uri.parse(url), headers: _headers);

      print('📥 Código de estado: ${response.statusCode}');
      print('📥 Respuesta: ${response.body}');

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        print('✅ Rendimientos obtenidos correctamente');
        final List<dynamic> rendimientosData = responseData;
        return {
          'success': true,
          'rendimientos': rendimientosData
              .map((r) => RendimientoModel.fromJson(r))
              .toList(),
          'count': rendimientosData.length,
        };
      } else {
        print('❌ Error al obtener rendimientos');
        return {
          'success': false,
          'message': 'Error al obtener rendimientos: ${response.statusCode}',
        };
      }
    } on http.ClientException catch (e) {
      print('💥 CLIENT EXCEPTION: ${e.message}');
      return {'success': false, 'message': 'Error de conexión: ${e.message}'};
    } on FormatException catch (e) {
      print('💥 FORMAT EXCEPTION: ${e.message}');
      return {'success': false, 'message': 'Error en formato de respuesta'};
    } catch (e) {
      print('💥 ERROR INESPERADO: $e');
      return {'success': false, 'message': 'Error inesperado: $e'};
    }
  }

  // ============================================
  // 2. OBTENER ESTADÍSTICAS
  // ============================================
  static Future<Map<String, dynamic>> obtenerEstadisticas() async {
    final url = Uri.parse('$_baseUrl/api/rendimientos/stats/');

    print('📈 [REPOSITORY] Obteniendo estadísticas');
    print('🔗 URL: $url');

    try {
      final response = await http.get(url, headers: _headers);

      print('📥 Código de estado: ${response.statusCode}');
      print('📥 Respuesta: ${response.body}');

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        print('✅ Estadísticas obtenidas correctamente');
        return {
          'success': true,
          'estadisticas': EstadisticasRendimiento.fromJson(responseData),
        };
      } else {
        print('❌ Error al obtener estadísticas');
        return {
          'success': false,
          'message': 'Error al obtener estadísticas: ${response.statusCode}',
        };
      }
    } on http.ClientException catch (e) {
      print('💥 CLIENT EXCEPTION: ${e.message}');
      return {'success': false, 'message': 'Error de conexión: ${e.message}'};
    } on FormatException catch (e) {
      print('💥 FORMAT EXCEPTION: ${e.message}');
      return {'success': false, 'message': 'Error en formato de respuesta'};
    } catch (e) {
      print('💥 ERROR INESPERADO: $e');
      return {'success': false, 'message': 'Error inesperado: $e'};
    }
  }

  // ============================================
  // 3. OBTENER RENDIMIENTOS POR MESA
  // ============================================
  static Future<Map<String, dynamic>> obtenerRendimientosPorMesa(
    String mesa,
  ) async {
    final url = Uri.parse('$_baseUrl/api/rendimiento/por_mesa/?mesa=$mesa');

    print('📊 [REPOSITORY] Obteniendo rendimientos por mesa: $mesa');
    print('🔗 URL: $url');

    try {
      final response = await http.get(url, headers: _headers);

      print('📥 Código de estado: ${response.statusCode}');
      print('📥 Respuesta: ${response.body}');

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        print('✅ Rendimientos por mesa obtenidos correctamente');
        final List<dynamic> rendimientosData = responseData;
        return {
          'success': true,
          'rendimientos': rendimientosData
              .map((r) => RendimientoModel.fromJson(r))
              .toList(),
          'count': rendimientosData.length,
        };
      } else {
        print('❌ Error al obtener rendimientos por mesa');
        return {
          'success': false,
          'message':
              'Error al obtener rendimientos por mesa: ${responseData['error']}',
        };
      }
    } on http.ClientException catch (e) {
      print('💥 CLIENT EXCEPTION: ${e.message}');
      return {'success': false, 'message': 'Error de conexión: ${e.message}'};
    } on FormatException catch (e) {
      print('💥 FORMAT EXCEPTION: ${e.message}');
      return {'success': false, 'message': 'Error en formato de respuesta'};
    } catch (e) {
      print('💥 ERROR INESPERADO: $e');
      return {'success': false, 'message': 'Error inesperado: $e'};
    }
  }

  // ============================================
  // 4. OBTENER RENDIMIENTOS ACTIVOS
  // ============================================
  static Future<Map<String, dynamic>> obtenerRendimientosActivos() async {
    final url = Uri.parse('$_baseUrl/api/rendimiento/activos/');

    print('📊 [REPOSITORY] Obteniendo rendimientos activos');
    print('🔗 URL: $url');

    try {
      final response = await http.get(url, headers: _headers);

      print('📥 Código de estado: ${response.statusCode}');
      print('📥 Respuesta: ${response.body}');

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        print('✅ Rendimientos activos obtenidos correctamente');
        final List<dynamic> rendimientosData = responseData;
        return {
          'success': true,
          'rendimientos': rendimientosData
              .map((r) => RendimientoModel.fromJson(r))
              .toList(),
          'count': rendimientosData.length,
        };
      } else {
        print('❌ Error al obtener rendimientos activos');
        return {
          'success': false,
          'message':
              'Error al obtener rendimientos activos: ${response.statusCode}',
        };
      }
    } on http.ClientException catch (e) {
      print('💥 CLIENT EXCEPTION: ${e.message}');
      return {'success': false, 'message': 'Error de conexión: ${e.message}'};
    } on FormatException catch (e) {
      print('💥 FORMAT EXCEPTION: ${e.message}');
      return {'success': false, 'message': 'Error en formato de respuesta'};
    } catch (e) {
      print('💥 ERROR INESPERADO: $e');
      return {'success': false, 'message': 'Error inesperado: $e'};
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
    final url = Uri.parse('$_baseUrl/api/rendimientos/');

    print('📊 [REPOSITORY] Creando nuevo rendimiento desde QR');
    print('🔗 URL: $url');
    print('📋 QR: $qrId, Mesa: $numeroMesa');

    try {
      final body = jsonEncode({
        'qr_id': qrId,
        'numero_mesa': numeroMesa,
        if (fechaEntrada != null) 'fecha_entrada': fechaEntrada,
      });

      final response = await http.post(url, headers: _headers, body: body);

      print('📥 Código de estado: ${response.statusCode}');
      print('📥 Respuesta: ${response.body}');

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Rendimiento creado/actualizado correctamente');
        return {
          'success': true,
          'rendimiento': RendimientoModel.fromJson(responseData),
          'message': response.statusCode == 201
              ? 'Nuevo rendimiento creado'
              : 'Rendimiento actualizado',
        };
      } else if (response.statusCode == 409) {
        print('❌ QR ya utilizado');
        return {
          'success': false,
          'message': 'Este QR ya fue utilizado anteriormente',
        };
      } else if (response.statusCode == 400) {
        print('❌ Error 400: ${responseData['error']}');
        return {
          'success': false,
          'message': responseData['error'] ?? 'Datos incompletos',
        };
      } else {
        print('⚠️ ERROR: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Error al crear rendimiento: ${response.statusCode}',
        };
      }
    } on http.ClientException catch (e) {
      print('💥 CLIENT EXCEPTION: ${e.message}');
      return {'success': false, 'message': 'Error de conexión: ${e.message}'};
    } on FormatException catch (e) {
      print('💥 FORMAT EXCEPTION: ${e.message}');
      return {'success': false, 'message': 'Error en formato de respuesta'};
    } catch (e) {
      print('💥 ERROR INESPERADO: $e');
      return {'success': false, 'message': 'Error inesperado: $e'};
    }
  }
}
