import 'package:flutter/material.dart';
import 'loginC.dart';

class MyLogin extends StatefulWidget {
  const MyLogin({super.key});

  @override
  _MyLoginState createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  final LoginController loginC = LoginController();

  @override
  void dispose() {
    loginC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF9C27B0),  // Purple
            Color(0xFF00BCD4),  // Cyan
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Logo and Options Section
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Section
                      const SizedBox(
                        height: 80,
                        width: 120,
                        child: Image(
                          image: AssetImage('lib/icons/logo.png'), // Custom logo image
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Options Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Option 1: Student/Parent
                          GestureDetector(
                            onTap: () {
                              // Handle Student/Parent option
                              setState(() {
                                loginC.setSelectedRole('Student/Parent');
                              });
                            },
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: loginC.selectedRole == 'Student/Parent'
                                          ? Colors.blue
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: const SizedBox(
                                    height: 80,
                                    width: 80,
                                    child: Image(
                                      image: AssetImage(
                                          'lib/icons/login_stu.png'), // Custom icon for student/parent
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Select if you're\n a student/parent",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 30),
                          // Option 2: Teacher
                          GestureDetector(
                            onTap: () {
                              // Handle Teacher option
                              setState(() {
                                loginC.setSelectedRole('Teacher');
                              });
                            },
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: loginC.selectedRole == 'Teacher'
                                          ? Colors.blue
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: const SizedBox(
                                    height: 80,
                                    width: 80,
                                    child: Image(
                                      image: AssetImage(
                                          'lib/icons/login_te.png'), // Custom icon for teacher
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Select if you're\n a teacher",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Form Section
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 35),
                  child: Form(
                    key: loginC.formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: loginC.emailController,
                          decoration: InputDecoration(
                            fillColor: Colors.white.withOpacity(0.9),
                            filled: true,
                            hintText: 'Email',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: loginC.validateEmail,
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: loginC.passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            fillColor: Colors.white.withOpacity(0.9),
                            filled: true,
                            hintText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: loginC.validatePassword,
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () {
                            if (loginC.selectedRole == null) {
                              // Show an error if no role is selected
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select a role (Student/Parent or Teacher) before signing in.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } else {
                              // Proceed with login if a role is selected
                              if (loginC.formKey.currentState!.validate()) {
                                loginC.handleLogin(context);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF9C27B0),
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            // Add forgot password logic
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Register Button
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, 'register'); // Navigate to the registration page
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            "Don't have an account? Register here.",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}