import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:new_project/feedback.dart';
import 'user_type_selection.dart';
import 'message.dart';
import 'HomePage.dart';
import 'login.dart';
import 'feed.dart';
import 'profile.dart';
import 'settings.dart';
import 'notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'feed_stu.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    if (kDebugMode) {
      print("Firebase already initialized: $e");
    }
  }
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
        'stu_feed': (context) => const FeedStu(),
        'register': (context) => UserTypeSelection(),
        'profile': (context) => const ProfilePage(),
        'settings': (context) => const SettingsPage(),
        'notifications': (context) => const NotificationsPage(),
        'message' : (context) => const MessagePage(),
        'feedback' : (context) => const FeedbackPage(),
      },
    );
  }
}
