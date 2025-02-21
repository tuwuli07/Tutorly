import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'login.dart';

class StuReg extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  StuReg({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Registration'),
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
                onPressed: () => _submitForm(context),
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

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (kDebugMode) {
        print('Student registration successful');
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyLogin()), // Navigate to login page
      );
    }
  }
}