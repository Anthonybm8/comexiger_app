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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Dashboard de Rendimiento - Mesa ${widget.usuarioMesa}',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _cargarDatos,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
            ),
    );
  }

  // ====== UI (lo demás igual, no lo toqué) ======

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
              Column(
                children: [
                  Icon(Icons.access_time, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    'No tienes jornada iniciada',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: _iniciarJornada,
                    icon: Icon(Icons.play_arrow),
                    label: Text('INICIAR JORNADA'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Table(
                    columnWidths: {
                      0: FlexColumnWidth(2),
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
                    ElevatedButton.icon(
                      onPressed: _finalizarJornada,
                      icon: Icon(Icons.stop),
                      label: Text('FINALIZAR JORNADA'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
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
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              title: 'Total Jornadas',
              value: historialJornadas.length.toString(),
              icon: Icons.date_range,
              color: Colors.blue,
            ),
            _buildStatCard(
              title: 'Horas Totales',
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
              title: 'Bonches Totales',
              value: totalBonches.toString(),
              icon: Icons.leaderboard,
              color: Colors.purple,
            ),
          ],
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
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: color),
            SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRendimientosRecientes() {
    if (rendimientos.isEmpty) return Container();

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
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: rendimiento.colorRendimiento.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    rendimiento.bonches > 20 ? Icons.star : Icons.work,
                    color: rendimiento.colorRendimiento,
                  ),
                ),
                title: Text('Mesa ${rendimiento.numeroMesa}'),
                subtitle: Text(
                  '${rendimiento.fechaFormatted} - ${rendimiento.bonches} bonches',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${rendimiento.rendimientoPorHora}/h',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: rendimiento.colorRendimiento,
                      ),
                    ),
                    Text(
                      rendimiento.nivelRendimiento,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHistorialJornadas() {
    if (historialJornadas.isEmpty) return Container();

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
            margin: EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: jornada.estadoColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(jornada.estadoIcon, color: jornada.estadoColor),
              ),
              title: Text(jornada.fechaFormatted),
              subtitle: Text(
                '${jornada.horaInicioFormatted} - ${jornada.horaFinFormatted ?? "En progreso"}',
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (jornada.horasTrabajadas != null)
                    Text(
                      '${jornada.horasTrabajadas!.toStringAsFixed(1)}h',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  Text(jornada.mesa, style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
