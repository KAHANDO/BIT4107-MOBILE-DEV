import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class DatabaseProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  String? _currentEmail;
  String? _currentName;

  String? get currentEmail => _currentEmail;
  String? get currentName => _currentName;
  bool get isLoggedIn => _currentEmail != null;

  Future<bool> login(String email, String password) async {
    final user = await _db.loginUser(email.toLowerCase(), password);
    if (user != null) {
      _currentEmail = user['email'] as String;
      _currentName = user['name'] as String;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    final success = await _db.registerUser(name, email.toLowerCase(), password);
    if (success) {
      _currentEmail = email.toLowerCase();
      _currentName = name;
      notifyListeners();
    }
    return success;
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    if (_currentEmail == null) return [];
    return await _db.getOrdersByUser(_currentEmail!);
  }

  Future<bool> placeOrder({
    required String partName,
    required int quantity,
    required double totalPrice,
  }) async {
    if (_currentEmail == null) return false;
    final id = await _db.placeOrder(
      userEmail: _currentEmail!,
      partName: partName,
      quantity: quantity,
      totalPrice: totalPrice,
    );
    notifyListeners();
    return id > 0;
  }

  void logout() {
    _currentEmail = null;
    _currentName = null;
    notifyListeners();
  }
}