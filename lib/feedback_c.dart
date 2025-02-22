import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FeedbackController {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> submitFeedback(BuildContext context, String feedback) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (feedback.isEmpty) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text("Feedback cannot be empty"), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      User? user = _auth.currentUser;
      String userId = user?.uid ?? "anonymous";
      String email = user?.email ?? "Guest";

      await _firestore.collection("feedbacks").add({
        "userId": userId,
        "email": email,
        "feedback": feedback,
        "timestamp": FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text("Feedback submitted successfully!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text("Failed to submit feedback: $e"), backgroundColor: Colors.red),
        );
      }
      if (kDebugMode) {
        print("Error submitting feedback: $e");
      }
    }
  }
}
