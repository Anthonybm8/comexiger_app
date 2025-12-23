import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Etiquetas extends StatefulWidget {
  const Etiquetas({super.key});

  @override
  State<Etiquetas> createState() => _EtiquetasState();
}

class _EtiquetasState extends State<Etiquetas> {
  String? _variedadSeleccionada;
  String? _mesaSeleccionada;
  String? _medidaSeleccionada;
  final TextEditingController _unidadController = TextEditingController();
  String _qrData = "Esperando datos...";

  final List<String> _variedades = ['Mandala', 'Fruteto', 'Mondial'];
  final List<String> _mesas = ['Mesa 1', 'Mesa 2', 'Mesa 3', 'Mesa 4'];
  final List<String> _medidas = ['40', '50', '60', '70', '80', '90', 'OPE'];

  @override
  void initState() {
    super.initState();
    _unidadController.addListener(_actualizarQR);
  }

  @override
  void dispose() {
    _unidadController.removeListener(_actualizarQR);
    _unidadController.dispose();
    super.dispose();
  }

  void _actualizarQR() {
    if (_variedadSeleccionada != null &&
        _unidadController.text.isNotEmpty &&
        _mesaSeleccionada != null &&
        _medidaSeleccionada != null) {
      setState(() {
        _qrData =
            "Variedad: $_variedadSeleccionada\n"
            "Unidad: ${_unidadController.text}\n"
            "Mesa: $_mesaSeleccionada\n"
            "Medida: $_medidaSeleccionada\n"
            "Fecha: ${DateTime.now().toString().split(' ')[0]}\n"
            "ID: ${DateTime.now().millisecondsSinceEpoch}";
      });
    } else {
      setState(() {
        _qrData = "Esperando datos...";
      });
    }
  }

  String _obtenerFechaFormateada() {
    final ahora = DateTime.now();
    final meses = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return "${ahora.day} ${meses[ahora.month - 1]} ${ahora.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 5),
                SizedBox(
                  width: 300,
                  height: 150,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset("assets/logo.jpg", fit: BoxFit.contain),
                  ),
                ),
                SizedBox(height: 20),
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
                Text(
                  "IMPRIMIR ETIQUETAS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 40),
                // ETIQUETA CIRCULAR
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child:
                      _variedadSeleccionada != null &&
                          _unidadController.text.isNotEmpty &&
                          _mesaSeleccionada != null &&
                          _medidaSeleccionada != null
                      ? Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // QR Code
                              Container(
                                width: 140,
                                height: 140,
                                child: QrImageView(
                                  data: _qrData,
                                  version: QrVersions.auto,
                                  size: 140,
                                  backgroundColor: Colors.white,
                                  eyeStyle: QrEyeStyle(
                                    eyeShape: QrEyeShape.square,
                                    color: Colors.black,
                                  ),
                                  dataModuleStyle: QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.square,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              // Variedad
                              Text(
                                _variedadSeleccionada!,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 6),
                              // Mesa y Medida
                              Text(
                                "$_mesaSeleccionada | Medida: $_medidaSeleccionada",
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.qr_code_scanner,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 15),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 30),
                              child: Text(
                                "Complete los datos\npara generar\nla etiqueta",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                ),
                SizedBox(height: 30),
                // Información de la etiqueta
                if (_variedadSeleccionada != null &&
                    _unidadController.text.isNotEmpty &&
                    _mesaSeleccionada != null &&
                    _medidaSeleccionada != null)
                  Container(
                    width: 280,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.yellow, width: 2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Información de etiqueta",
                          style: TextStyle(
                            color: Colors.yellow,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Divider(color: Colors.yellow.withOpacity(0.3)),
                        _buildInfoRow("Variedad:", _variedadSeleccionada!),
                        _buildInfoRow("Unidad:", _unidadController.text),
                        _buildInfoRow("Mesa:", _mesaSeleccionada!),
                        _buildInfoRow("Medida:", _medidaSeleccionada!),
                        _buildInfoRow("Fecha:", _obtenerFechaFormateada()),
                      ],
                    ),
                  ),
                SizedBox(height: 30),
                // Contenedor de Variedad
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Escoja la variedad:",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _variedadSeleccionada,
                            hint: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                "Select...",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            icon: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey[600],
                              ),
                            ),
                            items: _variedades.map((String variedad) {
                              return DropdownMenuItem<String>(
                                value: variedad,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  child: Text(
                                    variedad,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _variedadSeleccionada = newValue;
                              });
                              _actualizarQR();
                            },
                            style: TextStyle(color: Colors.black),
                            dropdownColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                // Contenedor de Unidad y Mesa
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Unidad:",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _unidadController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Ejemplo: 25",
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.yellow),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 12,
                          ),
                        ),
                        style: TextStyle(color: Colors.black, fontSize: 16),
                        onChanged: (value) {
                          if (value.isNotEmpty &&
                              !RegExp(r'^[0-9]+$').hasMatch(value)) {
                            _unidadController.text = value.replaceAll(
                              RegExp(r'[^0-9]'),
                              '',
                            );
                            _unidadController.selection =
                                TextSelection.fromPosition(
                                  TextPosition(
                                    offset: _unidadController.text.length,
                                  ),
                                );
                          }
                          _actualizarQR();
                        },
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Mesa:",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _mesaSeleccionada,
                            hint: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                "Select...",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            icon: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey[600],
                              ),
                            ),
                            items: _mesas.map((String mesa) {
                              return DropdownMenuItem<String>(
                                value: mesa,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  child: Text(
                                    mesa,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _mesaSeleccionada = newValue;
                              });
                              _actualizarQR();
                            },
                            style: TextStyle(color: Colors.black),
                            dropdownColor: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Medida:",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _medidaSeleccionada,
                            hint: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                "Select...",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            icon: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey[600],
                              ),
                            ),
                            items: _medidas.map((String medida) {
                              return DropdownMenuItem<String>(
                                value: medida,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  child: Text(
                                    medida,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _medidaSeleccionada = newValue;
                              });
                              _actualizarQR();
                            },
                            style: TextStyle(color: Colors.black),
                            dropdownColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                // Botón IMPRIMIR
                ElevatedButton(
                  onPressed: () {
                    if (_variedadSeleccionada == null ||
                        _unidadController.text.isEmpty ||
                        _mesaSeleccionada == null ||
                        _medidaSeleccionada == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Por favor, complete todos los campos'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      final unidad = _unidadController.text;
                      print('Variedad: $_variedadSeleccionada');
                      print('Unidad: $unidad');
                      print('Mesa: $_mesaSeleccionada');
                      print('Medida: $_medidaSeleccionada');
                      print('QR Data: $_qrData');

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Etiqueta circular enviada a impresión\n'
                            'QR generado correctamente',
                          ),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "IMPRIMIR",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
