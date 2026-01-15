import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../models/mesa_model.dart';
import '../repositories/usuario_repository.dart';

class UsuarioRegistro extends StatefulWidget {
  const UsuarioRegistro({super.key});

  @override
  State<UsuarioRegistro> createState() => _UsuarioRegistroState();
}

class _UsuarioRegistroState extends State<UsuarioRegistro> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _cargoController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  MesaModel? _selectedMesa;
  bool _isLoading = false;
  bool _isLoadingMesas = false;
  List<MesaModel> _mesas = [];
  String _errorMesas = '';

  @override
  void initState() {
    super.initState();
    _cargarMesas();
  }

  Future<void> _cargarMesas() async {
    if (mounted) {
      setState(() {
        _isLoadingMesas = true;
        _errorMesas = '';
      });
    }

    try {
      final resultado = await UsuarioRepository.obtenerMesas();

      if (mounted) {
        if (resultado['success'] == true) {
          final List<dynamic> mesasData = resultado['mesas'] ?? [];
          setState(() {
            _mesas = mesasData.map((json) => MesaModel.fromJson(json)).toList();
            debugPrint('📋 Mesas cargadas: ${_mesas.length}');
            // Si solo hay una mesa, seleccionarla automáticamente
            if (_mesas.length == 1) {
              _selectedMesa = _mesas[0];
            }
          });
        } else {
          setState(() {
            _errorMesas = resultado['message'] ?? 'Error al cargar mesas';
            debugPrint('❌ Error cargando mesas: $_errorMesas');
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMesas = 'Error: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingMesas = false);
      }
    }
  }

  Future<void> _registrarUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      _mostrarError('Las contraseñas no coinciden');
      return;
    }

    if (_selectedMesa == null) {
      _mostrarError('Debe seleccionar una mesa');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final usuario = UsuarioModel(
        nombres: _nombresController.text.trim(),
        apellidos: _apellidosController.text.trim(),
        mesa: _selectedMesa!.nombre,
        cargo: _cargoController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      final resultado = await UsuarioRepository.registrar(usuario);

      if (resultado['success'] == true) {
        _mostrarExito(resultado['message'] ?? 'Registro exitoso');
        _limpiarFormulario();
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context, true);
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

  void _limpiarFormulario() {
    _formKey.currentState?.reset();
    _nombresController.clear();
    _apellidosController.clear();
    _cargoController.clear();
    _usernameController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    setState(() => _selectedMesa = null);
  }

  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _cargoController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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

                      // Campo de Mesa (Dropdown) - ACTUALIZADO
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: DropdownButtonFormField<MesaModel>(
                          value: _selectedMesa,
                          decoration: InputDecoration(
                            hintText: _isLoadingMesas
                                ? "Cargando mesas..."
                                : (_mesas.isEmpty
                                      ? "No hay mesas"
                                      : "Seleccionar Mesa"),
                            hintStyle: TextStyle(
                              color: _isLoadingMesas
                                  ? Colors.yellow
                                  : (_mesas.isEmpty
                                        ? Colors.orange
                                        : Colors.white70),
                            ),
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
                            prefixIcon: _isLoadingMesas
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.yellow,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.table_restaurant,
                                    color: Colors.yellow,
                                  ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 18,
                            ),
                            errorText: _errorMesas.isNotEmpty
                                ? _errorMesas
                                : null,
                          ),
                          dropdownColor: Colors.grey[900],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          validator: (value) {
                            if (value == null) {
                              return 'La mesa es requerida';
                            }
                            return null;
                          },
                          items: _mesas.map((MesaModel mesa) {
                            return DropdownMenuItem<MesaModel>(
                              value: mesa,
                              child: Text(
                                mesa.nombre,
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: _isLoadingMesas || _mesas.isEmpty
                              ? null
                              : (MesaModel? newValue) {
                                  setState(() {
                                    _selectedMesa = newValue;
                                  });
                                },
                          isExpanded: true,
                        ),
                      ),

                      // Contador de mesas
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, right: 20.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            _isLoadingMesas
                                ? "Cargando..."
                                : "Mesas disponibles: ${_mesas.length}",
                            style: TextStyle(
                              color: _isLoadingMesas
                                  ? Colors.yellow
                                  : Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Botón para recargar mesas si hay error
                      if (_errorMesas.isNotEmpty || _mesas.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoadingMesas ? null : _cargarMesas,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[800],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(Icons.refresh, size: 20),
                              label: const Text('Reintentar cargar mesas'),
                            ),
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
                                onPressed:
                                    _isLoading ||
                                        _isLoadingMesas ||
                                        _mesas.isEmpty
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
                                      .withAlpha(127),
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
                                  ),
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
                color: Colors.black.withAlpha(127),
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
