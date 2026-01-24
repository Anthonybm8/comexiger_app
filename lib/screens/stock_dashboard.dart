// screens/stock_dashboard.dart
import 'package:flutter/material.dart';
import '../repositories/disponibilidad_repository.dart';
import '../models/disponibilidad_model.dart';

class StockDashboard extends StatefulWidget {
  const StockDashboard({super.key});

  @override
  State<StockDashboard> createState() => _StockDashboardState();
}

class _StockDashboardState extends State<StockDashboard> {
  // Estados
  List<DisponibilidadModel> disponibilidades = [];
  List<DisponibilidadModel> disponibilidadesActivas = [];
  EstadisticasDisponibilidad? estadisticas;
  bool isLoading = true;
  String filtroVariedad = '';
  String filtroMedida = '';
  TextEditingController variedadController = TextEditingController();
  TextEditingController medidaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    if (!mounted) return;

    setState(() => isLoading = true);

    try {
      // 1. Obtener todas las disponibilidades
      final result =
          await DisponibilidadRepository.obtenerTodasDisponibilidades(
            ordenar: 'fecha',
            reciente: true,
          );

      if (result['success'] == true) {
        setState(() {
          disponibilidades = result['disponibilidades'];
        });
      }

      // 2. Obtener disponibilidades activas
      final activasResult =
          await DisponibilidadRepository.obtenerDisponibilidadesActivas();
      if (activasResult['success'] == true) {
        setState(() {
          disponibilidadesActivas = activasResult['disponibilidades'];
        });
      }

      // 3. Obtener estadísticas
      final statsResult = await DisponibilidadRepository.obtenerEstadisticas();
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
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // Filtrar disponibilidades según criterios
  List<DisponibilidadModel> get _disponibilidadesFiltradas {
    var result = disponibilidadesActivas;

    if (filtroVariedad.isNotEmpty) {
      result = result
          .where(
            (d) =>
                d.variedad.toLowerCase().contains(filtroVariedad.toLowerCase()),
          )
          .toList();
    }

    if (filtroMedida.isNotEmpty) {
      result = result
          .where(
            (d) => d.medida.toLowerCase().contains(filtroMedida.toLowerCase()),
          )
          .toList();
    }

    // Ordenar por variedad y medida
    result.sort((a, b) {
      final variedadCompare = a.variedad.compareTo(b.variedad);
      if (variedadCompare != 0) return variedadCompare;
      return a.medida.compareTo(b.medida);
    });

    return result;
  }

  // Agrupar por variedad y medida
  Map<String, Map<String, List<DisponibilidadModel>>>
  get _disponibilidadesAgrupadas {
    final Map<String, Map<String, List<DisponibilidadModel>>> agrupadas = {};

    for (final dispo in _disponibilidadesFiltradas) {
      if (!agrupadas.containsKey(dispo.variedad)) {
        agrupadas[dispo.variedad] = {};
      }

      if (!agrupadas[dispo.variedad]!.containsKey(dispo.medida)) {
        agrupadas[dispo.variedad]![dispo.medida] = [];
      }

      agrupadas[dispo.variedad]![dispo.medida]!.add(dispo);
    }

    return agrupadas;
  }

  // Calcular stock total por variedad-medida
  int _calcularStockTotal(String variedad, String medida) {
    final items = _disponibilidadesAgrupadas[variedad]?[medida] ?? [];
    return items.fold(0, (sum, item) => sum + item.stock);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Stock Disponible',
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
          IconButton(
            icon: Icon(Icons.filter_alt, color: Colors.white),
            onPressed: _mostrarFiltros,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildContenido(),
    );
  }

  Widget _buildContenido() {
    return Column(
      children: [
        // ==================== FILTROS ====================
        if (filtroVariedad.isNotEmpty || filtroMedida.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.blue[50],
            child: Row(
              children: [
                Icon(Icons.filter_list, size: 16, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Filtros activos: ',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
                if (filtroVariedad.isNotEmpty)
                  Chip(
                    label: Text('Variedad: $filtroVariedad'),
                    onDeleted: () => setState(() => filtroVariedad = ''),
                  ),
                if (filtroMedida.isNotEmpty)
                  Chip(
                    label: Text('Medida: $filtroMedida'),
                    onDeleted: () => setState(() => filtroMedida = ''),
                  ),
                Spacer(),
                TextButton(
                  onPressed: () => setState(() {
                    filtroVariedad = '';
                    filtroMedida = '';
                  }),
                  child: Text('Limpiar', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),

        // ==================== ESTADÍSTICAS ====================
        _buildEstadisticasSection(),

        // ==================== TABLA DE STOCK ====================
        Expanded(child: _buildTablaStock()),
      ],
    );
  }

  Widget _buildEstadisticasSection() {
    if (estadisticas == null) return Container();

    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RESUMEN GENERAL',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildEstadisticaCard(
                title: 'Stock Total',
                value: estadisticas!.stockTotal.toString(),
                icon: Icons.inventory,
                color: Colors.blue,
              ),
              _buildEstadisticaCard(
                title: 'Activos',
                value: estadisticas!.registrosActivos.toString(),
                icon: Icons.check_circle,
                color: Colors.green,
              ),
              _buildEstadisticaCard(
                title: 'Mesas',
                value: estadisticas!.mesasActivas.toString(),
                icon: Icons.table_chart,
                color: Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticaCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 30, color: color),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildTablaStock() {
    final agrupadas = _disponibilidadesAgrupadas;

    if (agrupadas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay stock disponible',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            if (filtroVariedad.isNotEmpty || filtroMedida.isNotEmpty)
              TextButton(
                onPressed: () => setState(() {
                  filtroVariedad = '';
                  filtroMedida = '';
                }),
                child: Text('Limpiar filtros'),
              ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Variedad')),
          DataColumn(label: Text('Medida')),
          DataColumn(label: Text('Stock'), numeric: true),
          DataColumn(label: Text('Estado')),
          DataColumn(label: Text('Mesas')),
        ],
        rows: _buildRowsTabla(agrupadas),
      ),
    );
  }

  List<DataRow> _buildRowsTabla(
    Map<String, Map<String, List<DisponibilidadModel>>> agrupadas,
  ) {
    final List<DataRow> rows = [];

    agrupadas.forEach((variedad, medidas) {
      medidas.forEach((medida, items) {
        final stockTotal = _calcularStockTotal(variedad, medida);
        final mesas = items.map((item) => item.numeroMesa).toSet().toList();
        final mesasTexto = mesas.length <= 3
            ? mesas.join(', ')
            : '${mesas.take(3).join(', ')}... (+${mesas.length - 3})';

        rows.add(
          DataRow(
            cells: [
              DataCell(
                Text(variedad),
                onTap: () => _filtrarPorVariedad(variedad),
              ),
              DataCell(Text(medida), onTap: () => _filtrarPorMedida(medida)),
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getColorStock(stockTotal).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    stockTotal.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getColorStock(stockTotal),
                    ),
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getColorStock(stockTotal).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getNivelStock(stockTotal),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getColorStock(stockTotal),
                    ),
                  ),
                ),
              ),
              DataCell(
                Tooltip(
                  message: 'Mesas: ${mesas.join(', ')}',
                  child: Text(mesasTexto, style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        );
      });
    });

    return rows;
  }

  Color _getColorStock(int stock) {
    if (stock == 0) return Colors.red;
    if (stock <= 10) return Colors.orange;
    if (stock <= 30) return Colors.yellow;
    return Colors.green;
  }

  String _getNivelStock(int stock) {
    if (stock == 0) return 'Agotado';
    if (stock <= 10) return 'Bajo';
    if (stock <= 30) return 'Medio';
    return 'Alto';
  }

  void _filtrarPorVariedad(String variedad) {
    setState(() {
      filtroVariedad = variedad;
    });
  }

  void _filtrarPorMedida(String medida) {
    setState(() {
      filtroMedida = medida;
    });
  }

  void _mostrarFiltros() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filtrar Stock'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: variedadController,
                decoration: InputDecoration(
                  labelText: 'Variedad',
                  hintText: 'Ej: Rosas, Tulipanes...',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: medidaController,
                decoration: InputDecoration(
                  labelText: 'Medida',
                  hintText: 'Ej: 50cm, Grande...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  filtroVariedad = variedadController.text.trim();
                  filtroMedida = medidaController.text.trim();
                });
                Navigator.pop(context);
              },
              child: Text('Aplicar Filtros'),
            ),
          ],
        );
      },
    );
  }
}
