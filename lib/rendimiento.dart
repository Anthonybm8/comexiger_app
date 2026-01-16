// rendimiento.dart
import 'package:flutter/material.dart';
import './screens/rendimiento_dashboard.dart';
import 'utils/usuario_preferences.dart';

class Rendimiento extends StatelessWidget {
  const Rendimiento({super.key});

  // ✅ Normaliza mesa para backend: "Mesa 1" -> "1"
  String _normalizarMesa(String mesa) {
    final soloNumeros = mesa.replaceAll(RegExp(r'[^0-9]'), '').trim();
    return soloNumeros.isEmpty ? mesa.trim() : soloNumeros;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _obtenerDatosUsuario(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: Colors.yellow),
            ),
          );
        }

        final usuarioUsername = snapshot.data?['username']?.toString() ?? '';
        final usuarioNombre = snapshot.data?['nombre']?.toString() ?? 'Usuario';

        // ✅ Mesa cruda para mostrar (puede venir "Mesa 1")
        final mesa = snapshot.data?['mesa']?.toString() ?? 'Mesa 1';

        // ✅ Mesa limpia para enviar al backend ("1")
        final mesaNormalizada = _normalizarMesa(mesa);

        return Scaffold(
          backgroundColor: Colors.black,
          body: SingleChildScrollView( // 👈 Envolvemos todo en SingleChildScrollView
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Center(
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

                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/menu');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back, color: Colors.black, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Regresar",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 30),
                    Text(
                      "TU RENDIMIENTO",
                      style: TextStyle(color: Colors.white, fontSize: 30),
                    ),

                    SizedBox(height: 40),

                    // Información del usuario
                    Card(
                      color: Colors.grey[900],
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(Icons.person, size: 50, color: Colors.yellow),
                            SizedBox(height: 10),
                            Text(
                              usuarioNombre,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '@$usuarioUsername',
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Mesa: $mesa',
                              style: TextStyle(
                                color: Colors.yellow,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 30),

                    // ✅ Botón para ir al dashboard (YA ENVÍA MESA)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RendimientoDashboard(
                              usuarioUsername: usuarioUsername,
                              usuarioNombre: usuarioNombre,
                              usuarioMesa: mesa, // ✅ CLAVE
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.dashboard, size: 24),
                          SizedBox(width: 10),
                          Text(
                            "VER DASHBOARD",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Botón para iniciar jornada rápida (sin lógica por ahora)
                    ElevatedButton(
                      onPressed: () async {
                        // Aquí puedes agregar la lógica para iniciar jornada directamente
                        // usando mesaNormalizada
                        // Ejemplo:
                        // await JornadaRepository.iniciarJornada(mesa: mesaNormalizada);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow, size: 24),
                          SizedBox(width: 10),
                          Text(
                            "INICIAR JORNADA RÁPIDA",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Agregar espacio extra al final para mejor desplazamiento
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _obtenerDatosUsuario() async {
    try {
      final username = await UsuarioPreferences.obtenerUsername();
      final nombre = await UsuarioPreferences.obtenerNombreCompleto();
      final mesa = await UsuarioPreferences.obtenerMesa() ?? 'Mesa 1';

      return {'username': username, 'nombre': nombre, 'mesa': mesa};
    } catch (e) {
      return {'username': 'usuario', 'nombre': 'Usuario', 'mesa': 'Mesa 1'};
    }
  }
}