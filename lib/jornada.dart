import 'package:flutter/material.dart';
import '../models/jornada_model.dart';
import '../repositories/jornada_repository.dart';


class Jornada extends StatefulWidget {
  final String usuarioUsername;
  final String usuarioNombre;
  final String usuarioMesa;

  const Jornada({
    super.key,
    required this.usuarioUsername,
    required this.usuarioNombre,
    required this.usuarioMesa,
  });

  @override
  State<Jornada> createState() => _JornadaState();
}

class _JornadaState extends State<Jornada> {
  JornadaModel? _jornadaActual;
  JornadaModel? _ultimaJornadaFinalizada;
  bool _isLoading = false;
  bool _isLoadingJornada = false;
  String _errorMessage = '';
  bool _puedeIniciarNuevaJornada = true;
  String _mensajeBloqueo = '';

  @override
  void initState() {
    super.initState();
    _cargarJornadaActual();
  }

  Future<void> _cargarJornadaActual() async {
    if (mounted) {
      setState(() {
        _isLoadingJornada = true;
        _errorMessage = '';
      });
    }

    try {
      final resultado = await JornadaRepository.obtenerJornadaActual(
        mesa: widget.usuarioMesa,
        usuarioUsername: widget.usuarioUsername,
      );


      if (mounted) {
        if (resultado['success'] == true) {
          final response = JornadaActualResponse.fromJson(
            resultado['data'] as Map<String, dynamic>,
          );

          setState(() {
            _jornadaActual = response.jornadaActiva;
            _ultimaJornadaFinalizada = response.ultimaJornada;

            // Verificar si puede iniciar nueva jornada
            _verificarPuedeIniciarNuevaJornada();

            debugPrint('✅ Jornada cargada: ${_jornadaActual?.estado}');
          });
        } else {
          setState(() {
            _errorMessage = resultado['message'] ?? 'Error al cargar jornada';
            debugPrint('❌ Error: $_errorMessage');
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingJornada = false);
      }
    }
  }

  void _verificarPuedeIniciarNuevaJornada() {
    // Si ya hay una jornada activa, no puede iniciar otra
    if (_jornadaActual != null && _jornadaActual!.estaActiva) {
      setState(() {
        _puedeIniciarNuevaJornada = false;
        _mensajeBloqueo = 'Ya tienes una jornada activa';
      });
      return;
    }

    // Si no hay última jornada finalizada, puede iniciar
    if (_ultimaJornadaFinalizada == null) {
      setState(() {
        _puedeIniciarNuevaJornada = true;
        _mensajeBloqueo = '';
      });
      return;
    }

    // Verificar si la última jornada fue hoy
    final ultimaFecha = _ultimaJornadaFinalizada!.fechaEntrada;
    final ahora = DateTime.now();

    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final fechaUltimaJornada = DateTime(
      ultimaFecha.year,
      ultimaFecha.month,
      ultimaFecha.day,
    );

    // Si la última jornada fue hoy, no puede iniciar otra
    if (hoy.isAtSameMomentAs(fechaUltimaJornada)) {
      setState(() {
        _puedeIniciarNuevaJornada = false;
        _mensajeBloqueo =
            'Ya finalizaste tu jornada hoy. Puedes iniciar otra mañana.';
      });
    } else {
      // Si la última jornada fue otro día, puede iniciar
      setState(() {
        _puedeIniciarNuevaJornada = true;
        _mensajeBloqueo = '';
      });
    }
  }

  Future<void> _iniciarJornada() async {
    setState(() => _isLoading = true);

    try {
      final resultado = await JornadaRepository.iniciarJornada(
        mesa: widget.usuarioMesa,
        usuarioUsername: widget.usuarioUsername,
        usuarioNombre: widget.usuarioNombre,
      );


      if (resultado['success'] == true) {
        _mostrarExito(resultado['message'] ?? 'Jornada iniciada');
        setState(() {
          _jornadaActual = resultado['jornada'];
        });
        // Esperar 2 segundos y recargar
        await Future.delayed(const Duration(seconds: 2));
        await _cargarJornadaActual();
      } else {
        _mostrarError(resultado['message'] ?? 'Error al iniciar jornada');
      }
    } catch (e) {
      _mostrarError('Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _finalizarJornada() async {
    setState(() => _isLoading = true);

    try {
      final resultado = await JornadaRepository.finalizarJornada(
        mesa: widget.usuarioMesa,
        usuarioUsername: widget.usuarioUsername,
      );


      if (resultado['success'] == true) {
        _mostrarExito(resultado['message'] ?? 'Jornada finalizada');
        setState(() {
          _jornadaActual = resultado['jornada'];
        });
        // Esperar 2 segundos y recargar
        await Future.delayed(const Duration(seconds: 2));
        await _cargarJornadaActual();
      } else {
        _mostrarError(resultado['message'] ?? 'Error al finalizar jornada');
      }
    } catch (e) {
      _mostrarError('Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _mostrarDialogoIniciar(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            "Iniciar Jornada",
            style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "¿Está seguro de que desea empezar la jornada laboral?",
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              Text(
                "Mesa: ${widget.usuarioMesa}",
                style: TextStyle(
                  color: Colors.yellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              if (!_puedeIniciarNuevaJornada && _mensajeBloqueo.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.yellow, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _mensajeBloqueo,
                          style: TextStyle(color: Colors.yellow, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "NO",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: _puedeIniciarNuevaJornada
                  ? () {
                      Navigator.of(context).pop();
                      _iniciarJornada();
                    }
                  : null,
              child: Text(
                "SÍ",
                style: TextStyle(
                  color: _puedeIniciarNuevaJornada ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoFinalizar(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            "Finalizar Jornada",
            style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "¿Está seguro de que desea finalizar la jornada laboral?",
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              if (_jornadaActual != null)
                Text(
                  "Inicio: ${_jornadaActual!.horaInicioFormatted}",
                  style: TextStyle(color: Colors.yellow),
                ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Después de finalizar, no podrás iniciar otra jornada hoy",
                        style: TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "NO",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _finalizarJornada();
              },
              child: Text(
                "SÍ",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
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

  Widget _buildEstadoJornada() {
    if (_isLoadingJornada) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.yellow.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
              ),
            ),
            SizedBox(width: 10),
            Text("Cargando jornada...", style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.red[900]!.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.red),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.error, color: Colors.red, size: 20),
                SizedBox(width: 10),
                Text(
                  "Error",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(_errorMessage, style: TextStyle(color: Colors.white70)),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _cargarJornadaActual,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 40),
              ),
              icon: Icon(Icons.refresh, size: 16),
              label: Text("Reintentar"),
            ),
          ],
        ),
      );
    }

    // Mostrar advertencia si no puede iniciar nueva jornada
    if (!_puedeIniciarNuevaJornada &&
        _jornadaActual == null &&
        _ultimaJornadaFinalizada != null) {
      final ultimaFecha = _ultimaJornadaFinalizada!.fechaEntrada;
      final hoy = DateTime.now();
      final fechaUltima = DateTime(
        ultimaFecha.year,
        ultimaFecha.month,
        ultimaFecha.day,
      );
      final fechaHoy = DateTime(hoy.year, hoy.month, hoy.day);

      if (fechaUltima.isAtSameMomentAs(fechaHoy)) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.orange[900]!.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.orange),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 24),
                  SizedBox(width: 10),
                  Text(
                    "JORNADA FINALIZADA",
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Text(
                "Hoy ya finalizaste tu jornada laboral.",
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Última jornada: ${_ultimaJornadaFinalizada!.horaInicioFormatted} - ${_ultimaJornadaFinalizada!.horaFinFormatted ?? 'N/A'}",
                style: TextStyle(color: Colors.yellow, fontSize: 14),
              ),
              SizedBox(height: 10),
              Text(
                "Puedes iniciar una nueva jornada mañana.",
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }
    }

    if (_jornadaActual != null && _jornadaActual!.estaActiva) {
      final jornada = _jornadaActual!;
      final ahora = DateTime.now();
      final diferencia = ahora.difference(jornada.horaInicio);
      final horasTranscurridas = diferencia.inHours;
      final minutosTranscurridos = diferencia.inMinutes % 60;

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.green[900]!.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.green),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_circle_fill, color: Colors.green, size: 24),
                SizedBox(width: 10),
                Text(
                  "JORNADA ACTIVA",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Inicio:",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      jornada.horaInicioFormatted,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Tiempo transcurrido:",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      "${horasTranscurridas}h ${minutosTranscurridos}m",
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Divider(color: Colors.grey[700]),
            SizedBox(height: 10),
            Text(
              "Mesa: ${jornada.mesa}",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    // Si no hay jornada activa y puede iniciar nueva
    if (_puedeIniciarNuevaJornada) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[700]!),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pause_circle_filled, color: Colors.grey, size: 24),
                SizedBox(width: 10),
                Text(
                  "SIN JORNADA ACTIVA",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              "Presiona 'INICIAR JORNADA' para comenzar",
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Estado por defecto
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pause_circle_filled, color: Colors.grey, size: 24),
              SizedBox(width: 10),
              Text(
                "SIN JORNADA ACTIVA",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            "Presiona 'INICIAR JORNADA' para comenzar",
            style: TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(25),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),

                // Logo
                SizedBox(
                  width: 350,
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset("assets/logo.jpg", fit: BoxFit.contain),
                  ),
                ),

                SizedBox(height: 20),

                // Botón Regresar
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
                      elevation: 5,
                      shadowColor: Colors.black.withOpacity(0.3),
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

                // Título
                Text(
                  "JORNADA LABORAL",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),

                SizedBox(height: 15),

                // Información del usuario
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.usuarioNombre,
                        style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Mesa: ${widget.usuarioMesa}",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 25),

                // Imagen de flores
                Container(
                  width: 300,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      "assets/flores.jpg",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                          child: Icon(
                            Icons.work,
                            size: 60,
                            color: Colors.yellow,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                SizedBox(height: 30),

                // Estado de la jornada
                _buildEstadoJornada(),

                SizedBox(height: 25),

                // Mensaje instructivo
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "PRESIONE EN INICIAR O FINALIZAR LA JORNADA LABORAL.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 40),

                // Botones de Iniciar y Finalizar
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      // Botón INICIAR (solo si no hay jornada activa y puede iniciar)
                      if ((_jornadaActual == null ||
                              !_jornadaActual!.estaActiva) &&
                          _puedeIniciarNuevaJornada)
                        Container(
                          margin: EdgeInsets.only(bottom: 20),
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading || _isLoadingJornada
                                ? null
                                : () => _mostrarDialogoIniciar(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow,
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 8,
                              shadowColor: Colors.yellow.withOpacity(0.4),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.black,
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.play_arrow,
                                        color: Colors.black,
                                        size: 28,
                                      ),
                                      SizedBox(width: 15),
                                      Text(
                                        "INICIAR JORNADA",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                      // Botón FINALIZAR (solo si hay jornada activa)
                      if (_jornadaActual != null && _jornadaActual!.estaActiva)
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () => _mostrarDialogoFinalizar(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[700],
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 8,
                              shadowColor: Colors.red.withOpacity(0.4),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.stop,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                      SizedBox(width: 15),
                                      Text(
                                        "FINALIZAR JORNADA",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                      // Mostrar mensaje si no puede iniciar nueva jornada
                      if (!_puedeIniciarNuevaJornada &&
                          (_jornadaActual == null ||
                              !_jornadaActual!.estaActiva))
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.orange[900]!.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.orange),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info,
                                    color: Colors.orange,
                                    size: 24,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "No puedes iniciar nueva jornada hoy",
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Text(
                                _mensajeBloqueo,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 30),

                // Información adicional
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.yellow.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.yellow,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Hora Actual:",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
                        style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
