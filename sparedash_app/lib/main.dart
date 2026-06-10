import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const SpareDashApp());
}

class SpareDashApp extends StatelessWidget {
  const SpareDashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: const MaterialApp(
        title: 'SpareDash',
        debugShowCheckedModeBanner: false,
        home: LoginScreen(),
      ),
    );
  }
}