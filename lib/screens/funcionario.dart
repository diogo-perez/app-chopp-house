import 'dart:convert';
import 'package:chopp_house/models/funcionario.dart';
import 'package:chopp_house/utils/database/index.dart';
import 'package:chopp_house/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FuncionarioPage extends StatefulWidget {
  @override
  _FuncionarioPageState createState() => _FuncionarioPageState();
}

class _FuncionarioPageState extends State<FuncionarioPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _valorDiariaController = TextEditingController();
  List<Funcionario> funcionarios = [];
  List<Funcionario> funcionariosOriginal = [];

  @override
  void initState() {
    super.initState();
    _carregarFuncionarios();
  }

  void _carregarFuncionarios() async {
    final response =
        await http.get(Uri.parse('${ApiConfig.baseUrl}/funcionarios'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      List<Funcionario> funcionarios = [];

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
        this.funcionariosOriginal = funcionarios; // Atualize a lista original
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Erro ao buscar os funcionários: ${response.statusCode}'),
        ),
      );
    }
  }

  void _cadastrarFuncionario() async {
    final String nome = _nomeController.text;
    final double valorDiaria =
        double.tryParse(_valorDiariaController.text) ?? 0.0;

    if (nome.isNotEmpty) {
      final Map<String, dynamic> data = {
        "nome": nome,
        "valorDiaria": valorDiaria,
      };

      var response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/funcionario'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Funcionário cadastrado com sucesso!'),
          ),
        );

        _nomeController.clear();
        _valorDiariaController.clear();
        _carregarFuncionarios();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cadastrar funcionário.'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preencha todos os campos corretamente.'),
        ),
      );
    }
  }

  void _showEditDialog(Funcionario funcionario) {
    TextEditingController nomeController =
        TextEditingController(text: funcionario.nome);
    TextEditingController valorDiariaController =
        TextEditingController(text: funcionario.valorDiaria.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Funcionário'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: valorDiariaController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Valor da Diária (R\$)'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Salvar'),
              onPressed: () async {
                final String novoNome = nomeController.text;
                final double novoValorDiaria =
                    double.tryParse(valorDiariaController.text) ?? 0.0;

                try {
                  final response = await http.put(
                    Uri.parse(
                        '${ApiConfig.baseUrl}/funcionario/${funcionario.id}'),
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: jsonEncode({
                      "nome": novoNome,
                      "valorDiaria": novoValorDiaria,
                    }),
                  );

                  if (response.statusCode == 200) {
                    _carregarFuncionarios();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao atualizar funcionário.'),
                      ),
                    );
                  }
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao atualizar funcionário: $error'),
                    ),
                  );
                }

                Navigator.of(context).pop(); // Feche o Dialog
              },
            ),
            TextButton(
              child: Text('CANCELAR'),
              onPressed: () {
                Navigator.of(context).pop(); // Feche o Dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _filtrarFuncionariosPorNome(String nome) {
    final List<Funcionario> funcionariosFiltrados = funcionariosOriginal
        .where((funcionario) =>
            funcionario.nome.toLowerCase().contains(nome.toLowerCase()))
        .toList();

    setState(() {
      funcionarios = funcionariosFiltrados;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Funcionário'),
      ),
      body: Container(
        color: Colors.grey[100],
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      Wrap(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: _nomeController,
                              decoration:
                                  InputDecoration(labelText: 'Nome Completo'),
                              onChanged: (value) {
                                _filtrarFuncionariosPorNome(value);
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _valorDiariaController,
                              decoration: InputDecoration(
                                  labelText: 'Valor da Diária (R\$)'),
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                            ),
                          ),
                          SizedBox(width: 16),
                          Center(
                            child: ElevatedButton(
                              onPressed: _cadastrarFuncionario,
                              child: Text('CADASTRAR'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: funcionarios.length,
                  itemBuilder: (context, index) {
                    final funcionario = funcionarios[index];
                    final isAtivo = !funcionario.inativo;

                    return Card(
                      color: isAtivo ? Colors.green.shade200 : Colors.grey,
                      child: ListTile(
                        title: Text(funcionario.nome),
                        subtitle: Text(
                            'Valor da Diária: R\$ ${funcionario.valorDiaria.toStringAsFixed(2).replaceAll('.', ',')}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _showEditDialog(funcionario);
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                funcionario.inativo
                                    ? Icons.verified
                                    : Icons.delete,
                              ),
                              onPressed: () async {
                                try {
                                  final response = await http.put(
                                    Uri.parse(
                                        '${ApiConfig.baseUrl}/funcionario/inativar/${funcionario.id}'),
                                    headers: <String, String>{
                                      'Content-Type':
                                          'application/json; charset=UTF-8',
                                    },
                                  );

                                  if (response.statusCode == 200) {
                                    _carregarFuncionarios();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Erro ao inativar funcionário.'),
                                      ),
                                    );
                                  }
                                } catch (error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Erro ao inativar funcionário: $error'),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: AppDrawer(
        currentPage: 'cadastro',
      ),
    );
  }
}
