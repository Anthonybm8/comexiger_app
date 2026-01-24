import 'package:comexiger_app/settings/bluetooth_permission.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/usuario_preferences.dart';
import 'jornada.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  Map<String, dynamic> _usuarioData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
    _checkBluetoothPermissions();
  }

  Future<void> _cargarDatosUsuario() async {
    try {
      final datos = await UsuarioPreferences.obtenerUsuarioData();
      setState(() {
        _usuarioData = datos;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error cargando datos del usuario: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkBluetoothPermissions() async {
    final granted = await BluetoothPermission.request();
    print('Bluetooth permitido: $granted');

    if (!granted && mounted) {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Permiso requerido'),
        content: const Text(
          'La aplicación necesita Bluetooth para funcionar correctamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
            },
            child: const Text('Ir a ajustes'),
          ),
        ],
      ),
    );
  }

  Future<void> _cerrarSesion() async {
    await UsuarioPreferences.limpiarUsuarioData();
    Navigator.pushReplacementNamed(context, '/iniciosesion');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ==================== LOGO GRANDE CENTRADO ====================
              Container(
                color: Colors.black,
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    SizedBox(height: 10),

                    // LOGO GRANDE CENTRADO
                    SizedBox(
                      width: 280,
                      height: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Image.asset(
                          "assets/logo.jpg",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // TÍTULO DE LA APLICACIÓN
                    Text(
                      "CONTROL DE PRODUCCIÓN",
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              // ==================== INFO DEL USUARIO ELEGANTE ====================
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar del usuario
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(Icons.person, color: Colors.black, size: 30),
                    ),

                    SizedBox(width: 15),

                    // Información del usuario
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nombre del usuario
                          Text(
                            _usuarioData['nombre_completo'] ?? 'Usuario',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),

                          SizedBox(height: 5),

                          // Cargo y mesa
                          Row(
                            children: [
                              Icon(
                                Icons.work,
                                size: 14,
                                color: Colors.grey[400],
                              ),
                              SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  _usuarioData['cargo'] ?? 'Operario',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 13,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 4),

                          // Mesa
                          Row(
                            children: [
                              Icon(
                                Icons.table_bar,
                                size: 14,
                                color: Colors.grey[400],
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Mesa ${_usuarioData['mesa'] ?? 'N/A'}',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 4),

                          // Usuario
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 14,
                                color: Colors.grey[400],
                              ),
                              SizedBox(width: 5),
                              Text(
                                '@${_usuarioData['username'] ?? ''}',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 13,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // ==================== TÍTULO DEL MENÚ ====================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'MENÚ PRINCIPAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // ==================== BOTONES DEL MENÚ MEJORADOS ====================
              Padding(
                padding: EdgeInsets.all(25),
                child: Column(
                  children: [
                    // Botón RENDIMIENTO
                    _buildMenuButton(
                      icon: Icons.assessment,
                      text: "VER RENDIMIENTO",
                      color: Colors.blue,
                      onPressed: () {
                        Navigator.pushNamed(context, '/rendimiento');
                      },
                    ),

                    SizedBox(height: 20),

                    // Botón ETIQUETAS
                    _buildMenuButton(
                      icon: Icons.local_offer,
                      text: "ETIQUETAS",
                      color: Colors.green,
                      onPressed: () {
                        Navigator.pushNamed(context, '/etiquetas');
                      },
                    ),

                    SizedBox(height: 20),

                    // Botón STOCK
                    _buildMenuButton(
                      icon: Icons.inventory,
                      text: "STOCK DISPONIBLE",
                      color: Colors.orange,
                      onPressed: () {
                        Navigator.pushNamed(context, '/stock');
                      },
                    ),

                    SizedBox(height: 20),

                    // Botón JORNADA
                    _buildMenuButton(
                      icon: Icons.schedule,
                      text: "JORNADA LABORAL",
                      color: Colors.purple,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Jornada(
                              usuarioUsername: _usuarioData['username'] ?? '',
                              usuarioNombre:
                                  _usuarioData['nombre_completo'] ?? '',
                              usuarioMesa: _usuarioData['mesa'] ?? '',
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // ==================== BOTÓN CERRAR SESIÓN ====================
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        color: Colors.black,
        child: ElevatedButton.icon(
          onPressed: _cerrarSesion,
          icon: Icon(Icons.exit_to_app, size: 20),
          label: Text(
            "Cerrar Sesión",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            shadowColor: Colors.red.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 75, // Botones más pequeños y elegantes
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 3,
          shadowColor: Colors.black.withOpacity(0.2),
          side: BorderSide(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            // Icono con fondo circular
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(icon, color: color, size: 24),
            ),

            SizedBox(width: 15),

            // Texto del botón
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Flecha indicadora
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}
