import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  // Stream for connectivity changes
  final Connectivity _connectivity = Connectivity();
  late Stream<ConnectivityResult> connectivityStream;

  // Current connectivity status
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  // Initialize the service
  void init() {
    connectivityStream = _connectivity.onConnectivityChanged;
    _checkInitialConnectivity();
  }

  // Check initial connectivity
  Future<void> _checkInitialConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _isConnected = result != ConnectivityResult.none;
  }

  // Check current connectivity
  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _isConnected = result != ConnectivityResult.none;
    return _isConnected;
  }

  // Get connection type
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

  // Show no internet dialog
  static void showNoInternetDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.red),
            SizedBox(width: 8),
            Text('No Internet Connection'),
          ],
        ),
        content: const Text(
          'Please check your internet connection and try again.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Retry connection
              NetworkService().checkConnectivity();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Show connection restored snackbar
  static void showConnectionRestored(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.wifi, color: Colors.white),
            SizedBox(width: 8),
            Text('Internet connection restored!'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Show connection lost snackbar
  static void showConnectionLost(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.white),
            SizedBox(width: 8),
            Text('Internet connection lost!'),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
}