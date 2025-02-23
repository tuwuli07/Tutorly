import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login.dart';

class TeReg extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  TeReg({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Registration'),
        backgroundColor: Color(0xFF7F3FBF),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7F3FBF), Color(0xFF3B8ADE)],
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(20),
            children: [
              _buildTextField(_firstNameController, 'First Name', Icons.person),
              SizedBox(height: 16),
              _buildTextField(_lastNameController, 'Last Name', Icons.person),
              SizedBox(height: 16),
              _buildTextField(_emailController, 'Email', Icons.email, isEmail: true),
              SizedBox(height: 16),
              _buildPasswordField(_passwordController, 'Password'),
              SizedBox(height: 16),
              _buildPasswordField(_confirmPasswordController, 'Confirm Password'),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => registerUser(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF7F3FBF),
                  minimumSize: Size(double.infinity, 50),
                ), // Pass context for navigation
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon,
      {bool isEmail = false}
      ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.white24,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        if (isEmail && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.lock, color: Colors.white),
        filled: true,
        fillColor: Colors.white24,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        if (label == 'Confirm Password' && value != _passwordController.text) {
          return 'Passwords do not match';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }
  Future<void> registerUser(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Firebase Authentication
      final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final User? user = userCredential.user;
      if (user == null) throw FirebaseAuthException(code: "user-null");

      final userDocRef = FirebaseFirestore.instance.collection("users").doc(user.uid);

      // Check if the user already exists
      final userSnapshot = await userDocRef.get();
      final userData = userSnapshot.data() as Map<String, dynamic>? ?? {};
      List<String> roles = userSnapshot.exists && userSnapshot.data()!['role'] is List
          ? List<String>.from(userSnapshot.data()!['role'])
          : [];


      // Add student role if not present
      if (!roles.contains("teacher")) {
        roles.add("teacher");
      }

      // Update Firestore user document
      await userDocRef.set({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'username': userData['username'] ?? user.email!.split('@')[0],
        'description': userData['description'] ?? 'Empty bio...',
        'phoneNumber': userData['phoneNumber'] ?? 'null',
        'address': userData['address'] ?? 'null',
        'education': userData['education'] ?? 'null',
        'role': roles.isEmpty ? ["teacher"] : FieldValue.arrayUnion(["teacher"]),
      }, SetOptions(merge: true));

      // Save student-specific data
      await FirebaseFirestore.instance.collection("teachers").doc(user.uid).set({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'username': userData['username'] ?? user.email!.split('@')[0],
        'description': userData['description'] ?? 'Empty bio...',
        'phoneNumber': userData['phoneNumber'] ?? 'null',
        'address': userData['address'] ?? 'null',
        'education': userData['education'] ?? 'null',
      });

      // Close loading indicator
      if (context.mounted) Navigator.pop(context);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Teacher registered successfully!'), backgroundColor: Colors.green),
        );
      }

      // Navigate to login screen
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyLogin()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) Navigator.pop(context);

      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email.';
          break;
        case 'weak-password':
          errorMessage = 'Password must be at least 6 characters.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid.';
          break;
        default:
          errorMessage = 'An error occurred. Please try again.';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again later.'), backgroundColor: Colors.red),
        );
      }
    }
  }
}