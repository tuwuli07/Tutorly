import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreatePostController {
  String? selectedArea;
  String? selectedGrade;
  String? selectedSubject;
  String? selectedGender;

  final List<String> areas = ['Mirpur', 'Azimpur', 'Tejgaon', 'Dhanmondi'];
  final List<String> grades = ['Class 1', 'CLass 2', 'Class 3'];
  final List<String> subjects = ['Math', 'Science', 'English'];
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

    Map<String, dynamic> newPost = {
      'title': title,
      'description': description,
      'area': selectedArea,
      'grade': selectedGrade,
      'subject': selectedSubject,
      'gender': selectedGender,
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
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