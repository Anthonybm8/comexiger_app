// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario_model.dart';
import '../models/jornada_model.dart';

class UsuarioRepository {
  // 🎯 URL BASE - SIN 'Usuario/'
  static const String _baseUrl = "http://192.168.110.99:8000";

  // Headers comunes para todas las peticiones
  static final Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  // ============================================
  // 1. REGISTRAR NUEVO USUARIO
  // ============================================
  static Future<Map<String, dynamic>> registrar(UsuarioModel usuario) async {
    final url = Uri.parse('$_baseUrl/api/registrar/');

    print('🚀 [REPOSITORY] Iniciando registro de usuario');
    print('🔗 URL: $url');
    print('👤 Usuario a registrar: ${usuario.username}');
    print('📤 Datos completos: ${usuario.toJsonForRegister()}');

    try {
      final body = jsonEncode(usuario.toJsonForRegister());
      final response = await http.post(url, headers: _headers, body: body);

      print('📥 Código de estado: ${response.statusCode}');
      print('📥 Cuerpo de respuesta: ${response.body}');

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 201) {
        print('✅ REGISTRO EXITOSO: ${responseData['message']}');
        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData['data'],
        };
      } else if (response.statusCode == 400) {
        print('❌ ERROR 400: ${responseData['error']}');
        return {
          'success': false,
          'message': responseData['error'] ?? 'Error en los datos enviados',
        };
      } else if (response.statusCode == 500) {
        print('❌ ERROR 500: ${responseData['error']}');
        return {
          'success': false,
          'message': 'Error interno del servidor: ${responseData['error']}',
        };
      } else {
        print('⚠️ CÓDIGO INESPERADO: ${response.statusCode}');
        return {
          'success': false,
          'message':
              'Error inesperado (${response.statusCode}): ${response.body}',
        };
      }
    } on http.ClientException catch (e) {
      print('💥 CLIENT EXCEPTION: ${e.message}');
      return {
        'success': false,
        'message':
            'Error de conexión: ${e.message}.\n'
            'Verifica que Django esté corriendo en $_baseUrl',
      };
    } on FormatException catch (e) {
      print('💥 FORMAT EXCEPTION: ${e.message}');
      return {
        'success': false,
        'message': 'Error en el formato de respuesta del servidor',
      };
    } catch (e) {
      print('💥 ERROR INESPERADO: $e');
      return {'success': false, 'message': 'Error inesperado: $e'};
    }
  }

  // ============================================
  // 2. INICIAR SESIÓN
  // ============================================
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/api/login/');

    print('🔐 [REPOSITORY] Iniciando sesión');
    print('🔗 URL: $url');
    print('👤 Usuario: $username');

    try {
      final body = jsonEncode({
        'username': username.trim(),
        'password': password.trim(),
      });

      final response = await http.post(url, headers: _headers, body: body);

      print('📥 Código de estado: ${response.statusCode}');
      print('📥 Cuerpo de respuesta: ${response.body}');

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        print('✅ LOGIN EXITOSO: ${responseData['message']}');
        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData['data'],
        };
      } else if (response.statusCode == 401) {
        print('❌ ERROR 401: ${responseData['error']}');
        return {
          'success': false,
          'message': responseData['error'] ?? 'Credenciales incorrectas',
        };
      } else if (response.statusCode == 404) {
        print('❌ ERROR 404: ${responseData['error']}');
        return {
          'success': false,
          'message': responseData['error'] ?? 'Usuario no encontrado',
        };
      } else {
        print('⚠️ CÓDIGO INESPERADO: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Error (${response.statusCode}): ${response.body}',
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
  // 3. PROBAR CONEXIÓN CON DJANGO
  // ============================================
  static Future<Map<String, dynamic>> testConnection() async {
    print('🔍 [REPOSITORY] Probando conexión con Django...');

    try {
      final url = Uri.parse('$_baseUrl/');
      print('🔗 URL de prueba: $url');

      final client = http.Client();
      final response = await client
          .get(url)
          .timeout(const Duration(seconds: 5));

      print('📥 Código de estado: ${response.statusCode}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': '✅ Conexión exitosa con Django',
          'status': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': '⚠️ Django respondió con código: ${response.statusCode}',
          'status': response.statusCode,
        };
      }
    } on http.ClientException catch (e) {
      print('💥 CLIENT EXCEPTION: ${e.message}');
      return {
        'success': false,
        'message':
            '❌ No se pudo conectar con Django: ${e.message}\n'
            'Asegúrate de que Django esté corriendo en $_baseUrl',
      };
    } on Exception catch (e) {
      print('💥 TIMEOUT EXCEPTION: $e');
      return {
        'success': false,
        'message': '❌ Timeout de conexión (no responde en 5 segundos)',
      };
    } catch (e) {
      print('💥 ERROR INESPERADO: $e');
      return {'success': false, 'message': '❌ Error de conexión: $e'};
    }
  }

  // ============================================
  // 4. PROBAR RUTA API ESPECÍFICA
  // ============================================
  static Future<Map<String, dynamic>> testApiRoute() async {
    print('🔍 [REPOSITORY] Probando ruta API /api/registrar/...');

    try {
      final url = Uri.parse('$_baseUrl/api/registrar/');
      print('🔗 URL de API: $url');

      final client = http.Client();
      final response = await client
          .get(url)
          .timeout(const Duration(seconds: 5));

      print('📥 Código de estado: ${response.statusCode}');
      print('📥 Respuesta: ${response.body}');

      if (response.statusCode == 405) {
        return {
          'success': true,
          'message': '✅ Ruta API encontrada (espera POST, no GET)',
          'status': response.statusCode,
        };
      } else if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': '✅ Ruta API funciona correctamente',
          'status': response.statusCode,
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': '❌ Ruta API no encontrada (404)',
          'status': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': '⚠️ Respuesta inesperada: ${response.statusCode}',
          'status': response.statusCode,
        };
      }
    } on http.ClientException catch (e) {
      return {'success': false, 'message': '❌ Error de conexión: ${e.message}'};
    } on Exception catch (e) {
      return {'success': false, 'message': '❌ Timeout de conexión: $e'};
    } catch (e) {
      return {'success': false, 'message': '❌ Error inesperado: $e'};
    }
  }

  // ============================================
  // 5. VALIDAR SI UN USUARIO YA EXISTE
  // ============================================
  static Future<bool> usuarioExiste(String username) async {
    try {
      final result = await login(
        username: username,
        password: 'dummy_password',
      );

      if (result['success'] == true) return true;

      if (result['message']?.contains('no encontrado') == true ||
          result['message']?.contains('Usuario no') == true) {
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  // ============================================
  // 6. MÉTODO DE PRUEBA SIMPLE
  // ============================================
  static Future<void> runFullTest() async {
    print('🧪 [REPOSITORY] Ejecutando prueba completa...');

    print('\n=== 1. PROBANDO CONEXIÓN BÁSICA ===');
    final connectionTest = await testConnection();
    print('Resultado: ${connectionTest['message']}');

    print('\n=== 2. PROBANDO RUTA API ===');
    final apiTest = await testApiRoute();
    print('Resultado: ${apiTest['message']}');

    print('\n=== RESUMEN DE PRUEBA ===');
    if (connectionTest['success'] == true && apiTest['success'] == true) {
      print('✅ TODO CORRECTO');
    } else {
      print('❌ HAY PROBLEMAS');
    }

    print('\n=== PRUEBA COMPLETA FINALIZADA ===');
  }

  // ============================================
  // 7. OBTENER LISTA DE MESAS DESDE DJANGO
  // ============================================
  static Future<Map<String, dynamic>> obtenerMesas() async {
    final url = Uri.parse('$_baseUrl/api/mesas/');

    print('📋 [REPOSITORY] Obteniendo lista de mesas');
    print('🔗 URL: $url');

    try {
      final response = await http.get(url, headers: _headers);

      print('📥 Código de estado: ${response.statusCode}');
      print('📥 Respuesta: ${response.body}');

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        print('✅ Mesas obtenidas correctamente');
        return {
          'success': true,
          'mesas': responseData['data'],
          'count': responseData['count'],
        };
      } else {
        print('❌ Error al obtener mesas: ${responseData['error']}');
        return {
          'success': false,
          'message': responseData['error'] ?? 'Error al obtener mesas',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error al obtener mesas: $e'};
    }
  }

  // ============================================
  // 8. VERIFICAR SI UNA MESA EXISTE
  // ============================================
  static Future<Map<String, dynamic>> verificarMesa(String nombreMesa) async {
    final url = Uri.parse('$_baseUrl/api/verificar_mesa/');

    print('🔍 [REPOSITORY] Verificando mesa: $nombreMesa');
    print('🔗 URL: $url');

    try {
      final body = jsonEncode({'nombre': nombreMesa});
      final response = await http.post(url, headers: _headers, body: body);

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        print('✅ Mesa verificada: ${responseData['existe']}');
        return {
          'success': true,
          'existe': responseData['existe'],
          'nombre': responseData['nombre'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['error'] ?? 'Error al verificar mesa',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ============================================
  // 9. INICIAR JORNADA (POR MESA)
  // ============================================
  static Future<Map<String, dynamic>> iniciarJornada({
    required String mesa,
    String? usuarioUsername,
    String? usuarioNombre,
  }) async {
    final url = Uri.parse('$_baseUrl/api/jornada/iniciar/');

    print('⏰ [REPOSITORY] Iniciando jornada laboral (POR MESA)');
    print('🔗 URL: $url');
    print('👤 Usuario: ${usuarioUsername ?? "-"}');
    print('📋 Mesa: $mesa');

    try {
      final body = jsonEncode({'mesa': mesa});

      final response = await http.post(url, headers: _headers, body: body);

      print('📥 Código de estado: ${response.statusCode}');
      print('📥 Respuesta: ${response.body}');

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'],
          'jornada': JornadaModel.fromJson(responseData['data']),
        };
      }

      if (response.statusCode == 400) {
        // ✅ backend ahora manda: {error: "...", data: {...}}
        final data = responseData['data'];
        return {
          'success': false,
          'message': responseData['error'] ?? 'Ya existe jornada activa',
          'jornada': data != null ? JornadaModel.fromJson(data) : null,
        };
      }

      return {
        'success': false,
        'message': responseData['error'] ?? 'Error al iniciar jornada',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error al iniciar jornada: $e'};
    }
  }

  // ============================================
  // 10. FINALIZAR JORNADA (POR MESA)
  // ============================================
  static Future<Map<String, dynamic>> finalizarJornada({
    required String mesa,
    String? usuarioUsername,
  }) async {
    final url = Uri.parse('$_baseUrl/api/jornada/finalizar/');

    print('⏰ [REPOSITORY] Finalizando jornada laboral (POR MESA)');
    print('🔗 URL: $url');
    print('👤 Usuario: ${usuarioUsername ?? "-"}');
    print('📋 Mesa: $mesa');

    try {
      final body = jsonEncode({'mesa': mesa});

      final response = await http.post(url, headers: _headers, body: body);

      print('📥 Código de estado: ${response.statusCode}');
      print('📥 Respuesta: ${response.body}');

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'],
          'jornada': JornadaModel.fromJson(responseData['data']),
        };
      }

      if (response.statusCode == 400) {
        return {
          'success': false,
          'message': responseData['error'] ?? 'No hay jornada activa',
        };
      }

      return {
        'success': false,
        'message': responseData['error'] ?? 'Error al finalizar jornada',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error al finalizar jornada: $e'};
    }
  }

  // ============================================
  // 11. OBTENER JORNADA ACTUAL (POR MESA)
  // ============================================
  static Future<Map<String, dynamic>> obtenerJornadaActual({
    required String mesa,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/api/jornada/actual/',
    ).replace(queryParameters: {'mesa': mesa});

    print('⏰ [REPOSITORY] Obteniendo jornada actual (POR MESA)');
    print('🔗 URL: $url');

    try {
      final response = await http.get(url, headers: _headers);

      print('📥 Código de estado: ${response.statusCode}');
      print('📥 Respuesta: ${response.body}');

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': JornadaActualResponse.fromJson(responseData['data']),
        };
      }

      return {
        'success': false,
        'message': responseData['error'] ?? 'Error al obtener jornada actual',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al obtener jornada actual: $e',
      };
    }
  }

  // ============================================
  // 12. OBTENER HISTORIAL DE JORNADAS (POR MESA)
  // ============================================
  static Future<Map<String, dynamic>> obtenerHistorialJornadas({
    required String mesa,
    int limit = 30,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/api/jornada/historial/',
    ).replace(queryParameters: {'mesa': mesa, 'limit': '$limit'});

    print('⏰ [REPOSITORY] Obteniendo historial de jornadas (POR MESA)');
    print('🔗 URL: $url');

    try {
      final response = await http.get(url, headers: _headers);

      print('📥 Código de estado: ${response.statusCode}');
      print('📥 Respuesta: ${response.body}');

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': HistorialJornadasResponse.fromJson(responseData['data']),
        };
      }

      return {
        'success': false,
        'message': responseData['error'] ?? 'Error al obtener historial',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error al obtener historial: $e'};
    }
  }

  // ============================================
  // 13. VERIFICAR ESTADO DE JORNADA (POR MESA)
  // ============================================
  static Future<bool> tieneJornadaActivaPorMesa(String mesa) async {
    try {
      final resultado = await obtenerJornadaActual(mesa: mesa);
      if (resultado['success'] == true) {
        final JornadaActualResponse response = resultado['data'];
        return response.tieneJornadaActiva;
      }
      return false;
    } catch (e) {
      print('❌ Error verificando jornada activa: $e');
      return false;
    }
  }
}
