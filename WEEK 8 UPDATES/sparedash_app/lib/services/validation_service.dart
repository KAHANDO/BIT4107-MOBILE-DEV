class ValidationService {
  // Email validation
  static String? validateEmail(String email) {
    if (email.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.trim())) return 'Enter a valid email address';
    return null;
  }

  // Password validation
  static String? validatePassword(String password, {int minLength = 6}) {
    if (password.isEmpty) return 'Password is required';
    if (password.length < minLength) return 'Password must be at least $minLength characters';
    return null;
  }

  // Name validation
  static String? validateName(String name) {
    if (name.trim().isEmpty) return 'Name is required';
    if (name.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  // Password match validation
  static String? validatePasswordMatch(String password, String confirmPassword) {
    if (password != confirmPassword) return 'Passwords do not match';
    return null;
  }

  // Search query validation
  static String? validateSearchQuery(String query) {
    if (query.trim().isEmpty) return 'Please enter a search term';
    if (query.trim().length < 2) return 'Search term must be at least 2 characters';
    return null;
  }

  // General non-empty validation
  static String? validateRequired(String value, String fieldName) {
    if (value.trim().isEmpty) return '$fieldName is required';
    return null;
  }
}