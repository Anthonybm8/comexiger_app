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
          'Dashboard de Rendimiento',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
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
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.black87,
            child: Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.yellow),
                SizedBox(width: 8),
                Text(
                  '${widget.usuarioNombre}',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                Spacer(),
                Icon(Icons.table_bar, size: 16, color: Colors.yellow),
                SizedBox(width: 8),
                Text(
                  'Mesa: ${widget.usuarioMesa}',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
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

  Widget _buildJornadaActualCard() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'JORNADA ACTUAL',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (jornadaActual != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 8 : 12,
                      vertical: isSmallScreen ? 4 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: jornadaActual!.estadoColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          jornadaActual!.estadoIcon,
                          size: isSmallScreen ? 14 : 16,
                          color: jornadaActual!.estadoColor,
                        ),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            jornadaActual!.estadoTexto,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: jornadaActual!.estadoColor,
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                            overflow: TextOverflow.ellipsis,
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
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 10 : 20,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: isSmallScreen ? 40 : 50,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'No tienes jornada iniciada',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _iniciarJornada,
                        icon: Icon(
                          Icons.play_arrow,
                          size: isSmallScreen ? 18 : 24,
                        ),
                        label: Text(
                          'INICIAR JORNADA',
                          style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 12 : 15,
                          ),
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
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isVerySmall = constraints.maxWidth < 300;
                      return Table(
                        columnWidths: isVerySmall
                            ? {0: FlexColumnWidth(1.2), 1: FlexColumnWidth(2)}
                            : {0: FlexColumnWidth(1.5), 1: FlexColumnWidth(3)},
                        children: [
                          TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'Mesa:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isSmallScreen ? 14 : 16,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text(
                                  jornadaActual!.mesa,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 14 : 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'Fecha:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isSmallScreen ? 14 : 16,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text(
                                  jornadaActual!.fechaFormatted,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 14 : 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'Inicio:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isSmallScreen ? 14 : 16,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text(
                                  jornadaActual!.horaInicioFormatted,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 14 : 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (jornadaActual!.horaFin != null)
                            TableRow(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    'Fin:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isSmallScreen ? 14 : 16,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    jornadaActual!.horaFinFormatted ?? "",
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 14 : 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (jornadaActual!.horasTrabajadas != null)
                            TableRow(
                              children: [
                                Text(
                                  'Horas:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isSmallScreen ? 14 : 16,
                                  ),
                                ),
                                Text(
                                  '${jornadaActual!.horasTrabajadas!.toStringAsFixed(2)} horas',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 14 : 16,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  if (jornadaActual!.estaActiva)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _finalizarJornada,
                        icon: Icon(Icons.stop, size: isSmallScreen ? 18 : 24),
                        label: Text(
                          'FINALIZAR JORNADA',
                          style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 12 : 15,
                          ),
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
        LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final crossAxisCount = screenWidth < 400 ? 2 : 4;
            final childAspectRatio = screenWidth < 400 ? 1.3 : 1.5;

            return GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: childAspectRatio,
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
            );
          },
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
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: color),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
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
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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
                    size: 20,
                  ),
                ),
                title: Text(
                  'Mesa ${rendimiento.numeroMesa}',
                  style: TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  '${rendimiento.fechaFormatted} - ${rendimiento.bonches} bonches',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${rendimiento.rendimientoPorHora}/h',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: rendimiento.colorRendimiento,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      rendimiento.nivelRendimiento,
                      style: TextStyle(fontSize: 10, color: Colors.grey),
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
            TextButton(
              onPressed: () {},
              child: Text('Ver todo', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
        SizedBox(height: 10),
        ...jornadasMostrar.map((jornada) {
          return Card(
            margin: EdgeInsets.only(bottom: 8),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: jornada.estadoColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  jornada.estadoIcon,
                  color: jornada.estadoColor,
                  size: 20,
                ),
              ),
              title: Text(
                jornada.fechaFormatted,
                style: TextStyle(fontSize: 14),
              ),
              subtitle: Text(
                '${jornada.horaInicioFormatted} - ${jornada.horaFinFormatted ?? "En progreso"}',
                style: TextStyle(fontSize: 12),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (jornada.horasTrabajadas != null)
                    Text(
                      '${jornada.horasTrabajadas!.toStringAsFixed(1)}h',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  Text(jornada.mesa, style: TextStyle(fontSize: 10)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
