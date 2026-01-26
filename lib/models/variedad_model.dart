class VariedadModel {
  final int id;
  final String nombre;

  VariedadModel({required this.id, required this.nombre});

  factory VariedadModel.fromJson(Map<String, dynamic> json) {
    return VariedadModel(
      id: (json['id'] as num).toInt(),
      nombre: (json['nombre'] ?? '').toString(),
    );
  }
}
