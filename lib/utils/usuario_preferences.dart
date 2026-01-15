// lib/utils/usuario_preferences.dart
import 'package:shared_preferences/shared_preferences.dart';

class UsuarioPreferences {
  // Guardar datos del usuario después del login
  static Future<void> guardarUsuarioLogin(
    Map<String, dynamic> usuarioData,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('usuario_id', usuarioData['id']?.toString() ?? '');
    await prefs.setString('usuario_username', usuarioData['username'] ?? '');
    await prefs.setString('usuario_nombre', usuarioData['nombres'] ?? '');
    await prefs.setString('usuario_apellidos', usuarioData['apellidos'] ?? '');
    await prefs.setString('usuario_mesa', usuarioData['mesa'] ?? '');
    await prefs.setString('usuario_cargo', usuarioData['cargo'] ?? '');
    await prefs.setBool('is_logged_in', true);

    print('✅ Datos de usuario guardados en SharedPreferences');
    print('   Usuario: ${usuarioData['username']}');
    print('   Nombre: ${usuarioData['nombres']}');
    print('   Mesa: ${usuarioData['mesa']}');
  }

  // Obtener datos del usuario
  static Future<Map<String, dynamic>> obtenerUsuarioData() async {
    final prefs = await SharedPreferences.getInstance();

    final usuarioData = {
      'id': prefs.getString('usuario_id') ?? '',
      'username': prefs.getString('usuario_username') ?? '',
      'nombre': prefs.getString('usuario_nombre') ?? '',
      'apellidos': prefs.getString('usuario_apellidos') ?? '',
      'nombre_completo':
          '${prefs.getString('usuario_nombre') ?? ''} ${prefs.getString('usuario_apellidos') ?? ''}'
              .trim(),
      'mesa': prefs.getString('usuario_mesa') ?? '',
      'cargo': prefs.getString('usuario_cargo') ?? '',
      'is_logged_in': prefs.getBool('is_logged_in') ?? false,
    };

    return usuarioData;
  }

  // Verificar si el usuario está logueado
  static Future<bool> estaLogueado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  // Limpiar datos (logout)
  static Future<void> limpiarUsuarioData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('usuario_id');
    await prefs.remove('usuario_username');
    await prefs.remove('usuario_nombre');
    await prefs.remove('usuario_apellidos');
    await prefs.remove('usuario_mesa');
    await prefs.remove('usuario_cargo');
    await prefs.setBool('is_logged_in', false);

    print('✅ Datos de usuario eliminados (logout)');
  }

  // Obtener solo el username
  static Future<String> obtenerUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('usuario_username') ?? '';
  }

  // Obtener solo el nombre completo
  // Añade este método a tu clase UsuarioPreferences
  static Future<String?> obtenerNombreCompleto() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nombreCompleto') ??
        prefs.getString('nombre') ??
        prefs.getString('usuario_nombre');
  }

  // Obtener solo la mesa
  static Future<String> obtenerMesa() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('usuario_mesa') ?? '';
  }
}
