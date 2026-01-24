// repositories/disponibilidad_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/disponibilidad_model.dart';

class DisponibilidadRepository {
  static const String _baseUrl = "http://10.0.2.2:8000";

  static final Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

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
    String url = '$_baseUrl/api/disponibilidades/';
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

    try {
      final response = await http.get(Uri.parse(url), headers: _headers);
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        final List<dynamic> disponibilidadesData = responseData;
        return {
          'success': true,
          'disponibilidades': disponibilidadesData
              .map((d) => DisponibilidadModel.fromJson(d))
              .toList(),
          'count': disponibilidadesData.length,
        };
      } else {
        return {
          'success': false,
          'message':
              'Error al obtener disponibilidades: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // ============================================
  // 2. OBTENER ESTADÍSTICAS
  // ============================================
  static Future<Map<String, dynamic>> obtenerEstadisticas() async {
    final url = Uri.parse('$_baseUrl/api/disponibilidades/stats/');

    try {
      final response = await http.get(url, headers: _headers);
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'estadisticas': EstadisticasDisponibilidad.fromJson(responseData),
        };
      } else {
        return {
          'success': false,
          'message': 'Error al obtener estadísticas: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // ============================================
  // 3. OBTENER DISPONIBILIDADES POR MESA
  // ============================================
  static Future<Map<String, dynamic>> obtenerDisponibilidadesPorMesa(
    String mesa,
  ) async {
    final url = Uri.parse('$_baseUrl/api/disponibilidad/por_mesa/?mesa=$mesa');

    try {
      final response = await http.get(url, headers: _headers);
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        final List<dynamic> disponibilidadesData = responseData;
        return {
          'success': true,
          'disponibilidades': disponibilidadesData
              .map((d) => DisponibilidadModel.fromJson(d))
              .toList(),
          'count': disponibilidadesData.length,
        };
      } else {
        return {
          'success': false,
          'message':
              'Error al obtener disponibilidades por mesa: ${responseData['error']}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // ============================================
  // 4. OBTENER DISPONIBILIDADES ACTIVAS
  // ============================================
  static Future<Map<String, dynamic>> obtenerDisponibilidadesActivas() async {
    final url = Uri.parse('$_baseUrl/api/disponibilidad/activos/');

    try {
      final response = await http.get(url, headers: _headers);
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        final List<dynamic> disponibilidadesData = responseData;
        return {
          'success': true,
          'disponibilidades': disponibilidadesData
              .map((d) => DisponibilidadModel.fromJson(d))
              .toList(),
          'count': disponibilidadesData.length,
        };
      } else {
        return {
          'success': false,
          'message':
              'Error al obtener disponibilidades activas: ${response.statusCode}',
        };
      }
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
    final url = Uri.parse('$_baseUrl/api/disponibilidades/salida/');

    try {
      final body = jsonEncode({
        'qr_id': qrId,
        'variedad': variedad,
        'medida': medida,
      });

      final response = await http.post(url, headers: _headers, body: body);
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Stock actualizado correctamente',
          'disponibilidad': DisponibilidadModel.fromJson(responseData),
        };
      } else if (response.statusCode == 409) {
        return {
          'success': false,
          'message': responseData['error'] ?? 'Este QR ya fue utilizado',
        };
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'message': responseData['error'] ?? 'Datos incompletos',
        };
      } else {
        return {
          'success': false,
          'message': 'Error al registrar salida: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }
}
