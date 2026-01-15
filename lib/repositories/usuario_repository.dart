// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario_model.dart';

class UsuarioRepository {
  // 🎯 URL BASE - SIN 'Usuario/'
  static const String _baseUrl = "http://10.0.2.2:8000";
  // Para dispositivo físico: "http://192.168.1.X:8000"
  // Para iOS Simulator: "http://localhost:8000"

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
      // Convertir datos a JSON
      final body = jsonEncode(usuario.toJsonForRegister());

      // Enviar petición POST
      final response = await http.post(url, headers: _headers, body: body);

      // Logs de respuesta
      print('📥 Código de estado: ${response.statusCode}');
      print('📥 Cuerpo de respuesta: ${response.body}');

      // Decodificar respuesta (usar utf8.decode para caracteres especiales)
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      // Procesar según el código de estado
      if (response.statusCode == 201) {
        // Éxito - Usuario creado
        print('✅ REGISTRO EXITOSO: ${responseData['message']}');
        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData['data'],
        };
      } else if (response.statusCode == 400) {
        // Error del cliente (datos inválidos)
        print('❌ ERROR 400: ${responseData['error']}');
        return {
          'success': false,
          'message': responseData['error'] ?? 'Error en los datos enviados',
        };
      } else if (response.statusCode == 500) {
        // Error del servidor
        print('❌ ERROR 500: ${responseData['error']}');
        return {
          'success': false,
          'message': 'Error interno del servidor: ${responseData['error']}',
        };
      } else {
        // Otro código de error
        print('⚠️ CÓDIGO INESPERADO: ${response.statusCode}');
        return {
          'success': false,
          'message':
              'Error inesperado (${response.statusCode}): ${response.body}',
        };
      }
    } on http.ClientException catch (e) {
      // Error de conexión HTTP
      print('💥 CLIENT EXCEPTION: ${e.message}');
      return {
        'success': false,
        'message':
            'Error de conexión: ${e.message}.\n'
            'Verifica que Django esté corriendo en http://10.0.2.2:8000',
      };
    } on FormatException catch (e) {
      // Error al decodificar JSON
      print('💥 FORMAT EXCEPTION: ${e.message}');
      return {
        'success': false,
        'message': 'Error en el formato de respuesta del servidor',
      };
    } catch (e) {
      // Error inesperado
      print('💥 ERROR INESPERADO: $e');
      print('💥 Stack trace: ${e.toString()}');
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
      // Preparar datos para login
      final body = jsonEncode({
        'username': username.trim(),
        'password': password.trim(),
      });

      // Enviar petición POST
      final response = await http.post(url, headers: _headers, body: body);

      // Logs de respuesta
      print('📥 Código de estado: ${response.statusCode}');
      print('📥 Cuerpo de respuesta: ${response.body}');

      // Decodificar respuesta
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      // Procesar según el código de estado
      if (response.statusCode == 200) {
        // Éxito - Login correcto
        print('✅ LOGIN EXITOSO: ${responseData['message']}');
        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData['data'],
        };
      } else if (response.statusCode == 401) {
        // No autorizado (credenciales incorrectas)
        print('❌ ERROR 401: ${responseData['error']}');
        return {
          'success': false,
          'message': responseData['error'] ?? 'Credenciales incorrectas',
        };
      } else if (response.statusCode == 404) {
        // Usuario no encontrado
        print('❌ ERROR 404: ${responseData['error']}');
        return {
          'success': false,
          'message': responseData['error'] ?? 'Usuario no encontrado',
        };
      } else {
        // Otro error
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

      // Crear un client con timeout
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
            'Asegúrate de que:\n'
            '1. Django esté corriendo (python manage.py runserver)\n'
            '2. La IP 10.0.2.2:8000 sea accesible\n'
            '3. No haya firewalls bloqueando la conexión',
      };
    } on Exception catch (e) {
      print('💥 TIMEOUT EXCEPTION: $e');
      return {
        'success': false,
        'message':
            '❌ Timeout de conexión\n'
            'El servidor Django no responde en 5 segundos',
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

      // Crear un client con timeout
      final client = http.Client();
      final response = await client
          .get(url)
          .timeout(const Duration(seconds: 5));

      print('📥 Código de estado: ${response.statusCode}');
      print('📥 Respuesta: ${response.body}');

      // Interpretar el código de estado
      if (response.statusCode == 405) {
        // 405 Method Not Allowed - ¡ES BUENO! Significa que la ruta existe pero no acepta GET
        return {
          'success': true,
          'message': '✅ Ruta API encontrada (espera POST, no GET)',
          'status': response.statusCode,
          'note': 'Esta ruta solo acepta método POST para registrar usuarios',
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
          'message':
              '❌ Ruta API no encontrada (404)\n'
              'Verifica que en Django esté configurada:\n'
              'path(\'api/registrar/\', registrar_usuario_api)',
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
    // Esta función asume que tu API tiene un endpoint para verificar usuario
    // Si no lo tienes, puedes implementarlo en Django o usar try-catch del login

    try {
      // Intentamos login con contraseña falsa para ver si el usuario existe
      final result = await login(
        username: username,
        password: 'dummy_password',
      );

      // Si el error es 401 (credenciales incorrectas) significa que el usuario SÍ existe
      // Si el error es 404 (no encontrado) significa que NO existe

      if (result['success'] == true) {
        return true; // Usuario existe y contraseña correcta (improbable con dummy)
      } else if (result['message']?.contains('no encontrado') == true ||
          result['message']?.contains('Usuario no') == true) {
        return false; // Usuario no existe
      } else {
        return true; // Otro error, asumimos que existe
      }
    } catch (e) {
      return false; // En caso de error, asumimos que no existe
    }
  }

  // ============================================
  // 6. MÉTODO DE PRUEBA SIMPLE (solo logs, sin UI)
  // ============================================
  static Future<void> runFullTest() async {
    print('🧪 [REPOSITORY] Ejecutando prueba completa...');

    // 1. Probar conexión básica
    print('\n=== 1. PROBANDO CONEXIÓN BÁSICA ===');
    final connectionTest = await testConnection();
    print('Resultado: ${connectionTest['message']}');

    // 2. Probar ruta API
    print('\n=== 2. PROBANDO RUTA API ===');
    final apiTest = await testApiRoute();
    print('Resultado: ${apiTest['message']}');

    // 3. Resumen
    print('\n=== RESUMEN DE PRUEBA ===');
    if (connectionTest['success'] == true && apiTest['success'] == true) {
      print('✅ TODO CORRECTO: Django está accesible y las APIs funcionan');
    } else {
      print('❌ HAY PROBLEMAS:');
      if (!connectionTest['success']) {
        print('   • ${connectionTest['message']}');
      }
      if (!apiTest['success']) {
        print('   • ${apiTest['message']}');
      }
    }

    print('\n=== PRUEBA COMPLETA FINALIZADA ===');
  }
}
