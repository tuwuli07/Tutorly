import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StuFeedController extends ChangeNotifier{
  final List<Map<String, String>> allPosts = [
  ];

  set _postsStream(Stream<QuerySnapshot<Map<String, dynamic>>> postsStream) {}
  void fetchFilteredPosts(List<String> selectedSubjects) {
    if (selectedSubjects.isEmpty) {
      _postsStream = FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .snapshots();
    } else {
      _postsStream = FirebaseFirestore.instance
          .collection('posts')
          .where('subject', arrayContainsAny: selectedSubjects)
          .orderBy('timestamp', descending: true)
          .snapshots();
    }
    notifyListeners();
  }

}
