// models/rendimiento_model.dart
import 'package:flutter/material.dart'; // <-- AÑADE ESTA LÍNEA

class RendimientoModel {
  int? id;
  String? qrId;
  String numeroMesa;
  DateTime fechaEntrada;
  DateTime? horaInicio;
  DateTime? horaFinal;
  int rendimiento;
  int ramosBase;
  int bonches;
  double? horasTrabajadas;
  double? ramosEsperados;
  double? ramosExtras;
  double? extrasPorHora;

  RendimientoModel({
    this.id,
    this.qrId,
    required this.numeroMesa,
    required this.fechaEntrada,
    this.horaInicio,
    this.horaFinal,
    required this.rendimiento,
    required this.ramosBase,
    required this.bonches,
    this.horasTrabajadas,
    this.ramosEsperados,
    this.ramosExtras,
    this.extrasPorHora,
  });

  factory RendimientoModel.fromJson(Map<String, dynamic> json) {
    return RendimientoModel(
      id: json['id'],
      qrId: json['qr_id'],
      numeroMesa: json['numero_mesa'] ?? '',
      fechaEntrada: DateTime.parse(json['fecha_entrada']),
      horaInicio: json['hora_inicio'] != null
          ? DateTime.parse(json['hora_inicio'])
          : null,
      horaFinal: json['hora_final'] != null
          ? DateTime.parse(json['hora_final'])
          : null,
      rendimiento: json['rendimiento'] ?? 0,
      ramosBase: json['ramos_base'] ?? 0,
      bonches: json['bonches'] ?? 0,
      horasTrabajadas: json['horas_trabajadas']?.toDouble(),
      ramosEsperados: json['ramos_esperados']?.toDouble(),
      ramosExtras: json['ramos_extras']?.toDouble(),
      extrasPorHora: json['extras_por_hora']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (qrId != null) 'qr_id': qrId,
      'numero_mesa': numeroMesa,
      'fecha_entrada': fechaEntrada.toIso8601String(),
      if (horaInicio != null) 'hora_inicio': horaInicio!.toIso8601String(),
      if (horaFinal != null) 'hora_final': horaFinal!.toIso8601String(),
      'rendimiento': rendimiento,
      'ramos_base': ramosBase,
      'bonches': bonches,
    };
  }

  String get fechaFormatted {
    return '${fechaEntrada.day.toString().padLeft(2, '0')}/${fechaEntrada.month.toString().padLeft(2, '0')}/${fechaEntrada.year}';
  }

  String? get horaInicioFormatted {
    if (horaInicio == null) return null;
    return '${horaInicio!.hour.toString().padLeft(2, '0')}:${horaInicio!.minute.toString().padLeft(2, '0')}';
  }

  String? get horaFinalFormatted {
    if (horaFinal == null) return null;
    return '${horaFinal!.hour.toString().padLeft(2, '0')}:${horaFinal!.minute.toString().padLeft(2, '0')}';
  }

  String get rendimientoPorHora {
    if (horasTrabajadas == null || horasTrabajadas == 0) return '0.0';
    return (bonches / horasTrabajadas!).toStringAsFixed(1);
  }

  double get porcentajeEficiencia {
    if (ramosEsperados == null || ramosEsperados == 0) return 0;
    final eficiencia = (bonches / ramosEsperados!) * 100;
    return eficiencia > 200 ? 200 : eficiencia; // Límite del 200%
  }

  String get nivelRendimiento {
    final eficiencia = porcentajeEficiencia;
    if (eficiencia >= 150) return 'Excelente';
    if (eficiencia >= 120) return 'Bueno';
    if (eficiencia >= 100) return 'Aceptable';
    if (eficiencia >= 80) return 'Bajo';
    return 'Muy Bajo';
  }

  Color get colorRendimiento {
    final eficiencia = porcentajeEficiencia;
    if (eficiencia >= 150) return Colors.green;
    if (eficiencia >= 120) return Colors.lightGreen;
    if (eficiencia >= 100) return Colors.yellow;
    if (eficiencia >= 80) return Colors.orange;
    return Colors.red;
  }

  @override
  String toString() {
    return 'Rendimiento{id: $id, mesa: $numeroMesa, fecha: $fechaFormatted, bonches: $bonches}';
  }
}

class EstadisticasRendimiento {
  int totalRendimientos;
  int rendimientosActivos;
  int totalBonches;
  int mesasActivas;
  double promedioBonchesPorDia;
  double promedioHorasTrabajadas;

  EstadisticasRendimiento({
    required this.totalRendimientos,
    required this.rendimientosActivos,
    required this.totalBonches,
    required this.mesasActivas,
    required this.promedioBonchesPorDia,
    required this.promedioHorasTrabajadas,
  });

  factory EstadisticasRendimiento.fromJson(Map<String, dynamic> json) {
    return EstadisticasRendimiento(
      totalRendimientos: json['total_rendimientos'] ?? 0,
      rendimientosActivos: json['rendimientos_activos'] ?? 0,
      totalBonches: json['total_bonches'] ?? 0,
      mesasActivas: json['mesas_activas'] ?? 0,
      promedioBonchesPorDia: json['promedio_bonches_dia']?.toDouble() ?? 0.0,
      promedioHorasTrabajadas:
          json['promedio_horas_trabajadas']?.toDouble() ?? 0.0,
    );
  }
}
