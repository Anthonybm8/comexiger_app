import 'package:flutter/material.dart';
import '../repositories/usuario_repository.dart';

class InicioSesion extends StatefulWidget {
  const InicioSesion({super.key});

  @override
  State<InicioSesion> createState() => _InicioSesionState();
}

class _InicioSesionState extends State<InicioSesion> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _iniciarSesion() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _mostrarError('Por favor complete todos los campos');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 🔥 CORREGIDO: Usa los métodos STATIC correctamente
      final resultado = await UsuarioRepository.login(
        username: _usernameController.text.trim(), // 🔥 NAMED PARAMETER
        password: _passwordController.text, // 🔥 NAMED PARAMETER
      );

      if (resultado['success'] == true) {
        _mostrarExito(resultado['message'] ?? 'Login exitoso');

        // Guardar datos del usuario si quieres persistencia
        // final prefs = await SharedPreferences.getInstance();
        // await prefs.setString('usuario', jsonEncode(resultado['data']));

        // Navegar al menú - con verificación de mounted
        if (mounted) {
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pushNamed(context, '/menu');
          });
        }
      } else {
        _mostrarError(resultado['message'] ?? 'Error desconocido');
      }
    } catch (e) {
      _mostrarError('Error de conexión: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _mostrarExito(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(25),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // Logo
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

                    const SizedBox(height: 40),

                    // Título
                    const Text(
                      "INICIAR SESIÓN",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Foto de perfil circular
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.yellow, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.yellow.withAlpha(76), // 🔥 CORREGIDO
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          "assets/user.png",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: Icon(
                                Icons.person,
                                size: 80,
                                color: Colors.yellow,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Campo de usuario
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: _usernameController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: "Usuario",
                          hintStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.yellow,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          fillColor: Colors.white12,
                          filled: true,
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Colors.yellow,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Campo de contraseña
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: "Contraseña",
                          hintStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.yellow,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          fillColor: Colors.white12,
                          filled: true,
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Colors.yellow,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.yellow,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Botón de INICIAR SESIÓN
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _iniciarSesion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 8,
                          shadowColor: Colors.yellow.withAlpha(
                            127,
                          ), // 🔥 CORREGIDO
                          minimumSize: const Size(double.infinity, 50),
                          disabledBackgroundColor: Colors.yellow.withAlpha(
                            127,
                          ), // 🔥 CORREGIDO
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.black,
                                  ),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.login, size: 22),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      "INICIAR SESIÓN",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.8,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Separador
                    const Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.white54,
                            thickness: 1,
                            height: 40,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            "o",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.white54,
                            thickness: 1,
                            height: 40,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Enlace de registro
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Flexible(
                            child: Text(
                              "¿No tienes una cuenta? ",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          GestureDetector(
                            onTap: _isLoading
                                ? null
                                : () {
                                    Navigator.pushNamed(
                                      context,
                                      '/usuarioregistro',
                                    );
                                  },
                            child: const Text(
                              "Regístrate aquí",
                              style: TextStyle(
                                color: Colors.yellow,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),

            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.black.withAlpha(127), // 🔥 CORREGIDO
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
