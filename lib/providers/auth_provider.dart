import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();
  User? user;
  bool isLoading = true;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    user = _service.currentUser;
    isLoading = false;
    FirebaseAuth.instance.userChanges().listen((u) {
      user = u;
      notifyListeners();
    });
    notifyListeners();
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _service.signIn(email, password);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signUp(String email, String password) async {
    try {
      await _service.signUp(email, password);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
  }
}
