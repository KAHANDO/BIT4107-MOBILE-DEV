import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class DatabaseProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  Map<String, dynamic>? _currentUser;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _cartItems = [];
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _shippingRequests = [];
  bool _isLoading = false;
  bool _isLoggingIn = false;

  // Getters
  Map<String, dynamic>? get currentUser => _currentUser;
  List<Map<String, dynamic>> get products => _products;
  List<Map<String, dynamic>> get cartItems => _cartItems;
  List<Map<String, dynamic>> get orders => _orders;
  List<Map<String, dynamic>> get shippingRequests => _shippingRequests;
  bool get isLoading => _isLoading;
  bool get isLoggingIn => _isLoggingIn;
  int get cartCount => _cartItems.length;

  double get cartSubtotal {
    double total = 0;
    for (var item in _cartItems) {
      total += (item['price'] ?? 0) * (item['quantity'] ?? 1);
    }
    return total;
  }

  double get cartTotal => cartSubtotal + 500;

  // ============ LOGIN METHODS ============

  Future<bool> login(String email, String password) async {
    _isLoggingIn = true;
    notifyListeners();

    try {
      bool isValid = await _db.validateUser(email, password);

      if (isValid) {
        _currentUser = await _db.getUserByEmail(email);
        _isLoggingIn = false;

        // Load user data after login
        await loadProducts();
        await loadCart();
        await loadOrders();
        await loadShippingRequests();

        notifyListeners();
        return true;
      } else {
        _isLoggingIn = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      _isLoggingIn = false;
      notifyListeners();
      return false;
    }
  }

  // ============ REGISTRATION METHODS ============

  Future<bool> checkUserExists(String email) async {
    final user = await _db.getUserByEmail(email);
    return user != null;
  }

  Future<bool> registerUser(Map<String, dynamic> userData) async {
    _isLoading = true;
    notifyListeners();

    try {
      bool exists = await checkUserExists(userData['email']);
      if (exists) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      int userId = await _db.insertUser(userData);
      _isLoading = false;
      notifyListeners();
      return userId > 0;
    } catch (e) {
      print('Registration error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============ PRODUCT METHODS ============

  Future<void> loadProducts() async {
    _products = await _db.getAllProducts();
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    if (query.isEmpty) return _products;
    return await _db.searchProducts(query);
  }

  // ============ CART METHODS ============

  Future<void> loadCart() async {
    if (_currentUser != null) {
      _cartItems = await _db.getCartItems(_currentUser!['id']);
      notifyListeners();
    }
  }

  Future<void> addToCart(int productId, int quantity) async {
    if (_currentUser != null) {
      await _db.addToCart(_currentUser!['id'], productId, quantity);
      await loadCart();
    }
  }

  Future<void> updateCartItem(int cartId, int quantity) async {
    await _db.updateCartQuantity(cartId, quantity);
    await loadCart();
  }

  Future<void> removeFromCart(int cartId) async {
    await _db.removeFromCart(cartId);
    await loadCart();
  }

  Future<void> clearCart() async {
    if (_currentUser != null) {
      await _db.clearCart(_currentUser!['id']);
      await loadCart();
    }
  }

  // ============ ORDER METHODS ============

  Future<void> loadOrders() async {
    if (_currentUser != null) {
      _orders = await _db.getUserOrders(_currentUser!['id']);
      notifyListeners();
    }
  }

  Future<String> checkout(String paymentMethod, String address) async {
    if (_currentUser != null) {
      String orderNumber = 'ORD${DateTime.now().millisecondsSinceEpoch}';
      await clearCart();
      await loadOrders();
      await updateUserStats();

      int pointsEarned = (cartTotal / 100).floor();
      await addLoyaltyPoints(pointsEarned);

      return orderNumber;
    }
    return '';
  }

  // ============ USER PROFILE METHODS ============

  Future<void> updateUserStats() async {
    if (_currentUser != null) {
      var stats = await _db.getUserStats(_currentUser!['id']);
      if (_currentUser != null) {
        _currentUser!.addAll(stats);
      }
      notifyListeners();
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> userData) async {
    if (_currentUser != null) {
      await _db.updateUser(_currentUser!['id'], userData);
      _currentUser = await _db.getUserByEmail(_currentUser!['email']);
      notifyListeners();
    }
  }

  Future<void> addLoyaltyPoints(int points) async {
    if (_currentUser != null) {
      await _db.addLoyaltyPoints(_currentUser!['id'], points);
      await updateUserStats();
    }
  }

  // ============ SHIPPING REQUEST METHODS ============

  Future<int> createShippingRequest(Map<String, dynamic> request) async {
    if (_currentUser != null) {
      request['user_id'] = _currentUser!['id'];
      int result = await _db.insertShippingRequest(request);
      await loadShippingRequests();
      return result;
    }
    return 0;
  }

  Future<void> loadShippingRequests() async {
    if (_currentUser != null) {
      _shippingRequests = await _db.getUserShippingRequests(_currentUser!['id']);
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> getShippingRequests() async {
    if (_currentUser != null) {
      return await _db.getUserShippingRequests(_currentUser!['id']);
    }
    return [];
  }

  // ============ LOYALTY POINTS ============

  Future<int> getUserLoyaltyPoints() async {
    if (_currentUser != null) {
      return _currentUser!['loyalty_points'] ?? 0;
    }
    return 0;
  }

  Future<String> getUserMemberTier() async {
    if (_currentUser != null) {
      return _currentUser!['member_tier'] ?? 'Bronze';
    }
    return 'Bronze';
  }

  // ============ STATISTICS ============

  Future<Map<String, dynamic>> getUserStatistics() async {
    if (_currentUser != null) {
      return await _db.getUserStats(_currentUser!['id']);
    }
    return {
      'orderCount': 0,
      'totalSpent': 0,
      'loyaltyPoints': 0,
      'memberTier': 'Bronze',
    };
  }

  // ============ LOGOUT ============

  void logout() {
    _currentUser = null;
    _cartItems = [];
    _orders = [];
    _products = [];
    _shippingRequests = [];
    notifyListeners();
  }

  // ============ UTILITY ============

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}