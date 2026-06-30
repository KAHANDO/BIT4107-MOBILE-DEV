import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String name;
  final String price;
  final double priceValue;
  int quantity;
  final bool inStock;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.priceValue,
    required this.quantity,
    required this.inStock,
  });
}

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  double get subtotal {
    return _items.fold(0, (sum, item) => sum + (item.priceValue * item.quantity));
  }

  double get deliveryFee => 500;

  double get total => subtotal + deliveryFee;

  void addToCart({
    required String id,
    required String name,
    required String price,
    required double priceValue,
    required bool inStock,
  }) {
    if (!inStock) return;

    final existingIndex = _items.indexWhere((item) => item.id == id);

    if (existingIndex != -1) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(
        id: id,
        name: name,
        price: price,
        priceValue: priceValue,
        quantity: 1,
        inStock: inStock,
      ));
    }
    notifyListeners();
  }

  void removeFromCart(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void updateQuantity(String id, int newQuantity) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  int getItemQuantity(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      return _items[index].quantity;
    }
    return 0;
  }
}