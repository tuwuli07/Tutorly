import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Add this import
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
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Tutorly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.dark,
      ),
      themeMode: themeProvider.themeMode,
      home: const HomePage(),
      routes: {
        'login': (context) => const MyLogin(),
        'feed': (context) => const FeedScreen(),
        'stu_feed': (context) => const FeedStu(),
        'register': (context) => UserTypeSelection(),
        'profile': (context) => const ProfilePage(),
        'settings': (context) => const SettingsPage(),
        'notifications': (context) => const NotificationsPage(),
        'message': (context) => const MessagePage(),
        'feedback': (context) => const FeedbackPage(),
      },
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}