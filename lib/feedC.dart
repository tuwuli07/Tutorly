import 'package:flutter/material.dart';

class FeedController {
  final List<String> areas = ['Mirpur', 'Azimpur', 'Tejgaon','Dhanmondi','Gulshan','Banani','Farmgate','Kuril'];
  final List<String> grades = ['Class 1', 'Class 2', 'Class 3', 'Class 4','Class 5','Class 6','Class 7','Class 9','Class 10','Class 11','Class 12','A Levels', 'O Levels'];
  final List<String> subjects = ['Math', 'Science', 'English', 'History','Biology','Physics','Chemistry','Accounting','Statistics'];
  final List<String> genders = ['Male', 'Female', 'Any'];
  final List<String> versions = ['Bangla Version', 'English Version', 'English Medium'];

  String? selectedArea;
  String? selectedGrade;
  List<String> selectedSubjects = [];
  String? selectedGender;
  String? selectedVersion;

  final List<Map<String, String>> allPosts = [

  ];

  List<Map<String, String>> filteredPosts = [];

  void initFilters() {
    filteredPosts = List.from(allPosts);
  }

  void applyFilters() {
    filteredPosts = allPosts.where((post) {
      final matchesArea = selectedArea == null || post['area'] == selectedArea;
      final matchesGrade = selectedGrade == null || post['grade'] == selectedGrade;
      final matchesSubject = selectedSubjects.isEmpty ||
          (post['subject'] is List && post['subject'] != null && selectedSubjects.any((s) => (post['subject'] as List).contains(s)));
      final matchesGender = selectedGender == null || post['gender'] == selectedGender;
      final matchesVersion = selectedVersion == null || post['version'] == selectedVersion;
      return matchesArea && matchesGrade && matchesSubject && matchesGender && matchesVersion;
    }).toList();
  }

  void clearFilters() {
    selectedArea = null;
    selectedGrade = null;
    selectedSubjects = [];
    selectedGender = null;
    selectedVersion = null;
    filteredPosts = List.from(allPosts); // Reset to show all posts
  }

  void dispose() {}
}
