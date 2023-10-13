import 'dart:convert';
import 'package:chopp_house/models/funcionario.dart';
import 'package:chopp_house/utils/database/index.dart';
import 'package:chopp_house/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class RelatorioPage extends StatefulWidget {
  @override
  _RelatorioPageState createState() => _RelatorioPageState();
}

class _RelatorioPageState extends State<RelatorioPage> {
  String? _selectedMonth;
  final _dataInicialController = TextEditingController();
  final _dataFinalController = TextEditingController();
  final _dataInicialFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _dataFinalFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );
  List<Funcionario> funcionarios = [];
  List<Funcionario> diariasPagas = [];

  List<String> mesesDoAno = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];
  bool mesSemDiariaPaga = false;

  @override
  void initState() {
    super.initState();
    _carregarDadosIniciais();
  }

  void _carregarDadosIniciais() async {
    await _filtrarDados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Relatório'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedMonth,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedMonth = newValue;
                        // Chame a função para filtrar os dados com base no mês selecionado aqui.
                      });
                    },
                    items: mesesDoAno.map((String month) {
                      return DropdownMenuItem<String>(
                        value: month,
                        child: Text(month),
                      );
                    }).toList(),
                    hint: Text('Selecione um mês'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _filtrarPorMes();
                  },
                  child: Text('FILTRAR POR MES'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Divider(),
            Container(
              height: 500,
              child: Column(
                children: <Widget>[
                  if (mesSemDiariaPaga)
                    Text(
                      'Mês com nenhuma diária paga',
                      style: TextStyle(fontSize: 16),
                    )
                  else
                    Expanded(
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(),
                        series: _getStackedBarSeries(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: AppDrawer(
        currentPage: 'relatorio',
      ),
    );
  }

  List<BarSeries<Funcionario, String>> _getStackedBarSeries() {
    List<BarSeries<Funcionario, String>> seriesList = [];

    for (Funcionario funcionario in diariasPagas) {
      seriesList.add(
        BarSeries<Funcionario, String>(
          dataSource: [funcionario],
          xValueMapper: (Funcionario funcionario, _) => funcionario.nome,
          yValueMapper: (Funcionario funcionario, _) => funcionario.valorDiaria,
          name: funcionario.nome,
          color: _getBarColor(funcionario),
          animationDelay: 5,
        ),
      );
    }

    return seriesList;
  }

  Color _getBarColor(Funcionario funcionario) {
    if (funcionario.valorDiaria <= 200) {
      return Colors.greenAccent;
    } else if (funcionario.valorDiaria > 500) {
      return Colors.orangeAccent;
    } else {
      return Colors.blueAccent;
    }
  }

  Future<void> _filtrarDados() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/diariasAno'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        final List<Funcionario> diarias = data.map((item) {
          final id = item.containsKey('id') ? item['id'] as int : 0;
          final nome = item['nome'] as String;
          final somaDiaria = double.parse(item['valor_diaria'] as String);

          return Funcionario(
            id: id,
            nome: nome,
            valorDiaria: somaDiaria,
            presente: false,
            inativo: false,
          );
        }).toList();
        setState(() {
          diariasPagas = diarias;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao buscar diárias pagas'),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao buscar diárias pagas: $error'),
        ),
      );
    }
  }

  Future<void> _filtrarPorMes() async {
    final Map<String, dynamic> data = {
      "month": _selectedMonth,
      "year": DateFormat('yyyy').format(DateTime.now())
    };
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/diariasMes'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        final List<Funcionario> diarias = data.map((item) {
          final id = item.containsKey('id') ? item['id'] as int : 0;
          final nome = item['nome'] as String;
          final somaDiaria = double.parse(item['valor_diaria'] as String);

          return Funcionario(
            id: id,
            nome: nome,
            valorDiaria: somaDiaria,
            presente: false,
            inativo: false,
          );
        }).toList();
        setState(() {
          diariasPagas = diarias;
        });
        if (diarias.isEmpty) {
          // Se estiver vazia, mostre o texto
          setState(() {
            mesSemDiariaPaga = true;
          });
        } else {
          // Caso contrário, esconda o texto
          setState(() {
            mesSemDiariaPaga = false;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao buscar diárias pagas'),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao buscar diárias pagas: $error'),
        ),
      );
    }
  }
}
