import 'package:flutter/material.dart';

class TokenProvider with ChangeNotifier {
  String? _token;
  String? _username;

  String? get token => _token;
  String? get username => _username;

  void setToken(String? token) {
    _token = token;
    notifyListeners();
  }

  void setUsername(String? username) {
    _username = username;
    notifyListeners();
  }
}
