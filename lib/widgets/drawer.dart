import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chopp_house/models/token.dart';

class AppDrawer extends StatelessWidget {
  final String currentPage;

  AppDrawer({required this.currentPage});

  @override
  Widget build(BuildContext context) {
    final tokenProvider = Provider.of<TokenProvider>(context, listen: false);

    _showLogoutConfirmationDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Sair'),
            content: Text('Tem certeza de que deseja sair?'),
            actions: <Widget>[
              TextButton(
                child: Text('Cancelar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Sair'),
                onPressed: () {
                  tokenProvider.setToken(null);
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
            ],
          );
        },
      );
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green, // Cor de fundo do cabeçalho
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Bem Vindo(a): ${tokenProvider.username}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Cadastro de Funcionário'),
            onTap: () {
              Navigator.of(context).pushNamed('/cadastro');
            },
            tileColor: currentPage == 'cadastro' ? Colors.grey[300] : null,
          ),
          ListTile(
            leading: Icon(Icons.event),
            title: Text('Lançamento de Diária'),
            onTap: () {
              Navigator.of(context).pushNamed('/lancamento_diaria');
            },
            tileColor:
                currentPage == 'lancamento_diaria' ? Colors.grey[300] : null,
          ),
          ListTile(
            leading: Icon(Icons.monetization_on),
            title: Text('Pagamento'),
            onTap: () {
              Navigator.of(context).pushNamed('/pagamento');
            },
            tileColor: currentPage == 'pagamento' ? Colors.grey[300] : null,
          ),
          ListTile(
            leading: Icon(Icons.leaderboard),
            title: Text('Relatorio'),
            onTap: () {
              Navigator.of(context).pushNamed('/relatorio');
            },
            tileColor: currentPage == 'relatorio' ? Colors.grey[300] : null,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Sair'),
            onTap: () {
              _showLogoutConfirmationDialog(context);
            },
          ),
        ],
      ),
    );
  }
}
