import 'package:chopp_house/models/funcionario.dart';
import 'package:chopp_house/models/token.dart';
import 'package:chopp_house/screens/funcionario.dart';
import 'package:chopp_house/screens/diaria.dart';
import 'package:chopp_house/screens/home.dart';
import 'package:chopp_house/screens/login.dart';
import 'package:chopp_house/screens/pagamento.dart';
import 'package:chopp_house/screens/relatorio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => TokenProvider(), // Crie uma instância do TokenProvider
      child: MyApp(),
    ),
  );
}

//como acessar o token no restante do projeto:
//final tokenProvider = Provider.of<TokenProvider>(context);
//final token = tokenProvider.token;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chopp House',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/cadastro': (context) => FuncionarioPage(),
        '/lancamento_diaria': (context) => LancamentoDiariaPage(),
        '/pagamento': (context) => PagamentoPage(),
        '/relatorio': (context) => RelatorioPage(),
      },
    );
  }
}
