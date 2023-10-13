class RegistroDiaria {
  int id;
  String data;
  double valorDiaria;
  bool pago;
  bool isChecked;

  RegistroDiaria({
    required this.id,
    required this.data,
    required this.pago,
    required this.isChecked,
    required dynamic valorDiaria,
  }) : valorDiaria = double.parse(valorDiaria.toString());

  factory RegistroDiaria.fromJson(Map<String, dynamic> json) {
    final valorDiaria = json['valor_diaria'];
    return RegistroDiaria(
      isChecked: false,
      pago: json['pago'],
      id: json['id'],
      data: json['data_diaria'],
      valorDiaria: valorDiaria != null
          ? double.tryParse(valorDiaria.toString()) ?? 0.0
          : 0.0,
    );
  }
}
