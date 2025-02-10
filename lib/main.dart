import 'package:flutter/material.dart';
import 'package:new_project/feedback.dart';
import 'message.dart';
import 'HomePage.dart';
import 'login.dart';
import 'feed.dart';
import 'registration.dart';
import 'profile.dart';
import 'settings.dart';
import 'notifications.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tutorly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
      routes: {
        'login': (context) => const MyLogin(),
        'feed': (context) => const FeedScreen(),
        'register': (context) => RegistrationPage(),
        'profile': (context) => const ProfilePage(),
        'settings': (context) => const SettingsPage(),
        'notifications': (context) => const NotificationsPage(),
        'message' : (context) => const MessagePage(),
        'feedback' : (context) => const FeedbackPage(),
      },
    );
  }
}
