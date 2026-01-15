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
              // Header con información del usuario
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // Logo
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.asset(
                          "assets/logo.jpg",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Nombre del usuario
                    Text(
                      _usuarioData['nombre_completo'] ?? 'Usuario',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 10),

                    // Mesa y cargo
                    Text(
                      '${_usuarioData['cargo'] ?? ''} - Mesa ${_usuarioData['mesa'] ?? ''}',
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 15),

                    // Usuario
                    Text(
                      '@${_usuarioData['username'] ?? ''}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Título del menú
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'MENÚ PRINCIPAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Botones del menú
              Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 5),

                    SizedBox(
                      width: 300,
                      height: 150,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.asset(
                          "assets/logo.jpg",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    SizedBox(height: 30),

                    // Botón RENDIMIENTO
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/rendimiento');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(
                          horizontal: 35,
                          vertical: 40,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assessment, color: Colors.black, size: 24),
                          SizedBox(width: 10),
                          Text(
                            "VER RENDIMIENTO",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 50),

                    // Botón ETIQUETAS
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/etiquetas');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(
                          horizontal: 35,
                          vertical: 40,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_offer,
                            color: Colors.black,
                            size: 24,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "ETIQUETAS",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 50),

                    // Botón STOCK
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/stock');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(
                          horizontal: 35,
                          vertical: 40,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory, color: Colors.black, size: 24),
                          SizedBox(width: 10),
                          Text(
                            "STOCK",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 50),

                    // Botón JORNADA (ACTUALIZADO)
                    ElevatedButton(
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(
                          horizontal: 35,
                          vertical: 40,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.schedule, color: Colors.black, size: 24),
                          SizedBox(width: 10),
                          Text(
                            "JORNADA",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Botón CERRAR SESIÓN en el bottom navigation
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(10),
        color: Colors.black,
        child: ElevatedButton(
          onPressed: _cerrarSesion,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            minimumSize: Size(double.infinity, 50),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.exit_to_app, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                "Cerrar Sesión",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
