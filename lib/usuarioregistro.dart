import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../repositories/usuario_repository.dart';

class UsuarioRegistro extends StatefulWidget {
  const UsuarioRegistro({super.key});

  @override
  State<UsuarioRegistro> createState() => _UsuarioRegistroState();
}

class _UsuarioRegistroState extends State<UsuarioRegistro> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // Elimina esta línea si usas métodos static:
  // final UsuarioRepository _repo = UsuarioRepository(); // ❌ ELIMINA

  // Controllers
  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _mesaController = TextEditingController();
  final TextEditingController _cargoController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _selectedMesa;
  bool _isLoading = false;
  final List<String> _mesas = [
    'Mesa 1',
    'Mesa 2',
    'Mesa 3',
    'Mesa 4',
    'Mesa 5',
    'Mesa 6',
    'Administrador',
  ];

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _mesaController.dispose();
    _cargoController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _registrarUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    // Validar contraseñas coinciden
    if (_passwordController.text != _confirmPasswordController.text) {
      _mostrarError('Las contraseñas no coinciden');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final usuario = UsuarioModel(
        nombres: _nombresController.text.trim(),
        apellidos: _apellidosController.text.trim(),
        mesa: _selectedMesa ?? _mesaController.text.trim(),
        cargo: _cargoController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      // ✅ CORREGIDO: Usa UsuarioRepository.registrar() directamente
      final resultado = await UsuarioRepository.registrar(usuario);

      if (resultado['success'] == true) {
        _mostrarExito(resultado['message'] ?? 'Registro exitoso');

        // Limpiar formulario
        _limpiarFormulario(); // ✅ AGREGA ESTE MÉTODO

        // Regresar después de 2 segundos
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context, true);
          }
        });
      } else {
        _mostrarError(resultado['message'] ?? 'Error en el registro');
      }
    } catch (e) {
      _mostrarError('Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ✅ AGREGA ESTE MÉTODO FALTANTE:
  void _limpiarFormulario() {
    _formKey.currentState?.reset();
    _nombresController.clear();
    _apellidosController.clear();
    _mesaController.clear();
    _cargoController.clear();
    _usernameController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    setState(() => _selectedMesa = null);
  }

  void _mostrarExito(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
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
              child: Form(
                key: _formKey,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),

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

                      const SizedBox(height: 30),

                      // Título
                      const Text(
                        "REGISTRARSE",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Campo de Nombres
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextFormField(
                          controller: _nombresController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Los nombres son requeridos';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: "Nombres",
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
                              Icons.person_outline,
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

                      // Campo de Apellidos
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextFormField(
                          controller: _apellidosController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Los apellidos son requeridos';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: "Apellidos",
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
                              Icons.person_outlined,
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

                      // Campo de Mesa (Dropdown) - ✅ CORREGIDO
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: DropdownButtonFormField<String>(
                          value: _selectedMesa,
                          decoration: InputDecoration(
                            hintText: "Seleccionar Mesa",
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
                              Icons.table_restaurant,
                              color: Colors.yellow,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 18,
                            ),
                          ),
                          dropdownColor: Colors.grey[900],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La mesa es requerida';
                            }
                            return null;
                          },
                          items: _mesas.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedMesa = newValue;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Campo de Cargo
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextFormField(
                          controller: _cargoController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El cargo es requerido';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: "Cargo (ej: Mesero, Administrador)",
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
                              Icons.work,
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

                      // Campo de Usuario
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextFormField(
                          controller: _usernameController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El usuario es requerido';
                            }
                            if (value.length < 3) {
                              return 'Mínimo 3 caracteres';
                            }
                            return null;
                          },
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

                      // Campo de Contraseña
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'La contraseña es requerida';
                            }
                            if (value.length < 6) {
                              return 'Mínimo 6 caracteres';
                            }
                            return null;
                          },
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Campo de Confirmar Contraseña
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Confirme la contraseña';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: "Confirmar Contraseña",
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
                              Icons.lock_reset,
                              color: Colors.yellow,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Botones de acción
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: [
                            // Botón REGISTRARME
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : _registrarUsuario,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                  disabledBackgroundColor: Colors.green
                                      .withAlpha(127), // ✅ CORREGIDO
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.person_add, size: 22),
                                          SizedBox(width: 10),
                                          Text(
                                            "REGISTRARME",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Botón CANCELAR
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                  disabledBackgroundColor: Colors.red.withAlpha(
                                    127,
                                  ), // ✅ CORREGIDO
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.cancel, size: 22),
                                    SizedBox(width: 10),
                                    Text(
                                      "CANCELAR",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
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
            ),

            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.black.withAlpha(127), // ✅ CORREGIDO
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
