import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/database_provider.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedGender;

  Future<void> _handleRegister() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();
    String location = _locationController.text.trim();
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    // Validation
    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your full name';
        _isLoading = false;
      });
      return;
    }

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email';
        _isLoading = false;
      });
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
        _isLoading = false;
      });
      return;
    }

    if (location.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your location';
        _isLoading = false;
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a password';
        _isLoading = false;
      });
      return;
    }

    if (password.length < 4) {
      setState(() {
        _errorMessage = 'Password must be at least 4 characters';
        _isLoading = false;
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Passwords do not match';
        _isLoading = false;
      });
      return;
    }

    final provider = Provider.of<DatabaseProvider>(context, listen: false);

    // Check if user exists
    bool exists = await provider.checkUserExists(email);
    if (exists) {
      setState(() {
        _errorMessage = 'Email already registered. Please login.';
        _isLoading = false;
      });
      return;
    }

    // Register user
    Map<String, dynamic> userData = {
      'name': name,
      'email': email,
      'phone': phone.isEmpty ? null : phone,
      'location': location,
      'password': password,
      'gender': _selectedGender ?? 'Not specified',
      'profile_image': 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
      'loyalty_points': 0,
      'member_tier': 'Bronze',
    };

    bool success = await provider.registerUser(userData);

    setState(() => _isLoading = false);

    if (success) {
      _showSuccessDialog();
    } else {
      setState(() {
        _errorMessage = 'Registration failed. Please try again.';
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Icon(Icons.check_circle, color: Color(0xFFf59e0b), size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Registration Successful!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Welcome ${_nameController.text.trim()}!'),
            const SizedBox(height: 8),
            const Text('Your account has been created successfully.'),
            const SizedBox(height: 8),
            const Text('You can now login.', style: TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
            ),
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Header
                const Center(
                  child: Column(
                    children: [
                      Icon(Icons.person_add, size: 60, color: Color(0xFFf59e0b)),
                      SizedBox(height: 16),
                      Text(
                        'Join SpareDash',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Create your account to get started',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Full Name
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Full Name *',
                    prefixIcon: const Icon(Icons.person_outline, color: Color(0xFFf59e0b)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                ),
                const SizedBox(height: 16),

                // Email
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address *',
                    prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFf59e0b)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                ),
                const SizedBox(height: 16),

                // Phone
                TextField(
                  controller: _phoneController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number (Optional)',
                    prefixIcon: const Icon(Icons.phone_android, color: Color(0xFFf59e0b)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                ),
                const SizedBox(height: 16),

                // Location
                TextField(
                  controller: _locationController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Location *',
                    prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFFf59e0b)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                ),
                const SizedBox(height: 16),

                // Gender Selection
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedGender,
                      hint: const Text(
                        'Select Gender (Optional)',
                        style: TextStyle(color: Colors.white70),
                      ),
                      dropdownColor: const Color(0xFF1E40AF),
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFf59e0b)),
                      items: const [
                        DropdownMenuItem(value: 'Male', child: Text('Male', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'Female', child: Text('Female', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'Other', child: Text('Other', style: TextStyle(color: Colors.white))),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Password *',
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFf59e0b)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white70,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    helperText: 'Minimum 4 characters',
                    helperStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm Password
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Confirm Password *',
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFf59e0b)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white70,
                      ),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                ),

                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.orange),
                    ),
                  ),

                const SizedBox(height: 30),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFf59e0b),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: const Color(0xFFf59e0b),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}