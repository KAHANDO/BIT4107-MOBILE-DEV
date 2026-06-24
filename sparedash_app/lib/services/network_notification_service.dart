import 'package:flutter/material.dart';
import 'network_service.dart';

class NetworkNotificationService {
  static final NetworkNotificationService _instance =
  NetworkNotificationService._internal();
  factory NetworkNotificationService() => _instance;
  NetworkNotificationService._internal();

  bool _wasConnected = true;
  bool _isShowingDialog = false;
  OverlayEntry? _overlayEntry;

  void init(BuildContext context) {
    final networkService = NetworkService();

    // Listen to connectivity changes
    networkService.connectivityStream.listen((result) {
      final bool isConnected = result != ConnectivityResult.none;
      _handleConnectivityChange(context, isConnected);
    });
  }

  void _handleConnectivityChange(BuildContext context, bool isConnected) {
    if (isConnected != _wasConnected) {
      if (!isConnected) {
        // Connection Lost
        _showNoInternetBanner(context);
        _showNoInternetDialog(context);
      } else {
        // Connection Restored
        _hideNoInternetBanner();
        _showConnectionRestoredSnackbar(context);
      }
      _wasConnected = isConnected;
    }
  }

  void _showNoInternetBanner(BuildContext context) {
    // Remove existing banner if any
    _hideNoInternetBanner();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.red,
          elevation: 4,
          child: SafeArea(
            bottom: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'No Internet Connection',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Please check your network settings',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final networkService = NetworkService();
                      bool connected = await networkService.checkConnectivity();
                      if (connected) {
                        _hideNoInternetBanner();
                        _showConnectionRestoredSnackbar(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Still no internet connection'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Insert the overlay
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideNoInternetBanner() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  void _showNoInternetDialog(BuildContext context) {
    if (_isShowingDialog) return;
    _isShowingDialog = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text(
              'No Internet Connection',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your device is not connected to the internet.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              'Some features may not work properly. Please check your network settings.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 12),
            Text(
              '💡 Tip: Try turning Wi-Fi on/off or connecting to a different network.',
              style: TextStyle(fontSize: 13, color: Colors.blue),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _isShowingDialog = false;
              Navigator.pop(context);
            },
            child: const Text('Dismiss'),
          ),
          ElevatedButton(
            onPressed: () async {
              final networkService = NetworkService();
              bool connected = await networkService.checkConnectivity();
              if (connected) {
                _isShowingDialog = false;
                Navigator.pop(context);
                _hideNoInternetBanner();
                _showConnectionRestoredSnackbar(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Still no internet connection. Please try again.'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
            ),
            child: const Text('Check Again'),
          ),
        ],
      ),
    );
  }

  void _showConnectionRestoredSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.wifi, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Internet connection restored!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Icon(Icons.check_circle, color: Colors.white),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  // Show a toast/snackbar for offline mode
  static void showOfflineSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.white),
            SizedBox(width: 12),
            Text('You are offline. Some features may be limited.'),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  // Show online snackbar
  static void showOnlineSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.wifi, color: Colors.white),
            SizedBox(width: 12),
            Text('You are back online!'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }
}