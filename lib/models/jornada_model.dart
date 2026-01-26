// lib/models/jornada_model.dart
import 'package:flutter/material.dart';

class JornadaModel {
  final int id;
  final String mesa;
  final DateTime fechaEntrada;
  final DateTime horaInicio;
  final DateTime? horaFin;
  final double? horasTrabajadas;

  JornadaModel({
    required this.id,
    required this.mesa,
    required this.fechaEntrada,
    required this.horaInicio,
    this.horaFin,
    this.horasTrabajadas,
  });

  // ------------------------------
  // Helpers seguros para DateTime
  // ------------------------------
  static DateTime _parseDateTimeSafe(dynamic value) {
  if (value == null) return DateTime.now();
  final s = value.toString().trim();
  if (s.isEmpty) return DateTime.now();

  // ✅ CLAVE: convertir a hora local (Ecuador)
  return DateTime.parse(s).toLocal();
}


  factory JornadaModel.fromJson(Map<String, dynamic> json) {
    return JornadaModel(
      id: (json['id'] ?? 0) as int,
      mesa: (json['numero_mesa'] ?? json['mesa'] ?? '').toString(),
      fechaEntrada: _parseDateTimeSafe(json['fecha_entrada']),
      horaInicio: _parseDateTimeSafe(json['hora_inicio']),
      horaFin: json['hora_final'] != null
          ? _parseDateTimeSafe(json['hora_final'])
          : null,
      horasTrabajadas: json['horas_trabajadas'] != null
          ? (json['horas_trabajadas'] as num).toDouble()
          : null,
    );
  }

  // ------------------------------
  // Estado / UI helpers
  // ------------------------------
  bool get estaActiva => horaFin == null;

  // ✅ esto arregla tu error: _jornadaActual?.estado
  String get estado => estaActiva ? 'iniciada' : 'finalizada';

  Color get estadoColor => estaActiva ? Colors.green : Colors.blue;
  IconData get estadoIcon => estaActiva ? Icons.play_arrow : Icons.check_circle;
  String get estadoTexto => estaActiva ? 'En Progreso' : 'Finalizada';

  // ------------------------------
  // Formatos
  // ------------------------------
  String get horaInicioFormatted =>
      '${horaInicio.hour.toString().padLeft(2, '0')}:${horaInicio.minute.toString().padLeft(2, '0')}';

  String? get horaFinFormatted {
    if (horaFin == null) return null;
    return '${horaFin!.hour.toString().padLeft(2, '0')}:${horaFin!.minute.toString().padLeft(2, '0')}';
  }

  String get fechaFormatted =>
      '${fechaEntrada.day.toString().padLeft(2, '0')}/${fechaEntrada.month.toString().padLeft(2, '0')}/${fechaEntrada.year}';

  @override
  String toString() => 'Jornada{id:$id, mesa:$mesa, estado:$estado}';
}

// ===============================
// WRAPPERS compatibles con tu código
// ===============================
class JornadaActualResponse {
  final bool tieneJornadaActiva;
  final JornadaModel? jornadaActiva;
  final JornadaModel? ultimaJornada;

  JornadaActualResponse({
    required this.tieneJornadaActiva,
    this.jornadaActiva,
    this.ultimaJornada,
  });

  factory JornadaActualResponse.fromJson(Map<String, dynamic> json) {
    // ✅ soporta: activa / jornada_activa
    final dynamic activaRaw = json['jornada_activa'] ?? json['activa'];

    // ✅ soporta: tiene_jornada_activa o lo calcula
    final bool tieneActiva =
        (json['tiene_jornada_activa'] == true) || (activaRaw != null);

    return JornadaActualResponse(
      tieneJornadaActiva: tieneActiva,
      jornadaActiva: activaRaw != null
          ? JornadaModel.fromJson(activaRaw as Map<String, dynamic>)
          : null,
      ultimaJornada: json['ultima_jornada'] != null
          ? JornadaModel.fromJson(json['ultima_jornada'] as Map<String, dynamic>)
          : null,
    );
  }

}

class HistorialJornadasResponse {
  final int totalJornadas;
  final double totalHoras;
  final List<JornadaModel> jornadas;

  HistorialJornadasResponse({
    required this.totalJornadas,
    required this.totalHoras,
    required this.jornadas,
  });

  factory HistorialJornadasResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> jornadasData = (json['jornadas'] ?? []) as List<dynamic>;

    return HistorialJornadasResponse(
      totalJornadas: json['total_jornadas'] ?? 0,
      totalHoras: json['total_horas'] != null
          ? (json['total_horas'] as num).toDouble()
          : 0.0,
      jornadas: jornadasData.map((j) => JornadaModel.fromJson(j)).toList(),
    );
  }
}
