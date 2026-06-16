import 'package:flutter/material.dart';

// A simple wrapper widget that doesn't add any UI elements
// This prevents any overflow issues
class NetworkAwareWidget extends StatelessWidget {
  final Widget child;

  const NetworkAwareWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}