import 'dart:convert';
import 'package:chopp_house/models/diaria.dart';
import 'package:chopp_house/models/funcionario.dart';
import 'package:http/http.dart' as http;
import 'package:chopp_house/utils/database/index.dart';
import 'package:chopp_house/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PagamentoPage extends StatefulWidget {
  @override
  _PagamentoPageState createState() => _PagamentoPageState();
}

class _PagamentoPageState extends State<PagamentoPage> {
  List<Funcionario> funcionarios = [];
  Funcionario? selectedFuncionario;
  List<RegistroDiaria> registrosDiaria = [];

  List<RegistroDiaria> diariasSelecionadas = [];

  int totalDiarias = 0;
  double totalAPagar = 0.0;
  double totalPago = 0.0;

  String formatDate(String inputDate) {
    final dateTime = DateTime.parse(inputDate);
    final formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
    return formattedDate;
  }

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

  void _resetPage() {
    setState(() {
      selectedFuncionario = null;
      registrosDiaria.clear();
      totalDiarias = 0;
      totalAPagar = 0;
      totalPago = 0;
    });
  }

  void _pagarDiarias() async {
    final List<int> diarias_ids =
        diariasSelecionadas.map((diaria) => diaria.id).toList();

    const apiEndpoint = '${ApiConfig.baseUrl}/pagar';

    final data = {
      'funcionario_id': selectedFuncionario!.id,
      'diarias_ids': diarias_ids,
    };

    print(data);

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
        print('Pagamento realizado com sucesso!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Diárias pagas com sucesso!'),
          ),
        );

        // Limpar os estados após o pagamento bem-sucedido
        setState(() {
          diariasSelecionadas.clear();
          selectedFuncionario = null;
          registrosDiaria.clear(); // Limpar a lista de diárias
        });

        // Recarregar os registros de diária
        _fetchRegistrosDiaria(selectedFuncionario);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao realizar pagamento: ${response.statusCode}'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pagamento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown para selecionar um funcionário
            Text(
              'Selecione um Funcionário:',
              style: TextStyle(fontSize: 16),
            ),
            DropdownButtonFormField<Funcionario>(
              value: selectedFuncionario,
              onChanged: (Funcionario? newValue) {
                setState(() {
                  selectedFuncionario = newValue;
                  diariasSelecionadas.clear();
                  _fetchRegistrosDiaria(newValue);
                });
              },
              items: funcionarios.map((Funcionario funcionario) {
                return DropdownMenuItem<Funcionario>(
                  value: funcionario,
                  child: Text(funcionario.nome),
                );
              }).toList(),
            ),
            SizedBox(height: 16), // Espaçamento entre os elementos

            // Lista de registros de diária
            Text(
              'Registros de Diária:',
              style: TextStyle(fontSize: 16),
            ),
            registrosDiaria.isEmpty
                ? Center(
                    child: Text(
                      'Nenhum registro de diária disponível.',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: registrosDiaria.length,
                      itemBuilder: (context, index) {
                        registrosDiaria.sort((a, b) {
                          if (a.pago && !b.pago) {
                            return 1; // Mova as diárias pagas para o final
                          } else if (!a.pago && b.pago) {
                            return -1; // Mova as diárias pendentes para o início
                          } else {
                            // Se ambos têm o mesmo status ordena por data
                            return a.data.compareTo(b.data);
                          }
                        });
                        final registro = registrosDiaria[index];
                        return ListTile(
                          leading: registro.pago
                              ? null
                              : Checkbox(
                                  value: registro.isChecked,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      registro.isChecked = value ?? false;

                                      if (registro.isChecked) {
                                        diariasSelecionadas.add(registro);
                                      } else {
                                        diariasSelecionadas.remove(registro);
                                      }
                                    });
                                  },
                                ),
                          title: Text('Data: ${formatDate(registro.data)}'),
                          subtitle: Text(
                            'Valor da Diária: ${registro.valorDiaria.toStringAsFixed(2).replaceAll('.', ',')}',
                          ),
                          trailing: registro.pago
                              ? Text(
                                  'Pago',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : Text(
                                  'PENDENTE',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ), // Mostrar o texto "Pago" apenas quando pago for true
                        );
                      },
                    ),
                  ),

            SizedBox(height: 16), // Espaçamento abaixo da lista
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total de Diárias: $totalDiarias',
                  style: TextStyle(fontSize: 16),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total a Pagar: R\$ $totalAPagar',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Total Pago: R\$ $totalPago',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.green.shade900,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 16), // Espaçamento abaixo do total

            // Botão "Pagar"
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _pagarDiarias();
                },
                child: Text('PAGAR'),
              ),
            ),
          ],
        ),
      ),
      drawer: AppDrawer(
        currentPage: 'pagamento',
      ),
    );
  }

  void _fetchRegistrosDiaria(Funcionario? funcionario) async {
    if (funcionario == null) {
      return;
    }
    totalDiarias = 0;
    totalAPagar = 0;
    totalPago = 0;

    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/diaria/${funcionario.id}'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      List<RegistroDiaria> registros = [];

      for (var item in data) {
        try {
          final registro = RegistroDiaria.fromJson(item);
          registros.add(registro);
          // Atualize os totais com base no status de pagamento
          if (registro.pago) {
            totalPago += registro.valorDiaria;
          } else {
            totalAPagar += registro.valorDiaria;
          }
          totalDiarias++;
        } catch (e) {
          print('Erro ao converter JSON para RegistroDiaria: $e');
        }
      }

      setState(() {
        registrosDiaria = registros;
      });
    } else {
      print('Erro ao buscar os registros de diária: ${response.statusCode}');
    }
  }
}
