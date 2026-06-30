import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/database_provider.dart';
import '../services/input_handler.dart';
import 'simple_home.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;
  String? _generalError;

  Future<void> _handleRegister() async {
    setState(() {
      _nameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmError = null;
      _generalError = null;
    });

    // Use InputHandler for validation (Week 8 — OOP input handling)
    final errors = InputHandler.handleRegisterInput(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    setState(() {
      _nameError = errors['name'];
      _emailError = errors['email'];
      _passwordError = errors['password'];
      _confirmError = errors['confirmPassword'];
    });

    if (!InputHandler.isFormValid(errors)) return;

    setState(() => _isLoading = true);

    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    bool success = await provider.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SimpleHomeScreen()),
              (route) => false,
        );
      }
    } else {
      setState(() => _generalError = 'An account with this email already exists');
    }
  }

  @override
  Widget build(BuildContext context) {
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
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 1),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: const Icon(Icons.car_repair, size: 50, color: Color(0xFFf59e0b)),
                        ),
                        const SizedBox(height: 16),
                        const Text('Create Account',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 8),
                        const Text('Join SpareDash today',
                            style: TextStyle(color: Colors.white70)),
                        const SizedBox(height: 32),

                        // Name field
                        _buildField(
                          controller: _nameController,
                          focusNode: _nameFocus,
                          nextFocus: _emailFocus,
                          hint: 'Full Name',
                          icon: Icons.person_outline,
                          errorText: _nameError,
                          action: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        // Email field
                        _buildField(
                          controller: _emailController,
                          focusNode: _emailFocus,
                          nextFocus: _passwordFocus,
                          hint: 'Email',
                          icon: Icons.email_outlined,
                          errorText: _emailError,
                          action: TextInputAction.next,
                          keyboard: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        _buildPasswordField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          nextFocus: _confirmFocus,
                          hint: 'Password',
                          obscure: _obscurePassword,
                          errorText: _passwordError,
                          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                          action: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        // Confirm password field
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          focusNode: _confirmFocus,
                          hint: 'Confirm Password',
                          obscure: _obscureConfirmPassword,
                          errorText: _confirmError,
                          onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          action: TextInputAction.done,
                          onSubmit: _handleRegister,
                        ),

                        if (_generalError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(_generalError!,
                                style: const TextStyle(color: Colors.orange, fontSize: 12),
                                textAlign: TextAlign.center),
                          ),

                        const SizedBox(height: 24),

                        // Register button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFf59e0b),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                                : const Text('Create Account',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Already have an account? ',
                                style: TextStyle(color: Colors.white.withOpacity(0.8))),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text('Login',
                                  style: TextStyle(
                                      color: Color(0xFFf59e0b),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Color(0xFFf59e0b))),
                            ),
                          ],
                        ),
                        const Spacer(flex: 1),
                        const SizedBox(height: 16),
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

  Widget _buildField({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    required String hint,
    required IconData icon,
    String? errorText,
    TextInputAction action = TextInputAction.next,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboard,
      textInputAction: action,
      onSubmitted: (_) {
        if (nextFocus != null) {
          InputHandler.handleKeyboardAction(
            action: action,
            onSubmit: () => FocusScope.of(context).requestFocus(nextFocus),
          );
        }
      },
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFFf59e0b)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        errorText: errorText,
        errorStyle: const TextStyle(color: Colors.orange),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    required String hint,
    required bool obscure,
    String? errorText,
    required VoidCallback onToggle,
    TextInputAction action = TextInputAction.next,
    VoidCallback? onSubmit,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      textInputAction: action,
      onSubmitted: (_) {
        if (onSubmit != null) {
          InputHandler.handleKeyboardAction(action: action, onSubmit: onSubmit);
        } else if (nextFocus != null) {
          InputHandler.handleKeyboardAction(
            action: action,
            onSubmit: () => FocusScope.of(context).requestFocus(nextFocus),
          );
        }
      },
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFf59e0b)),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        errorText: errorText,
        errorStyle: const TextStyle(color: Colors.orange),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }
}