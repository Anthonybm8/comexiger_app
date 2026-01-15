// models/mesa_model.dart
class MesaModel {
  int id;
  String nombre;

  MesaModel({required this.id, required this.nombre});

  factory MesaModel.fromJson(Map<String, dynamic> json) {
    return MesaModel(id: json['id'] ?? 0, nombre: json['nombre'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nombre': nombre};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MesaModel && other.id == id && other.nombre == nombre;
  }

  @override
  int get hashCode => id.hashCode ^ nombre.hashCode;

  @override
  String toString() {
    return 'Mesa{id: $id, nombre: $nombre}';
  }
}
