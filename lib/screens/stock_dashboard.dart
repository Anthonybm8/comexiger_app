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
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        // HACER TODO DESPLAZABLE
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
                    "STOCK DISPONIBLE",
                    style: TextStyle(color: Colors.white, fontSize: 30),
                  ),

                  SizedBox(height: 40),

                  // TARJETA INFORMATIVA
                  Card(
                    color: Colors.grey[900],
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(Icons.inventory, size: 50, color: Colors.yellow),
                          SizedBox(height: 10),
                          Text(
                            "Control de Stock",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Consulta el stock disponible por variedad y medida",
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
    return Column(
      children: [
        // ==================== FILTROS ====================
        if (filtroVariedad.isNotEmpty || filtroMedida.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                    backgroundColor: Colors.blue[100],
                    onDeleted: () => setState(() => filtroVariedad = ''),
                  ),
                if (filtroMedida.isNotEmpty)
                  Chip(
                    label: Text('Medida: $filtroMedida'),
                    backgroundColor: Colors.blue[100],
                    onDeleted: () => setState(() => filtroMedida = ''),
                  ),
                Spacer(),
                ElevatedButton(
                  onPressed: () => setState(() {
                    filtroVariedad = '';
                    filtroMedida = '';
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Limpiar', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),

        // ==================== ESTADÍSTICAS ====================
        _buildEstadisticasSection(),

        SizedBox(height: 20),

        // ==================== LISTA DE STOCK POR VARIEDAD ====================
        _buildListaStock(),

        SizedBox(height: 40),
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
              color: Colors.black,
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
    return Container(
      width: 100,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 28, color: color),
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
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildListaStock() {
    final agrupadas = _disponibilidadesAgrupadas;

    if (agrupadas.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory, size: 60, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                'No hay stock disponible',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 20),
              if (filtroVariedad.isNotEmpty || filtroMedida.isNotEmpty)
                ElevatedButton(
                  onPressed: () => setState(() {
                    filtroVariedad = '';
                    filtroMedida = '';
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Limpiar filtros'),
                ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _mostrarFiltros,
                icon: Icon(Icons.filter_alt, size: 18),
                label: Text('Buscar stock'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Stock por Variedad',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              Spacer(),
              ElevatedButton.icon(
                onPressed: _mostrarFiltros,
                icon: Icon(Icons.filter_alt, size: 16),
                label: Text('Filtrar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),

          // LISTA DE VARIEDADES
          ..._buildItemsLista(agrupadas),
        ],
      ),
    );
  }

  List<Widget> _buildItemsLista(
    Map<String, Map<String, List<DisponibilidadModel>>> agrupadas,
  ) {
    final List<Widget> items = [];
    final List<String> variedades = agrupadas.keys.toList()..sort();

    for (final variedad in variedades) {
      final medidas = agrupadas[variedad]!;
      final List<String> medidasList = medidas.keys.toList()..sort();

      // Agregar título de variedad
      items.add(
        Container(
          margin: EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.category, color: Colors.blue, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  variedad,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.search, size: 18, color: Colors.blue),
                onPressed: () => _filtrarPorVariedad(variedad),
                tooltip: 'Filtrar por esta variedad',
              ),
            ],
          ),
        ),
      );

      // Agregar medidas de esta variedad
      for (final medida in medidasList) {
        final stockTotal = _calcularStockTotal(variedad, medida);
        final mesas = medidas[medida]!
            .map((item) => item.numeroMesa)
            .toSet()
            .toList();
        final mesasTexto = mesas.length <= 3
            ? mesas.join(', ')
            : '${mesas.take(3).join(', ')}... (+${mesas.length - 3})';

        items.add(
          Card(
            margin: EdgeInsets.only(bottom: 8, left: 20),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getColorStock(stockTotal).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    stockTotal.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getColorStock(stockTotal),
                    ),
                  ),
                ),
              ),
              title: Text(
                medida,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getColorStock(stockTotal).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getNivelStock(stockTotal),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getColorStock(stockTotal),
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.table_chart, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Mesas: $mesasTexto',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.search, size: 18, color: Colors.blue),
                onPressed: () => _filtrarPorMedida(medida),
                tooltip: 'Filtrar por esta medida',
              ),
            ),
          ),
        );
      }

      items.add(SizedBox(height: 10)); // Espacio entre variedades
    }

    return items;
  }

  Color _getColorStock(int stock) {
    if (stock == 0) return Colors.red;
    if (stock <= 10) return Colors.orange[700]!;
    if (stock <= 30) return Colors.yellow[700]!;
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
          title: Row(
            children: [
              Icon(Icons.filter_alt, color: Colors.blue),
              SizedBox(width: 10),
              Text(
                'Filtrar Stock',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: variedadController,
                decoration: InputDecoration(
                  labelText: 'Variedad',
                  hintText: 'Ej: Rosas, Tulipanes...',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: medidaController,
                decoration: InputDecoration(
                  labelText: 'Medida',
                  hintText: 'Ej: 50cm, Grande...',
                  prefixIcon: Icon(Icons.straighten),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
              ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text('Aplicar Filtros'),
            ),
          ],
        );
      },
    );
  }
}
