import 'package:comexiger_app/etiquetas.dart';
import 'package:comexiger_app/iniciosesion.dart';
import 'package:comexiger_app/jornada.dart';
import 'package:comexiger_app/menu.dart';
import 'package:comexiger_app/rendimiento.dart';
import 'package:comexiger_app/stock.dart';
import 'package:comexiger_app/usuarioregistro.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/iniciosesion',
      routes: {
        '/iniciosesion': (context) => InicioSesion(),
        '/menu': (context) => Menu(),
        '/rendimiento': (context) => Rendimiento(),
        '/stock': (context) => Stock(),
        '/jornada': (context) => Jornada(),
        '/etiquetas': (context) => Etiquetas(),
        '/usuarioregistro': (context) => UsuarioRegistro(),
      },
    );
  }
}
