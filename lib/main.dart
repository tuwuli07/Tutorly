import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'login.dart';
import 'feed.dart';
import 'registration.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tutorly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Set the initial route
      home: const HomePage(),
      routes: {
        'login': (context) => const MyLogin(), // Login page route
        'feed': (context) => const FeedScreen(),
        'register': (context) => RegistrationPage(),// Feed screen route
      },
    );
  }
}
