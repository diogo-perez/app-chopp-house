import 'dart:convert';
import 'package:chopp_house/models/funcionario.dart';
import 'package:chopp_house/utils/database/index.dart';
import 'package:chopp_house/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class LancamentoDiariaPage extends StatefulWidget {
  @override
  _LancamentoDiariaPageState createState() => _LancamentoDiariaPageState();
}

class _LancamentoDiariaPageState extends State<LancamentoDiariaPage> {
  String selectedDate = DateFormat('dd/MM/yyyy')
      .format(DateTime.now()); // Data inicial como a data atual
  List<Funcionario> funcionarios = []; // Lista de funcionários fictícios
  List<Funcionario> selectedFuncionarios = [];
  bool selectAll = false;

  @override
  void initState() {
    super.initState();
    _fetchFuncionarios();
  }

  void _fetchFuncionarios() async {
    final response =
        await http.get(Uri.parse('${ApiConfig.baseUrl}/funcionarios'));

    if (response.statusCode == 200) {
      // Decodifique a resposta JSON usando json.decode
      final List<dynamic> data = json.decode(response.body);

      // Crie uma lista de funcionários a partir dos dados recebidos
      List<Funcionario> funcionarios = [];

      // Percorra os dados e crie instâncias de Funcionario
      for (var item in data) {
        try {
          final funcionario = Funcionario.fromJson(item);
          funcionarios.add(funcionario);
        } catch (e) {
          print('Erro ao converter JSON para Funcionario: $e');
        }
      }

      setState(() {
        this.funcionarios = funcionarios;
      });
    } else {
      // Se a solicitação não for bem-sucedida, trate o erro de acordo com suas necessidades.
      print('Erro ao buscar os funcionários: ${response.statusCode}');
    }
  }

  void _saveData() async {
    if (selectedDate.isNotEmpty && selectedFuncionarios.isNotEmpty) {
      final DateFormat formatter = DateFormat('dd/MM/yyyy');
      final DateTime date = formatter.parse(selectedDate);

      final List<int> funcionarioIds =
          selectedFuncionarios.map((funcionario) => funcionario.id).toList();

      final dataDiaria = date.toLocal();

      final List<Set<int>> funcionariosData =
          funcionarioIds.map((funcionarioId) => {funcionarioId}).toList();

      final apiEndpoint = '${ApiConfig.baseUrl}/diaria';

      final data = {
        'data_diaria': formatter.format(dataDiaria),
        'funcionarios': funcionarioIds,
      };

      try {
        final response = await http.post(
          Uri.parse(apiEndpoint),
          body: jsonEncode(data),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );

        print(response.statusCode);

        if (response.statusCode == 201) {
          print('Diárias salvas com sucesso!');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Diárias salvas com sucesso!'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar diárias: ${response.statusCode}'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer a solicitação HTTP: $e'),
          ),
        );
      }

      // Limpe a seleção após salvar as diárias
      setState(() {
        selectedDate = '';
        selectedFuncionarios.clear();
        selectAll = false;
      });
    } else {
      // Exiba uma mensagem de erro se algum campo estiver vazio.
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erro'),
            content: Text('Por favor, preencha todos os campos.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      selectAll = value ?? false;
      if (selectAll) {
        selectedFuncionarios = List.from(funcionarios);
      } else {
        selectedFuncionarios.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lançamento de Diária'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input para selecionar a data
            Text(
              'Selecione a Data:',
              style: TextStyle(fontSize: 16),
            ),
            TextField(
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
                  });
                }
              },
              readOnly: true,
              controller: TextEditingController(text: selectedDate),
              decoration: InputDecoration(
                hintText: 'Selecione a data',
              ),
            ),
            SizedBox(height: 16), // Espaçamento entre os elementos

            // Lista de funcionários com caixas de seleção
            Row(
              children: [
                Checkbox(
                  value: selectAll,
                  onChanged: _toggleSelectAll,
                ),
                Text('Selecionar Todos os Funcionários'),
              ],
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: funcionarios.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text(funcionarios[index].nome),
                    value: selectedFuncionarios.contains(funcionarios[index]),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value != null) {
                          if (value) {
                            selectedFuncionarios.add(funcionarios[index]);
                          } else {
                            selectedFuncionarios.remove(funcionarios[index]);
                          }
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 600) {
            // Tela grande (PC)
            return ElevatedButton(
              onPressed: () {
                _saveData();
              },
              child: Text('Salvar'),
            );
          } else {
            // Tela pequena (celular)
            return FloatingActionButton(
              onPressed: () {
                _saveData();
              },
              child: Icon(Icons.save),
            );
          }
        },
      ),
      drawer: AppDrawer(
        currentPage: 'lancamento_diaria',
      ),
    );
  }
}
