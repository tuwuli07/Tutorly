import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'feed.dart'; // Import the feed screen

class LoginController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? selectedRole;
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }

  void setSelectedRole(String role) {
    selectedRole = role;
  }

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

  Future<void> handleLogin(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
          const Center(child: CircularProgressIndicator()),
        );

        // Attempt to sign in
        final UserCredential userCredential = await _auth
            .signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Close loading indicator
        if (context.mounted) {
          Navigator.pop(context);
        }

        if (userCredential.user != null) {
          // Successfully logged in
          if (kDebugMode) {
            print('Successfully logged in: ${userCredential.user?.email}');
          }
          if (kDebugMode) {
            print('Role selected: $selectedRole');
          }

          // Navigate to feed screen and remove all previous routes
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const FeedScreen()),
                  (route) => false,
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        // Close loading indicator
        if (context.mounted) {
          Navigator.pop(context);
        }


        // Show error message
        String errorMessage;
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found with this email.';
            break;
          case 'wrong-password':
            errorMessage = 'Wrong password provided.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is invalid.';
            break;
          case 'user-disabled':
            errorMessage = 'This user account has been disabled.';
            break;
          default:
            errorMessage = 'An error occurred. Please try again.';
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Close loading indicator
        if (context.mounted) {
          Navigator.pop(context);
        }


        // Show general error message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An error occurred. Please try again later.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
