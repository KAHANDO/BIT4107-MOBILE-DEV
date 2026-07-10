import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connectivity_provider.dart';
import '../services/input_handler.dart';
import 'simple_home.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;

  void _validateAndLogin() {
    setState(() { _emailError = null; _passwordError = null; });

    final connectivity = Provider.of<ConnectivityProvider>(context, listen: false);
    if (!connectivity.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Row(children: [
          Icon(Icons.wifi_off, color: Colors.white, size: 18),
          SizedBox(width: 10),
          Expanded(child: Text('No internet. Please connect to login.',
              style: TextStyle(color: Colors.white))),
        ]),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }

    final errors = InputHandler.handleLoginInput(
      email: _emailController.text,
      password: _passwordController.text,
    );

    setState(() {
      _emailError = errors['email'];
      _passwordError = errors['password'];
    });

    if (InputHandler.isFormValid(errors)) {
      _handleLogin();
    }
  }

  void _handleLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SimpleHomeScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = context.watch<ConnectivityProvider>().isConnected;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),

                        // Offline banner
                        if (!isConnected)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.red[700],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red[300]!),
                            ),
                            child: const Row(children: [
                              Icon(Icons.wifi_off, color: Colors.white, size: 18),
                              SizedBox(width: 10),
                              Expanded(child: Text(
                                  'You are offline. Internet required to login.',
                                  style: TextStyle(color: Colors.white, fontSize: 12))),
                            ]),
                          ),

                        // Logo
                        Column(children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                            ),
                            child: const Icon(Icons.car_repair, size: 50, color: Color(0xFFf59e0b)),
                          ),
                          const SizedBox(height: 16),
                          const Text('SpareDash',
                              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 8),
                          Text('Spare parts at your fingertips',
                              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
                        ]),

                        const SizedBox(height: 50),

                        // Email field
                        TextField(
                          controller: _emailController,
                          focusNode: _emailFocus,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) {
                            InputHandler.handleKeyboardAction(
                              action: TextInputAction.next,
                              onSubmit: () => FocusScope.of(context).requestFocus(_passwordFocus),
                            );
                          },
                          decoration: InputDecoration(
                            hintText: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFf59e0b)),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                            errorText: _emailError,
                            errorStyle: const TextStyle(color: Colors.orange),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Password field
                        TextField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: Colors.white),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) {
                            InputHandler.handleKeyboardAction(
                              action: TextInputAction.done,
                              onSubmit: _validateAndLogin,
                            );
                          },
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFf59e0b)),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.white70),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                            errorText: _passwordError,
                            errorStyle: const TextStyle(color: Colors.orange),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Reset password link sent to your email!')));
                            },
                            child: const Text('Forgot Password?',
                                style: TextStyle(color: Color(0xFFf59e0b))),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Login button
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _validateAndLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isConnected
                                  ? const Color(0xFFf59e0b)
                                  : Colors.grey[600],
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                                : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (!isConnected)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Icon(Icons.wifi_off,
                                        color: Colors.white, size: 16),
                                  ),
                                Text(isConnected ? 'Login' : 'No Connection',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Sign up row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account? ",
                                style: TextStyle(color: Colors.white.withOpacity(0.8))),
                            TextButton(
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(
                                        builder: (context) => RegisterScreen()));
                              },
                              child: const Text('Sign Up',
                                  style: TextStyle(
                                      color: Color(0xFFf59e0b),
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),

                        // Demo credentials
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(children: [
                            const Text('Demo Credentials',
                                style: TextStyle(
                                    color: Color(0xFFf59e0b),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('Email: demo@sparedash.com',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 11)),
                            Text('Password: demo123',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 11)),
                          ]),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }
}