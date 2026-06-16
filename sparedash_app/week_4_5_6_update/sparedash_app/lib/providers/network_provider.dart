import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/network_service.dart';

class NetworkProvider extends ChangeNotifier {
  final NetworkService _networkService = NetworkService();
  bool _isConnected = true;
  String _connectionType = 'Unknown';
  bool _isLoading = false;

  bool get isConnected => _isConnected;
  String get connectionType => _connectionType;
  bool get isLoading => _isLoading;

  NetworkProvider() {
    _networkService.init();
    _listenToConnectivity();
  }

  void _listenToConnectivity() {
    _networkService.connectivityStream.listen((ConnectivityResult result) {
      _updateConnectionStatus(result);
    });
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final bool wasConnected = _isConnected;
    _isConnected = result != ConnectivityResult.none;
    _connectionType = NetworkService.getConnectionType(result);
    notifyListeners();

    // Notify listeners about connection changes
    if (_isConnected != wasConnected) {
      print('Connection status changed: $_isConnected');
    }
  }

  Future<bool> checkConnectivity() async {
    _isLoading = true;
    notifyListeners();

    final bool isConnected = await _networkService.checkConnectivity();
    _isConnected = isConnected;

    _isLoading = false;
    notifyListeners();
    return isConnected;
  }
}