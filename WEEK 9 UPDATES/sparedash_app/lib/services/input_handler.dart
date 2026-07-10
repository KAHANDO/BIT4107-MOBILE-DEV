import 'package:flutter/material.dart';
import 'validation_service.dart';

class InputHandler {
  // Handles login form submission with validation
  static Map<String, String?> handleLoginInput({
    required String email,
    required String password,
  }) {
    return {
      'email': ValidationService.validateEmail(email),
      'password': ValidationService.validatePassword(password, minLength: 4),
    };
  }

  // Handles registration form submission with validation
  static Map<String, String?> handleRegisterInput({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    return {
      'name': ValidationService.validateName(name),
      'email': ValidationService.validateEmail(email),
      'password': ValidationService.validatePassword(password),
      'confirmPassword': ValidationService.validatePasswordMatch(password, confirmPassword),
    };
  }

  // Handles search input with validation
  static String? handleSearchInput(String query) {
    return ValidationService.validateSearchQuery(query);
  }

  // Handles keyboard action (Enter key)
  static void handleKeyboardAction({
    required TextInputAction action,
    required VoidCallback onSubmit,
  }) {
    if (action == TextInputAction.search || action == TextInputAction.done) {
      onSubmit();
    }
  }

  // Checks if the entire form is valid
  static bool isFormValid(Map<String, String?> errors) {
    return errors.values.every((error) => error == null);
  }
}