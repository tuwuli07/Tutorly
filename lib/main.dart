import 'package:flutter/material.dart';
import 'login.dart'; // Your login page implementation
import 'feed.dart'; // Your FeedScreen implementation

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: 'login',
    routes: {
      'login': (context) => const MyLogin(), // Login page route
      'feed': (context) => const FeedScreen(), // Feed screen route
    },
  ));
}
