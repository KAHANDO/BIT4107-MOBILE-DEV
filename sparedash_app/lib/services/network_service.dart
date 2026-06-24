import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  late Stream<ConnectivityResult> connectivityStream;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  // List of listeners for connection changes
  final List<Function(bool)> _listeners = [];

  void init() {
    connectivityStream = _connectivity.onConnectivityChanged;
    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _isConnected = result != ConnectivityResult.none;
  }

  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _isConnected = result != ConnectivityResult.none;
    return _isConnected;
  }

  void addListener(Function(bool) listener) {
    _listeners.add(listener);
  }

  void removeListener(Function(bool) listener) {
    _listeners.remove(listener);
  }

  void notifyListeners(bool isConnected) {
    for (var listener in _listeners) {
      listener(isConnected);
    }
  }

  static String getConnectionType(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return 'Wi-Fi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.none:
        return 'No Connection';
      default:
        return 'Unknown';
    }
  }
}