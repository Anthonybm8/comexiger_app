class UsuarioModel {
  int? id;
  String nombres;
  String apellidos;
  String mesa;
  String cargo;
  String username;
  String password;

  UsuarioModel({
    this.id,
    required this.nombres,
    required this.apellidos,
    required this.mesa,
    required this.cargo,
    required this.username,
    required this.password,
  });

  // Constructor desde JSON de Django
  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] ?? json['data']?['id'],
      nombres: json['nombres'] ?? json['data']?['nombres'] ?? '',
      apellidos: json['apellidos'] ?? json['data']?['apellidos'] ?? '',
      mesa: json['mesa'] ?? json['data']?['mesa'] ?? '',
      cargo: json['cargo'] ?? json['data']?['cargo'] ?? '',
      username: json['username'] ?? json['data']?['username'] ?? '',
      password: json['password'] ?? '',
    );
  }

  // Para registro (enviar a /api/registrar/)
  Map<String, dynamic> toJsonForRegister() {
    return {
      'nombres': nombres.trim(),
      'apellidos': apellidos.trim(),
      'mesa': mesa.trim(),
      'cargo': cargo.trim(),
      'username': username.trim(),
      'password': password.trim(),
    };
  }

  // Para login (enviar a /api/login/)
  Map<String, dynamic> toJsonForLogin() {
    return {'username': username.trim(), 'password': password.trim()};
  }

  // Para uso interno
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombres': nombres,
      'apellidos': apellidos,
      'mesa': mesa,
      'cargo': cargo,
      'username': username,
    };
  }

  // Para debug
  @override
  String toString() {
    return 'Usuario{id: $id, nombres: $nombres, username: $username}';
  }
}
