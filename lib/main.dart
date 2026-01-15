import 'package:comexiger_app/etiquetas.dart';
import 'package:comexiger_app/iniciosesion.dart';
import 'package:comexiger_app/menu.dart';
import 'package:comexiger_app/rendimiento.dart';
import 'package:comexiger_app/stock.dart';
import 'package:comexiger_app/usuarioregistro.dart';
import 'package:flutter/material.dart';
import 'utils/usuario_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => FutureBuilder(
          future: UsuarioPreferences.estaLogueado(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                backgroundColor: Colors.black,
                body: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                  ),
                ),
              );
            }

            final bool estaLogueado = snapshot.data ?? false;
            if (estaLogueado) {
              return Menu();
            } else {
              return InicioSesion();
            }
          },
        ),
        '/iniciosesion': (context) => InicioSesion(),
        '/menu': (context) => Menu(),
        '/rendimiento': (context) =>
            Rendimiento(), // <-- Aquí ya no necesita parámetros
        '/stock': (context) => Stock(),
        '/etiquetas': (context) => Etiquetas(),
        '/usuarioregistro': (context) => UsuarioRegistro(),
      },
    );
  }
}
