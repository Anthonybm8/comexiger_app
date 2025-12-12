import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Etiquetas extends StatefulWidget {
  const Etiquetas({super.key});

  @override
  State<Etiquetas> createState() => _EtiquetasState();
}

class _EtiquetasState extends State<Etiquetas> {
  // Variables para controlar los dropdowns y campo de texto
  String? _variedadSeleccionada;
  String? _mesaSeleccionada;

  // Controlador para el campo de texto de unidad
  final TextEditingController _unidadController = TextEditingController();

  // Variable para almacenar el contenido del QR
  String _qrData = "Esperando datos...";

  // Listas de opciones
  final List<String> _variedades = ['Mandala', 'Fruteto', 'Mondial'];

  final List<String> _mesas = ['Mesa 1', 'Mesa 2', 'Mesa 3', 'Mesa 4'];

  @override
  void initState() {
    super.initState();
    // Escuchar cambios en los campos para actualizar el QR
    _unidadController.addListener(_actualizarQR);
  }

  @override
  void dispose() {
    _unidadController.removeListener(_actualizarQR);
    _unidadController.dispose();
    super.dispose();
  }

  // Función para actualizar el QR cuando cambian los datos
  void _actualizarQR() {
    if (_variedadSeleccionada != null &&
        _unidadController.text.isNotEmpty &&
        _mesaSeleccionada != null) {
      // Formatear los datos para el QR
      setState(() {
        _qrData =
            "Variedad: $_variedadSeleccionada\n"
            "Unidad: ${_unidadController.text}\n"
            "Mesa: $_mesaSeleccionada\n"
            "Fecha: ${DateTime.now().toString().split(' ')[0]}\n"
            "ID: ${DateTime.now().millisecondsSinceEpoch}";
      });
    } else {
      setState(() {
        _qrData = "Esperando datos...";
      });
    }
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
                // Contenedor del QR
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey, width: 2),
                  ),
                  child: Center(
                    child:
                        _variedadSeleccionada != null &&
                            _unidadController.text.isNotEmpty &&
                            _mesaSeleccionada != null
                        ? QrImageView(
                            data: _qrData,
                            version: QrVersions.auto,
                            size: 180,
                            backgroundColor: Colors.white,
                            eyeStyle: QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: Colors.black,
                            ),
                            dataModuleStyle: QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: Colors.black,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code_scanner,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Complete los datos",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                "para generar QR",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                SizedBox(height: 20),
                // Texto que muestra los datos del QR
                Container(
                  width: 250,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Datos del QR:",
                        style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        _qrData,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Contenedor de Variedad con Dropdown
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
                // Contenedor de Unidad (campo de texto) y Mesa (dropdown)
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
                      // Campo de texto para unidad (solo números)
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
                          // Validación para permitir solo números
                          if (value.isNotEmpty &&
                              !RegExp(r'^[0-9]+$').hasMatch(value)) {
                            // Remover caracteres no numéricos
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
                    ],
                  ),
                ),
                SizedBox(height: 40),
                // Botón IMPRIMIR
                ElevatedButton(
                  onPressed: () {
                    // Lógica para imprimir
                    if (_variedadSeleccionada == null ||
                        _unidadController.text.isEmpty ||
                        _mesaSeleccionada == null) {
                      // Mostrar mensaje de error si no se han completado todos los campos
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Por favor, complete todos los campos'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      // Aquí va la lógica de impresión
                      final unidad = _unidadController.text;
                      print('Variedad: $_variedadSeleccionada');
                      print('Unidad: $unidad');
                      print('Mesa: $_mesaSeleccionada');
                      print('QR Data: $_qrData');

                      // Puedes mostrar un mensaje de éxito
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Etiquetas enviadas a impresión\n'
                            'QR generado correctamente',
                          ),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 3),
                        ),
                      );

                      // Aquí podrías agregar la lógica de impresión real
                      // Por ejemplo, enviar el QR a una impresora
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
}
