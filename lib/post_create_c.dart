import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreatePostController {
  String? selectedArea;
  String? selectedGrade;
  List<String> selectedSubjects = [];
  String? selectedGender;
  String? selectedVersion;

  final List<String> areas = ['Mirpur', 'Azimpur', 'Tejgaon', 'Dhanmondi','Gulshan','Banani','Farmgate','Kuril'];
  final List<String> grades = ['Class 1', 'Class 2', 'Class 3', 'Class 4','Class 5','Class 6','Class 7','Class 9','Class 10','Class 11','Class 12','A Levels', 'O Levels'];
  final List<String> subjects = ['Math', 'Science', 'English', 'History','Biology','Physics','Chemistry','Accounting','Statistics'];
  final List<String> genders = ['Male', 'Female', 'Any'];
  final List<String> versions = ['Bangla Version', 'English Version', 'English Medium'];

  Future<void> createPost(String title, String description, BuildContext context) async {
    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill title and description")),
      );
      return;
    }

    if (selectedArea == null || selectedSubjects.isEmpty || selectedGender == null || selectedVersion==null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select all filters")),
      );
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not authenticated")),
      );
      return;
    }

    try {

      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      String creatorName = userDoc.exists ? userDoc['username'] ?? 'Unknown' : 'Unknown';
      Map<String, dynamic> newPost = {
        'title': title,
        'description': description,
        'area': selectedArea,
        'grade': selectedGrade,
        'version' : selectedVersion,
        'subject': FieldValue.arrayUnion(selectedSubjects),
        'gender': selectedGender,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user.uid,
        'creatorName': creatorName,
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