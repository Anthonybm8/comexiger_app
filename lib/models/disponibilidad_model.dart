import 'package:flutter/material.dart'; // <-- AÑADE ESTA LÍNEA

// models/disponibilidad_model.dart
class DisponibilidadModel {
  int? id;
  int numeroMesa;
  String variedad;
  String medida;
  int stock;
  DateTime fechaEntrada;
  DateTime? fechaSalida;

  DisponibilidadModel({
    this.id,
    required this.numeroMesa,
    required this.variedad,
    required this.medida,
    required this.stock,
    required this.fechaEntrada,
    this.fechaSalida,
  });

  factory DisponibilidadModel.fromJson(Map<String, dynamic> json) {
    return DisponibilidadModel(
      id: json['id'],
      numeroMesa: json['numero_mesa'] ?? 0,
      variedad: json['variedad'] ?? '',
      medida: json['medida'] ?? '',
      stock: json['stock'] ?? 0,
      fechaEntrada: DateTime.parse(json['fecha_entrada']),
      fechaSalida: json['fecha_salida'] != null
          ? DateTime.parse(json['fecha_salida'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'numero_mesa': numeroMesa,
      'variedad': variedad,
      'medida': medida,
      'stock': stock,
      'fecha_entrada': fechaEntrada.toIso8601String(),
      if (fechaSalida != null) 'fecha_salida': fechaSalida!.toIso8601String(),
    };
  }

  String get fechaEntradaFormatted {
    return '${fechaEntrada.day.toString().padLeft(2, '0')}/${fechaEntrada.month.toString().padLeft(2, '0')}/${fechaEntrada.year}';
  }

  String get horaEntradaFormatted {
    return '${fechaEntrada.hour.toString().padLeft(2, '0')}:${fechaEntrada.minute.toString().padLeft(2, '0')}';
  }

  String? get fechaSalidaFormatted {
    if (fechaSalida == null) return null;
    return '${fechaSalida!.day.toString().padLeft(2, '0')}/${fechaSalida!.month.toString().padLeft(2, '0')}/${fechaSalida!.year}';
  }

  String? get horaSalidaFormatted {
    if (fechaSalida == null) return null;
    return '${fechaSalida!.hour.toString().padLeft(2, '0')}:${fechaSalida!.minute.toString().padLeft(2, '0')}';
  }

  bool get estaActiva => fechaSalida == null;

  // Color según el nivel de stock
  Color get colorStock {
    if (stock == 0) return Colors.red;
    if (stock <= 10) return Colors.orange;
    if (stock <= 30) return Colors.yellow;
    return Colors.green;
  }

  String get nivelStock {
    if (stock == 0) return 'Agotado';
    if (stock <= 10) return 'Bajo';
    if (stock <= 30) return 'Medio';
    return 'Alto';
  }

  @override
  String toString() {
    return 'Disponibilidad{id: $id, mesa: $numeroMesa, variedad: $variedad, stock: $stock}';
  }
}

class EstadisticasDisponibilidad {
  int totalRegistros;
  int registrosActivos;
  int stockTotal;
  int mesasActivas;

  EstadisticasDisponibilidad({
    required this.totalRegistros,
    required this.registrosActivos,
    required this.stockTotal,
    required this.mesasActivas,
  });

  factory EstadisticasDisponibilidad.fromJson(Map<String, dynamic> json) {
    return EstadisticasDisponibilidad(
      totalRegistros: json['total_registros'] ?? 0,
      registrosActivos: json['registros_activos'] ?? 0,
      stockTotal: json['stock_total'] ?? 0,
      mesasActivas: json['mesas_activas'] ?? 0,
    );
  }
}
