import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'feed.dart';
import 'feed_stu.dart';

class LoginController extends ChangeNotifier{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _selectedRole;
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? get selectedRole => _selectedRole;

  void setSelectedRole(String role) {
    _selectedRole = role;
    notifyListeners(); // Notify UI to rebuild
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
        if (!context.mounted) return; // Ensure widget is still mounted before proceeding
        Navigator.pop(context);

        final User? user = userCredential.user;
        if (user == null) throw FirebaseAuthException(code: "user-null");

        // Fetch user data from Firestore
        final userDocRef = FirebaseFirestore.instance.collection("users").doc(user.uid);
        final userSnapshot = await userDocRef.get();
        if (!context.mounted) return;
        final userData = userSnapshot.data() as Map<String, dynamic>? ?? {};
        List<dynamic> roles = List.from(userData['role'] ?? []);

        if (roles.isEmpty) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No role assigned. Please contact support.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        if (!roles.contains(selectedRole)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selected role does not match registered role.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
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
          Widget feedScreen = _selectedRole == "teacher" ? const FeedScreen() : const FeedStu();
          // Navigate to feed screen and remove all previous routes
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => feedScreen),
                  (route) => false,
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        // Close loading indicator
        if (!context.mounted) return;
        Navigator.pop(context);
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
        showErrorSnackbar(context, errorMessage);
      } catch (e) {
        if (!context.mounted) return;
        Navigator.pop(context);
        showErrorSnackbar(context, "An error occurred. Please try again later.");
      }
    }
  }
  void showErrorSnackbar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
