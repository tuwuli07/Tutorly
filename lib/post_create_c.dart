import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreatePostController {
  String? selectedArea;
  String? selectedGrade;
  String? selectedSubject;
  String? selectedGender;

  final List<String> areas = ['Mirpur', 'Azimpur', 'Tejgaon', 'Dhanmondi','Gulshan','Banani','Farmgate','Kuril'];
  final List<String> grades = ['Class 1', 'CLass 2', 'Class 3','Class 4','Class 5','Class 6','Class 7','Class 8','Class 9','Class 10','Class 11','Class 12'];
  final List<String> subjects = ['Math', 'Science', 'English','History','Biology','Physics','Chemistry','Accounting'];
  final List<String> genders = ['Male', 'Female', 'Any'];

  Future<void> createPost(String title, String description, BuildContext context) async {
    // Check if title or description is empty
    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill title and description")),
      );
      return;
    }

    // Check if all dropdowns have been selected
    if (selectedArea == null || selectedGrade == null ||
        selectedSubject == null || selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select all filters")),
      );
      return;
    }
// Get the current user
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not authenticated")),
      );
      return;
    }

    try {
      // Retrieve the creator's name from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      String creatorName = userDoc.exists ? userDoc['username'] ?? 'Unknown' : 'Unknown';
      // Create post data
      Map<String, dynamic> newPost = {
        'title': title,
        'description': description,
        'area': selectedArea,
        'grade': selectedGrade,
        'subject': selectedSubject,
        'gender': selectedGender,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user.uid, // Store user ID
        'creatorName': creatorName, // Store creator name
      };

      await FirebaseFirestore.instance.collection('posts').add(newPost);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Post created successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error creating post: $e")),
      );
    }
  }
}