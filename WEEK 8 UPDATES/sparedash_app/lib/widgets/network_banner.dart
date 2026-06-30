import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connectivity_provider.dart';

class NetworkBanner extends StatelessWidget {
  final Widget child;
  const NetworkBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivity, _) {
        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: connectivity.isConnected ? 0 : 28,
              child: Container(
                color: Colors.red,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text('No internet connection',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            _OnlineRestoredBanner(
              isConnected: connectivity.isConnected,
              connectionLabel: connectivity.connectionLabel,
            ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}

class _OnlineRestoredBanner extends StatefulWidget {
  final bool isConnected;
  final String connectionLabel;
  const _OnlineRestoredBanner({required this.isConnected, required this.connectionLabel});

  @override
  State<_OnlineRestoredBanner> createState() => _OnlineRestoredBannerState();
}

class _OnlineRestoredBannerState extends State<_OnlineRestoredBanner> {
  bool _showRestoredBanner = false;
  bool _previouslyConnected = true;

  @override
  void didUpdateWidget(_OnlineRestoredBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_previouslyConnected && widget.isConnected) {
      setState(() => _showRestoredBanner = true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showRestoredBanner = false);
      });
    }
    _previouslyConnected = widget.isConnected;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showRestoredBanner ? 28 : 0,
      child: Container(
        color: Colors.green,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi, color: Colors.white, size: 14),
            const SizedBox(width: 6),
            Text('Connected via ${widget.connectionLabel}',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
