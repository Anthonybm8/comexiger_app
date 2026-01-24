import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class Etiquetas extends StatefulWidget {
  const Etiquetas({super.key});

  @override
  State<Etiquetas> createState() => _EtiquetasState();
}

class _EtiquetasState extends State<Etiquetas> {
  final ScreenshotController screenshotController = ScreenshotController();

  String? _variedadSeleccionada;
  String? _mesaSeleccionada;
  String? _medidaSeleccionada;

  String _qrData = "Esperando datos...";

  final List<String> _variedades = ['Mandala', 'Fruteto', 'Mondial'];
  final List<String> _mesas = ['Mesa 1', 'Mesa 2', 'Mesa 3', 'Mesa 4'];
  final List<String> _medidas = ['40', '50', '60', '70', '80', '90', 'OPE'];

  void _actualizarQR() {
    if (_variedadSeleccionada != null &&
        _mesaSeleccionada != null &&
        _medidaSeleccionada != null) {
      final fecha = DateTime.now();
      final idUnico = fecha.microsecondsSinceEpoch
          .toRadixString(16)
          .toUpperCase();

      // Obtener solo el número de la mesa
      final numeroMesa = _mesaSeleccionada!.replaceAll('Mesa ', '').trim();

      setState(() {
        // Formato CORREGIDO con Ñ y ] como separadores
        _qrData =
            "IDÑ$idUnico ] MesaÑ$numeroMesa ] FlorÑ$_variedadSeleccionada ] MedidaÑ$_medidaSeleccionada ] FechaÑ${fecha.day}-${fecha.month}-${fecha.year}";
      });
    }
  }

  Future<void> _compartirEtiqueta() async {
    if (_variedadSeleccionada == null ||
        _mesaSeleccionada == null ||
        _medidaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Complete todos los campos"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _actualizarQR();

    await Future.delayed(const Duration(milliseconds: 200));

    final image = await screenshotController.capture();
    if (image == null) return;

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/etiqueta_qr.png');
    await file.writeAsBytes(image);

    await Share.shareXFiles([XFile(file.path)], text: 'Etiqueta QR');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            // LOGO
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

            // BOTÓN REGRESAR
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/menu');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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

            const SizedBox(height: 30),
            const Text(
              "IMPRIMIR ETIQUETAS",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            /// -------- ETIQUETA CAPTURABLE --------
            Screenshot(
              controller: screenshotController,
              child: Container(
                width: 280,
                height: 280,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: _variedadSeleccionada == null
                    ? const Center(child: Text("Complete datos"))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          QrImageView(data: _qrData, size: 140),

                          const SizedBox(height: 10),

                          Text(
                            _variedadSeleccionada!,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            "$_mesaSeleccionada | Medida: $_medidaSeleccionada",
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 30),

            /// VARIEDAD
            _dropdown("Variedad", _variedades, _variedadSeleccionada, (v) {
              setState(() => _variedadSeleccionada = v);
              _actualizarQR();
            }),

            const SizedBox(height: 15),

            /// MESA
            _dropdown("Mesa", _mesas, _mesaSeleccionada, (v) {
              setState(() => _mesaSeleccionada = v);
              _actualizarQR();
            }),

            const SizedBox(height: 15),

            /// MEDIDA
            _dropdown("Medida", _medidas, _medidaSeleccionada, (v) {
              setState(() => _medidaSeleccionada = v);
              _actualizarQR();
            }),

            const SizedBox(height: 30),

            /// BOTON COMPARTIR
            ElevatedButton(
              onPressed: _compartirEtiqueta,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "COMPARTIR / IMPRIMIR",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown(
    String label,
    List<String> items,
    String? value,
    Function(String?) onChange,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(label),
          items: items.map((e) {
            return DropdownMenuItem(value: e, child: Text(e));
          }).toList(),
          onChanged: onChange,
        ),
      ),
    );
  }
}
