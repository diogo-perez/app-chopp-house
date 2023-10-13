class Usuario {
  final String usuario;
  final String senha;

  Usuario({required this.usuario, required this.senha});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      usuario: json['usuario'],
      senha: json['senha'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario': usuario,
      'senha': senha,
    };
  }
}
