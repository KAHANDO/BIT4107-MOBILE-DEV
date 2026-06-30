import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database/database_helper.dart';
import 'providers/database_provider.dart';
import 'providers/api_provider.dart';
import 'providers/network_provider.dart';
import 'screens/login_screen.dart';
import 'screens/api_demo_screen.dart';
import 'screens/simple_home.dart';
import 'widgets/network_status_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  final dbHelper = DatabaseHelper();
  await dbHelper.database;

  // Print all users for debugging
  await dbHelper.printAllUsers();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DatabaseProvider()),
        ChangeNotifierProvider(create: (context) => ApiProvider()),
        ChangeNotifierProvider(create: (context) => NetworkProvider()),
      ],
      child: MaterialApp(
        title: 'SpareDash',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF2563EB),
          useMaterial3: true,
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2563EB),
            secondary: Color(0xFFf59e0b),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2563EB),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => NetworkStatusWidget(
            child: const LoginScreen(),
          ),
          '/api-demo': (context) => NetworkStatusWidget(
            child: const ApiDemoScreen(),
          ),
          '/home': (context) => NetworkStatusWidget(
            child: const SimpleHomeScreen(),
          ),
        },
      ),
    );
  }
}