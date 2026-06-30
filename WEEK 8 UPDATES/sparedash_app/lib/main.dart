import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/database_provider.dart';
import 'providers/connectivity_provider.dart';
import 'screens/login_screen.dart';
import 'widgets/network_banner.dart';

void main() {
  runApp(const SpareDashApp());
}

class SpareDashApp extends StatelessWidget {
  const SpareDashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => DatabaseProvider()),
        ChangeNotifierProvider(create: (context) => ConnectivityProvider()),
      ],
      child: const MaterialApp(
        title: 'SpareDash',
        debugShowCheckedModeBanner: false,
        home: _RootScreen(),
      ),
    );
  }
}

class _RootScreen extends StatelessWidget {
  const _RootScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NetworkBanner(
        child: const LoginScreen(),
      ),
    );
  }
}