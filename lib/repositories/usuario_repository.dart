
import '../models/usuario_model.dart';
import '../utils/api_client.dart';
import '../utils/usuario_preferences.dart';

class UsuarioRepository {
  // ============================================
  // 1. REGISTRAR NUEVO USUARIO  (NO auth)
  // ============================================
  static Future<Map<String, dynamic>> registrar(UsuarioModel usuario) async {
    try {
      final res = await ApiClient.post(
        '/api/registrar/',
        auth: false,
        body: usuario.toJsonForRegister(),
      );

      final status = res['status'] as int;
      final responseData = res['data'] as Map<String, dynamic>;

      if (status == 201) {
        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData['data'],
        };
      }

      return {
        'success': false,
        'message': responseData['error'] ?? 'Error ($status)',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error inesperado: $e'};
    }
  }

  // ============================================
  // 2. LOGIN (NO auth) + guarda tokens
  // ============================================
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final res = await ApiClient.post(
        '/api/login/',
        auth: false,
        body: {
          'username': username.trim(),
          'password': password.trim(),
        },
      );

      final status = res['status'] as int;
      final responseData = res['data'] as Map<String, dynamic>;

      if (status == 200) {
        final data = (responseData['data'] ?? {}) as Map<String, dynamic>;
        final tokens = (responseData['tokens'] ?? {}) as Map<String, dynamic>;

        final access = (tokens['access'] ?? '').toString();
        final refresh = (tokens['refresh'] ?? '').toString();
        final cargo = (data['cargo'] ?? '').toString().trim().toUpperCase();

        if (cargo == 'ADMIN') {
          return {
            'success': false,
            'message': 'Este usuario ADMIN no puede ingresar desde la app móvil.',
          };
        }

        if (access.isEmpty || refresh.isEmpty) {
          return {
            'success': false,
            'message': 'Login OK pero faltan tokens (access/refresh). Revisa backend.',
          };
        }

        await UsuarioPreferences.guardarTokens(access: access, refresh: refresh);

        return {
          'success': true,
          'message': responseData['message'],
          'data': data,
          'tokens': {'access': access, 'refresh': refresh},
        };
      }

      return {
        'success': false,
        'message': responseData['error'] ?? 'Error ($status)',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error inesperado: $e'};
    }
  }

  // ============================================
  // 3. OBTENER LISTA DE MESAS (NO auth)
  // ============================================
  static Future<Map<String, dynamic>> obtenerMesas() async {
    try {
      final res = await ApiClient.get('/api/mesas/', auth: false);

      final status = res['status'] as int;
      final responseData = res['data'] as Map<String, dynamic>;

      if (status == 200) {
        return {
          'success': true,
          'mesas': responseData['data'],
          'count': responseData['count'],
        };
      }

      return {
        'success': false,
        'message': responseData['error'] ?? 'Error ($status)',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error al obtener mesas: $e'};
    }
  }

  // ============================================
  // 4. VERIFICAR MESA (NO auth)
  // ============================================
  static Future<Map<String, dynamic>> verificarMesa(String nombreMesa) async {
    try {
      final res = await ApiClient.post(
        '/api/verificar_mesa/',
        auth: false,
        body: {'nombre': nombreMesa},
      );

      final status = res['status'] as int;
      final responseData = res['data'] as Map<String, dynamic>;

      if (status == 200) {
        return {
          'success': true,
          'existe': responseData['existe'],
          'nombre': responseData['nombre'],
        };
      }

      return {
        'success': false,
        'message': responseData['error'] ?? 'Error ($status)',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
