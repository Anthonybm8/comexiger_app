// models/jornada_model.dart
import 'package:flutter/material.dart';

class JornadaModel {
  int? id;
  String usuarioUsername;
  String usuarioNombre;
  String mesa;
  DateTime fecha;
  DateTime horaInicio;
  DateTime? horaFin;
  String estado;
  double? horasTrabajadas;

  JornadaModel({
    this.id,
    required this.usuarioUsername,
    required this.usuarioNombre,
    required this.mesa,
    required this.fecha,
    required this.horaInicio,
    this.horaFin,
    required this.estado,
    this.horasTrabajadas,
  });

  factory JornadaModel.fromJson(Map<String, dynamic> json) {
    return JornadaModel(
      id: json['id'],
      usuarioUsername: json['usuario_username'] ?? '',
      usuarioNombre: json['usuario_nombre'] ?? '',
      mesa: json['mesa'] ?? '',
      fecha: DateTime.parse(json['fecha']),
      horaInicio: DateTime.parse(json['hora_inicio']),
      horaFin: json['hora_fin'] != null
          ? DateTime.parse(json['hora_fin'])
          : null,
      estado: json['estado'] ?? 'iniciada',
      horasTrabajadas: json['horas_trabajadas']?.toDouble(),
    );
  }

  Map<String, dynamic> toJsonForIniciar() {
    return {
      'usuario_username': usuarioUsername,
      'usuario_nombre': usuarioNombre,
      'mesa': mesa,
    };
  }

  Map<String, dynamic> toJsonForFinalizar() {
    return {'usuario_username': usuarioUsername};
  }

  String get horaInicioFormatted {
    return '${horaInicio.hour.toString().padLeft(2, '0')}:${horaInicio.minute.toString().padLeft(2, '0')}';
  }

  String? get horaFinFormatted {
    if (horaFin == null) return null;
    return '${horaFin!.hour.toString().padLeft(2, '0')}:${horaFin!.minute.toString().padLeft(2, '0')}';
  }

  String get fechaFormatted {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  String get duracionFormatted {
    if (horasTrabajadas == null) return 'En curso';
    final horas = horasTrabajadas!.floor();
    final minutos = ((horasTrabajadas! - horas) * 60).round();
    return '${horas}h ${minutos}m';
  }

  bool get estaActiva => estado == 'iniciada';

  Color get estadoColor {
    switch (estado) {
      case 'iniciada':
        return Colors.green;
      case 'finalizada':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData get estadoIcon {
    switch (estado) {
      case 'iniciada':
        return Icons.play_arrow;
      case 'finalizada':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  String get estadoTexto {
    switch (estado) {
      case 'iniciada':
        return 'En Progreso';
      case 'finalizada':
        return 'Finalizada';
      default:
        return estado;
    }
  }

  @override
  String toString() {
    return 'Jornada{id: $id, usuario: $usuarioUsername, fecha: $fecha, estado: $estado}';
  }
}

class JornadaActualResponse {
  bool tieneJornadaActiva;
  JornadaModel? jornadaActiva;
  JornadaModel? ultimaJornada;

  JornadaActualResponse({
    required this.tieneJornadaActiva,
    this.jornadaActiva,
    this.ultimaJornada,
  });

  factory JornadaActualResponse.fromJson(Map<String, dynamic> json) {
    return JornadaActualResponse(
      tieneJornadaActiva: json['tiene_jornada_activa'] ?? false,
      jornadaActiva: json['jornada_activa'] != null
          ? JornadaModel.fromJson(json['jornada_activa'])
          : null,
      ultimaJornada: json['ultima_jornada'] != null
          ? JornadaModel.fromJson(json['ultima_jornada'])
          : null,
    );
  }
}

class HistorialJornadasResponse {
  int totalJornadas;
  double totalHoras;
  List<JornadaModel> jornadas;

  HistorialJornadasResponse({
    required this.totalJornadas,
    required this.totalHoras,
    required this.jornadas,
  });

  factory HistorialJornadasResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> jornadasData = json['jornadas'] ?? [];
    return HistorialJornadasResponse(
      totalJornadas: json['total_jornadas'] ?? 0,
      totalHoras: json['total_horas']?.toDouble() ?? 0.0,
      jornadas: jornadasData.map((j) => JornadaModel.fromJson(j)).toList(),
    );
  }
}
