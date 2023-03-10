import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/common/urls.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  DateTime? _expireDate;
  String? _userId;

  bool get authenticated {
    return token!= null;
  }

  String? get token {
    if (_token != null && _expireDate != null && _expireDate!.isAfter(DateTime.now())) {
      return _token;
    } else {
      return null;
    }
  }

  String? get userId {
    if (token != null) {
      return _userId;
    }
    return null;
  }

  Timer? _authTimer;

  Future<void> authenticate(String email, String password, {bool signUp = true}) async {
    try {
      final response = await http.post(Uri.parse(signUp?signUpUrl:signInUrl), body: json.encode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }));
      final responseBody = json.decode(response.body);
      if (responseBody['error'] != null) {
        throw HttpException((responseBody['error']['errors'] as List<dynamic>).map((e) => e.toString()).toList().join('\n'));
      }
      _token = responseBody['idToken'];
      _expireDate = DateTime.now().add(Duration(seconds: int.parse(responseBody['expiresIn'])));
      _userId = responseBody['localId'];
      autoLogout();
      notifyListeners();
      final pref = await SharedPreferences.getInstance();
      final userData = json.encode(({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expireDate.toString(),
      }));
      pref.setString('userData', userData);
    } catch(err, stacktrace) {
      print(stacktrace);
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      final response = await http.post(Uri.parse(signUpUrl), body: json.encode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }));
      final responseBody = json.decode(response.body);
      if (responseBody['error'] != null) {
        throw HttpException((responseBody['error']['errors'] as List<dynamic>).map((e) => e.toString()).toList().join('\n'));
      }
    } catch(err, stacktrace) {
      print(stacktrace);
      rethrow;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      final response = await http.post(Uri.parse(signInUrl), body: json.encode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }));
      final responseBody = json.decode(response.body);
      if (responseBody['error'] != null) {
        throw HttpException((responseBody['error']['errors'] as List<dynamic>).map((e) => e.toString()).toList().join('\n'));
      }
    } catch(err, stacktrace) {
      print(stacktrace);
      rethrow;
    }
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expireDate = null;
    if (_authTimer !=  null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
  }

  void autoLogout() {
    if (_authTimer !=  null) {
      _authTimer!.cancel();
    }
    if (_expireDate!=null) {
      final timeToExpiry = _expireDate!.difference(DateTime.now()).inSeconds;
      _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
    }
  }

  Future<bool> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData')) {
      final data = json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
      _expireDate = DateTime.tryParse(data['expiryDate']!);
      if (_expireDate?.isAfter(DateTime.now()) == true) {
        _token = data['token'];
        _userId = data['userId'];
        notifyListeners();
        return true;
      }
    }
    return false;
  }
}