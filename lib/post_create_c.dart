import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreatePostController {
  String? selectedArea;
  String? selectedGrade;
  String? selectedSubject;
  String? selectedGender;

  final List<String> areas = ['Area 1', 'Area 2', 'Area 3'];
  final List<String> grades = ['Grade 1', 'Grade 2', 'Grade 3'];
  final List<String> subjects = ['Math', 'Science', 'English'];
  final List<String> genders = ['Male', 'Female', 'Any'];

  Future<void> createPost(String title, String description, BuildContext context) async {
    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields")),
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
        SnackBar(content: Text("Error creating post: \$e")),
      );
    }
  }
}
