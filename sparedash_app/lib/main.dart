import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database/database_helper.dart';
import 'providers/database_provider.dart';
import 'providers/api_provider.dart';
import 'providers/network_provider.dart';
import 'screens/login_screen.dart';
import 'screens/api_demo_screen.dart';
import 'screens/simple_home.dart';
import 'services/network_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  final dbHelper = DatabaseHelper();
  await dbHelper.database;

  // Print all users for debugging
  await dbHelper.printAllUsers();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Initialize network notification service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentContext!;
      NetworkNotificationService().init(context);
    });
  }

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
        navigatorKey: navigatorKey,
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
          '/': (context) => const LoginScreen(),
          '/api-demo': (context) => const ApiDemoScreen(),
          '/home': (context) => const SimpleHomeScreen(),
        },
      ),
    );
  }
}