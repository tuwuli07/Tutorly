import 'package:flutter/material.dart';
import 'feed.dart'; // Import the feed screen

class LoginController {
  String? selectedRole;
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }

  // Method to set the selected role
  void setSelectedRole(String role) {
    selectedRole = role;
  }

  // Method to validate selection and handle login
  /*String? validateSelection() {
    if (selectedRole == null) {
      return "Please select a role to proceed.";
    }
    return null;
  }
  */

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!value.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void handleLogin(BuildContext context) {
    if (formKey.currentState!.validate()) {
      // Add your login logic here
      print('Role selected: $selectedRole');
      print('Email: ${emailController.text}');
      print('Password: ${passwordController.text}');

      // Navigate to the feed screen after successful login
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FeedScreen()),
      );
    }
  }
}
