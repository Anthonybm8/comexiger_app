// screens/rendimiento_dashboard.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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
  List<RendimientoModel> rendimientosMesaActual = [];
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
      // 1) ✅ Obtener jornada actual POR MESA (LO DEJAMOS POR SI LO USAS EN OTRA LÓGICA)
      final jornadaResult = await JornadaRepository.obtenerJornadaActual(
        mesa: widget.usuarioMesa,
      );

      if (jornadaResult['success'] == true) {
        final data = jornadaResult['data'];
        if (data['tiene_jornada_activa'] == true &&
            data['jornada_activa'] != null) {
          jornadaActual = JornadaModel.fromJson(data['jornada_activa']);
        } else {
          jornadaActual = null;
        }
      }

      // 2) ✅ Historial POR MESA
      final historialResult = await JornadaRepository.obtenerHistorialJornadas(
        mesa: widget.usuarioMesa,
        limit: 10,
      );

      if (historialResult['success'] == true) {
        final List<dynamic> jornadasData = historialResult['data']['jornadas'];
        historialJornadas = jornadasData.map((j) => JornadaModel.fromJson(j)).toList();
      }

      // 3) ✅ Rendimientos recientes SOLO DE LA MESA ACTUAL
      final rendimientosResult = await RendimientoRepository.obtenerTodosRendimientos(
        mesa: widget.usuarioMesa,
        ordenar: 'fecha',
        reciente: true,
      );

      if (rendimientosResult['success'] == true) {
        rendimientosMesaActual = rendimientosResult['rendimientos'];
      }

      // 4) Estadísticas (globales, opcional)
      final statsResult = await RendimientoRepository.obtenerEstadisticas();
      if (statsResult['success'] == true) {
        estadisticas = statsResult['estadisticas'];
      }

      if (mounted) setState(() {});
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
    final result = await JornadaRepository.iniciarJornada(
      mesa: widget.usuarioMesa,
      usuarioUsername: widget.usuarioUsername,
      usuarioNombre: widget.usuarioNombre,
    );

    if (result['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ ${result['message']}')),
        );
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
      usuarioUsername: widget.usuarioUsername,
    );

    if (result['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ ${result['message']}')),
        );
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
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  const SizedBox(height: 5),

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

                  const SizedBox(height: 20),

                  // BOTÓN REGRESAR AL INICIO
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back, color: Colors.black, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Regresar",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // TÍTULO
                  const Text(
                    "TU RENDIMIENTO",
                    style: TextStyle(color: Colors.white, fontSize: 30),
                  ),

                  const SizedBox(height: 10),

                  // INFO USUARIO
                  Text(
                    "${widget.usuarioNombre} - Mesa: ${widget.usuarioMesa}",
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),

                  const SizedBox(height: 20),

                  // TARJETA INFORMATIVA
                  Card(
                    color: Colors.grey[900],
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: const [
                          Icon(Icons.assessment, size: 50, color: Colors.yellow),
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
                            "Revisa tu productividad y estadísticas por fecha",
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
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ❌ ELIMINADO: _buildJornadaActualCard(),
          const SizedBox(height: 10),
          _buildEstadisticasSection(),
          const SizedBox(height: 20),
          _buildRendimientosRecientes(),
          const SizedBox(height: 20),
          _buildHistorialJornadas(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ====================== ESTADÍSTICAS + GRÁFICO ======================

  Widget _buildEstadisticasSection() {
    // Calcular estadísticas solo de la mesa actual
    final totalHorasMesa = historialJornadas
        .where((j) => j.horasTrabajadas != null)
        .fold(0.0, (sum, j) => sum + (j.horasTrabajadas ?? 0));

    final totalBonchesMesa = rendimientosMesaActual.fold(0, (sum, r) => sum + r.bonches);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ESTADÍSTICAS - MESA ${widget.usuarioMesa}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
        ),
        const SizedBox(height: 10),

        // ✅ GRÁFICO BONCHES POR FECHA
        _buildBonchesBarChart(),

        const SizedBox(height: 12),

        // ✅ CARDS SIN OVERFLOW (sin height fija)
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.8, // más ancho para evitar overflow en móvil
          children: [
            _buildStatCard(
              title: 'Jornadas',
              value: historialJornadas.length.toString(),
              icon: Icons.date_range,
              color: Colors.blue,
            ),
            _buildStatCard(
              title: 'Horas Trab.',
              value: totalHorasMesa.toStringAsFixed(1),
              icon: Icons.access_time,
              color: Colors.green,
            ),
            _buildStatCard(
              title: 'Rendimientos',
              value: rendimientosMesaActual.length.toString(),
              icon: Icons.assessment,
              color: Colors.orange,
            ),
            _buildStatCard(
              title: 'Bonches Total',
              value: totalBonchesMesa.toString(),
              icon: Icons.leaderboard,
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBonchesBarChart() {
    if (rendimientosMesaActual.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "Aún no hay rendimientos para graficar.",
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    // ✅ Agrupar bonches por fecha (día)
    final Map<String, int> bonchesPorFecha = {};
    for (final r in rendimientosMesaActual) {
      // Usamos el getter que ya muestras en UI (dd/MM/yyyy normalmente)
      final key = r.fechaFormatted;
      bonchesPorFecha[key] = (bonchesPorFecha[key] ?? 0) + r.bonches;
    }

    // ✅ Orden por fecha: asumimos formato dd/MM/yyyy
    final fechasOrdenadas = bonchesPorFecha.keys.toList()
      ..sort((a, b) {
        DateTime parse(String s) {
          final parts = s.split('/');
          if (parts.length != 3) return DateTime(1970);
          final d = int.tryParse(parts[0]) ?? 1;
          final m = int.tryParse(parts[1]) ?? 1;
          final y = int.tryParse(parts[2]) ?? 1970;
          return DateTime(y, m, d);
        }

        return parse(a).compareTo(parse(b));
      });

    // ✅ Limitar a últimas 7 fechas para que se vea bonito en móvil
    final lastDates = fechasOrdenadas.length > 7
        ? fechasOrdenadas.sublist(fechasOrdenadas.length - 7)
        : fechasOrdenadas;

    final values = lastDates.map((f) => bonchesPorFecha[f] ?? 0).toList();
    final maxY = (values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b)).toDouble();

    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < lastDates.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: (bonchesPorFecha[lastDates[i]] ?? 0).toDouble(),
              width: 16,
              borderRadius: BorderRadius.circular(6),
              // color NO especificado para respetar tu estilo; fl_chart toma por defecto.
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: SizedBox(
          height: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bonches por fecha (últimos ${lastDates.length})",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: BarChart(
                  BarChartData(
                    maxY: (maxY <= 0) ? 10 : (maxY + (maxY * 0.2)),
                    gridData: const FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                    barGroups: barGroups,
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 36),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 34,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < 0 || i >= lastDates.length) return const SizedBox.shrink();

                            // Mostrar solo dd/MM (sin año) para que no se amontone
                            final full = lastDates[i];
                            final parts = full.split('/');
                            final label = (parts.length == 3) ? "${parts[0]}/${parts[1]}" : full;

                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                label,
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: TextStyle(fontSize: 11, color: Colors.grey[700], height: 1.1),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====================== RENDIMIENTOS RECIENTES ======================

  Widget _buildRendimientosRecientes() {
    if (rendimientosMesaActual.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RENDIMIENTOS RECIENTES - MESA ${widget.usuarioMesa}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 300,
          child: Card(
            elevation: 3,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: rendimientosMesaActual.length,
              itemBuilder: (context, index) {
                final rendimiento = rendimientosMesaActual[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  leading: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: rendimiento.colorRendimiento.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      rendimiento.bonches > 20 ? Icons.star : Icons.work,
                      color: rendimiento.colorRendimiento,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    rendimiento.fechaFormatted,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  subtitle: Text(
                    '${rendimiento.bonches} bonches • ${rendimiento.horaInicioFormatted ?? ''}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  trailing: SizedBox(
                    width: 85,
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
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
              },
            ),
          ),
        ),
      ],
    );
  }

  // ====================== HISTORIAL JORNADAS ======================

  Widget _buildHistorialJornadas() {
    if (historialJornadas.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HISTORIAL DE JORNADAS - MESA ${widget.usuarioMesa}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 300,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: historialJornadas.length,
            itemBuilder: (context, index) {
              final jornada = historialJornadas[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  leading: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: jornada.estadoColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(jornada.estadoIcon, color: jornada.estadoColor, size: 22),
                  ),
                  title: Text(
                    jornada.fechaFormatted,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
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
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 3),
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
            },
          ),
        ),
      ],
    );
  }
}
