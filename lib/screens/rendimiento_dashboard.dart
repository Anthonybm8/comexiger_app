// screens/rendimiento_dashboard.dart
import 'package:flutter/material.dart';
import '../repositories/jornada_repository.dart';
import '../repositories/rendimiento_repository.dart';
import '../models/jornada_model.dart';
import '../models/rendimiento_model.dart';

class RendimientoDashboard extends StatefulWidget {
  final String usuarioUsername;
  final String usuarioNombre;
  final String usuarioMesa;

  const RendimientoDashboard({
    super.key,
    required this.usuarioUsername,
    required this.usuarioNombre,
    required this.usuarioMesa,
  });

  @override
  State<RendimientoDashboard> createState() => _RendimientoDashboardState();
}

class _RendimientoDashboardState extends State<RendimientoDashboard> {
  JornadaModel? jornadaActual;
  List<JornadaModel> historialJornadas = [];
  List<RendimientoModel> rendimientos = [];
  EstadisticasRendimiento? estadisticas;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    if (!mounted) return;

    setState(() => isLoading = true);

    try {
      // 1) ✅ Obtener jornada actual POR MESA
      final jornadaResult = await JornadaRepository.obtenerJornadaActual(
        mesa: widget.usuarioMesa,
      );

      if (jornadaResult['success'] == true) {
        final data = jornadaResult['data'];
        if (data['tiene_jornada_activa'] == true &&
            data['jornada_activa'] != null) {
          setState(() {
            jornadaActual = JornadaModel.fromJson(data['jornada_activa']);
          });
        } else {
          setState(() {
            jornadaActual = null;
          });
        }
      }

      // 2) ✅ Historial POR MESA
      final historialResult = await JornadaRepository.obtenerHistorialJornadas(
        mesa: widget.usuarioMesa,
        limit: 10,
      );

      if (historialResult['success'] == true) {
        final List<dynamic> jornadasData = historialResult['data']['jornadas'];
        setState(() {
          historialJornadas = jornadasData
              .map((j) => JornadaModel.fromJson(j))
              .toList();
        });
      }

      // 3) Rendimientos recientes (tu repo actual trae todos; lo dejo igual)
      final rendimientosResult =
          await RendimientoRepository.obtenerTodosRendimientos(
            ordenar: 'fecha',
            reciente: true,
          );

      if (rendimientosResult['success'] == true) {
        setState(() {
          rendimientos = rendimientosResult['rendimientos'];
        });
      }

      // 4) Estadísticas
      final statsResult = await RendimientoRepository.obtenerEstadisticas();
      if (statsResult['success'] == true) {
        setState(() {
          estadisticas = statsResult['estadisticas'];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _iniciarJornada() async {
    // ✅ usa la mesa real asignada al usuario
    final result = await JornadaRepository.iniciarJornada(
      mesa: widget.usuarioMesa,
      usuarioUsername: widget.usuarioUsername, // opcional (logs)
      usuarioNombre: widget.usuarioNombre, // opcional (logs)
    );

    if (result['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('✅ ${result['message']}')));
        await _cargarDatos();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _finalizarJornada() async {
    final result = await JornadaRepository.finalizarJornada(
      mesa: widget.usuarioMesa,
      usuarioUsername: widget.usuarioUsername, // opcional (logs)
    );

    if (result['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('✅ ${result['message']}')));
        await _cargarDatos();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ==================== CABECERA ====================
            Container(
              color: Colors.black,
              padding: EdgeInsets.all(25),
              child: Column(
                children: [
                  SizedBox(height: 5),

                  // LOGO GRANDE CENTRADO
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

                  // BOTÓN REGRESAR AL INICIO
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
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

                  // TÍTULO
                  Text(
                    "TU RENDIMIENTO",
                    style: TextStyle(color: Colors.white, fontSize: 30),
                  ),

                  SizedBox(height: 10),

                  // INFO USUARIO
                  Text(
                    "${widget.usuarioNombre} - Mesa: ${widget.usuarioMesa}",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),

                  SizedBox(height: 40),

                  // TARJETA INFORMATIVA
                  Card(
                    color: Colors.grey[900],
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.assessment,
                            size: 50,
                            color: Colors.yellow,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Dashboard de Rendimiento",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Controla tu jornada y revisa tu productividad",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==================== CONTENIDO PRINCIPAL ====================
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: isLoading
                  ? Container(
                      height: 300,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _buildContenido(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContenido() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildJornadaActualCard(),
          SizedBox(height: 20),
          _buildEstadisticasSection(),
          SizedBox(height: 20),
          _buildRendimientosRecientes(),
          SizedBox(height: 20),
          _buildHistorialJornadas(),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildJornadaActualCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'JORNADA ACTUAL',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                if (jornadaActual != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: jornadaActual!.estadoColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          jornadaActual!.estadoIcon,
                          size: 16,
                          color: jornadaActual!.estadoColor,
                        ),
                        SizedBox(width: 6),
                        Text(
                          jornadaActual!.estadoTexto,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: jornadaActual!.estadoColor,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            SizedBox(height: 15),
            if (jornadaActual == null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Icon(Icons.access_time, size: 50, color: Colors.grey),
                    SizedBox(height: 10),
                    Text(
                      'No tienes jornada iniciada',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _iniciarJornada,
                        icon: Icon(Icons.play_arrow, size: 24),
                        label: Text('INICIAR JORNADA'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  Table(
                    columnWidths: {
                      0: FlexColumnWidth(1.5),
                      1: FlexColumnWidth(3),
                    },
                    children: [
                      TableRow(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                              'Mesa:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(jornadaActual!.mesa),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                              'Fecha:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(jornadaActual!.fechaFormatted),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                              'Inicio:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(jornadaActual!.horaInicioFormatted),
                          ),
                        ],
                      ),
                      if (jornadaActual!.horaFin != null)
                        TableRow(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: Text(
                                'Fin:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: Text(
                                jornadaActual!.horaFinFormatted ?? "",
                              ),
                            ),
                          ],
                        ),
                      if (jornadaActual!.horasTrabajadas != null)
                        TableRow(
                          children: [
                            Text(
                              'Horas:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${jornadaActual!.horasTrabajadas!.toStringAsFixed(2)} horas',
                            ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: 20),
                  if (jornadaActual!.estaActiva)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _finalizarJornada,
                        icon: Icon(Icons.stop, size: 24),
                        label: Text('FINALIZAR JORNADA'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticasSection() {
    final totalHoras = historialJornadas
        .where((j) => j.horasTrabajadas != null)
        .fold(0.0, (sum, j) => sum + (j.horasTrabajadas ?? 0));

    final totalBonches = rendimientos.fold(0, (sum, r) => sum + r.bonches);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ESTADÍSTICAS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
        ),
        SizedBox(height: 10),
        SizedBox(
          // <-- AÑADÍ UN SIZEDBOX CON ALTURA FIJA
          height: 180, // Altura suficiente para las 4 tarjetas
          child: GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(), // Sin scroll interno
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                title: 'Jornadas',
                value: historialJornadas.length.toString(),
                icon: Icons.date_range,
                color: Colors.blue,
              ),
              _buildStatCard(
                title: 'Horas',
                value: totalHoras.toStringAsFixed(1),
                icon: Icons.access_time,
                color: Colors.green,
              ),
              _buildStatCard(
                title: 'Rendimientos',
                value: rendimientos.length.toString(),
                icon: Icons.assessment,
                color: Colors.orange,
              ),
              _buildStatCard(
                title: 'Bonches',
                value: totalBonches.toString(),
                icon: Icons.leaderboard,
                color: Colors.purple,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12), // <-- REDUJE EL PADDING
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // <-- AÑADÍ ESTO
          children: [
            Icon(icon, size: 28, color: color), // <-- REDUJE TAMAÑO ICONO
            SizedBox(height: 6), // <-- REDUJE ESPACIADO
            Text(
              value,
              style: TextStyle(
                fontSize: 20, // <-- REDUJE TAMAÑO DE TEXTO
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 11, // <-- REDUJE TAMAÑO DE TEXTO
                color: Colors.grey[600],
                height: 1.2, // <-- AÑADÍ ALTURA DE LÍNEA
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRendimientosRecientes() {
    if (rendimientos.isEmpty) return SizedBox.shrink();

    final rendimientosMostrar = rendimientos.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RENDIMIENTOS RECIENTES',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
        ),
        SizedBox(height: 10),
        Card(
          elevation: 3,
          child: Column(
            children: rendimientosMostrar.map((rendimiento) {
              return ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10, // <-- REDUJE EL VERTICAL
                ),
                leading: Container(
                  width: 45, // <-- REDUJE TAMAÑO
                  height: 45,
                  decoration: BoxDecoration(
                    color: rendimiento.colorRendimiento.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    rendimiento.bonches > 20 ? Icons.star : Icons.work,
                    color: rendimiento.colorRendimiento,
                    size: 22, // <-- REDUJE TAMAÑO
                  ),
                ),
                title: Text(
                  'Mesa ${rendimiento.numeroMesa}',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  '${rendimiento.fechaFormatted} • ${rendimiento.bonches} bonches',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
                trailing: SizedBox(
                  // <-- AÑADÍ SIZEDBOX PARA TRAILING
                  width: 80, // <-- ANCHO FIJO
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${rendimiento.rendimientoPorHora}/h',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: rendimiento.colorRendimiento,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: rendimiento.colorRendimiento.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          rendimiento.nivelRendimiento,
                          style: TextStyle(
                            fontSize: 10,
                            color: rendimiento.colorRendimiento,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHistorialJornadas() {
    if (historialJornadas.isEmpty) return SizedBox.shrink();

    final jornadasMostrar = historialJornadas.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'HISTORIAL DE JORNADAS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            TextButton(onPressed: () {}, child: Text('Ver todo')),
          ],
        ),
        SizedBox(height: 10),
        ...jornadasMostrar.map((jornada) {
          return Card(
            margin: EdgeInsets.only(bottom: 8),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              leading: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: jornada.estadoColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  jornada.estadoIcon,
                  color: jornada.estadoColor,
                  size: 22,
                ),
              ),
              title: Text(
                jornada.fechaFormatted,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              subtitle: Text(
                '${jornada.horaInicioFormatted} - ${jornada.horaFinFormatted ?? "En progreso"}',
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
              trailing: SizedBox(
                width: 60,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (jornada.horasTrabajadas != null)
                      Text(
                        '${jornada.horasTrabajadas!.toStringAsFixed(1)}h',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    SizedBox(height: 3),
                    Text(
                      jornada.mesa,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
