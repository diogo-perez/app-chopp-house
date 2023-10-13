class Funcionario {
  int id;
  String nome;
  double valorDiaria;
  bool presente;
  bool inativo;

  Funcionario({
    required this.id,
    required this.nome,
    required this.valorDiaria,
    this.presente = false,
    required this.inativo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'valorDiaria': valorDiaria,
      'presente': presente ? 1 : 0,
    };
  }

  factory Funcionario.fromJson(Map<String, dynamic> json) {
    try {
      final id = json['id'] as int;
      final nome = json['nome'] as String;
      final valorDiaria = json['valor_diaria'];
      final inativo = json['inativo'];

      if (nome == null || valorDiaria == null) {
        throw FormatException("Dados inválidos no JSON");
      }

      // Remova qualquer vírgula ou ponto do valor e depois converta para double
      final valorDiariaDouble =
          double.parse(valorDiaria.toString().replaceAll(',', '.'));

      return Funcionario(
        nome: nome,
        valorDiaria: valorDiariaDouble,
        id: id,
        inativo: inativo,
      );
    } catch (e) {
      print('Erro ao converter JSON para Funcionario: $e');
      throw e;
    }
  }
}
