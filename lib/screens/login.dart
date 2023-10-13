import 'dart:convert';
import 'package:chopp_house/models/token.dart';
import 'package:http/http.dart' as http;
import 'package:chopp_house/utils/database/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _login() async {
    setState(() {
      _isLoading = true;
    });
    final String usuario = _usernameController.text;
    final String senha = _passwordController.text;

    if (usuario.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, preencha todos os campos.'),
        ),
      );
      return;
    }
    final Map<String, dynamic> data = {
      "usuario": usuario,
      "senha": senha,
    };

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final token = json.decode(response.body)['token'];
        final username = json.decode(response.body)['usuario'];
        final tokenProvider =
            Provider.of<TokenProvider>(context, listen: false);
        tokenProvider.setToken(token);
        tokenProvider.setUsername(username);
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // Exiba uma mensagem de erro de login
        final errorMessage = json.decode(response.body)['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro de login: $errorMessage'),
          ),
        );
      }
    } catch (e) {
      // Trate o erro aqui
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao fazer login: $e'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100], // Cor de fundo verde suave
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            constraints: BoxConstraints(
                maxWidth: 400, maxHeight: 400), // Largura máxima do card
            child: Card(
              elevation: 5, // Adicione elevação para dar um efeito de card
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Image.asset(
                      'assets/logo.webp',
                      width: 80,
                      height: 80,
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _usernameController, // Adicione o controlador
                      decoration: InputDecoration(labelText: 'USUARIO'),
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'SENHA',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (!_isLoading) {
                          _login();
                        }
                      },
                      child: _isLoading
                          ? CircularProgressIndicator(
                              // Exibe o indicador de progresso se _isLoading for verdadeiro
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Text(
                              'ENTRAR',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
