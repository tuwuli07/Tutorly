import 'package:flutter/material.dart';

class FeedController {
  // Filter options
  final List<String> areas = ['Mirpur', 'Azimpur', 'Tejgaon','Dhanmondi','Gulshan','Banani','Farmgate','Kuril'];
  final List<String> grades = ['Class 1', 'Class 2', 'Class 3', 'Class 4','Class 5','Class 6','Class 7','Class 9','Class 10','Class 11','Class 12'];
  final List<String> subjects = ['Math', 'Science', 'English', 'History','Biology','Physics','Chemistry','Accounting','English'];
  final List<String> genders = ['Male', 'Female', 'Any'];

  // Selected filter values
  String? selectedArea;
  String? selectedGrade;
  String? selectedSubject;
  String? selectedGender;

  // All posts (mock data)
  final List<Map<String, String>> allPosts = [

  ];

  // Filtered posts
  List<Map<String, String>> filteredPosts = [];

  // Initialize the filters
  void initFilters() {
    filteredPosts = List.from(allPosts); // Initially, show all posts
  }

  // Apply filters
  void applyFilters() {
    filteredPosts = allPosts.where((post) {
      final matchesArea = selectedArea == null || post['area'] == selectedArea;
      final matchesGrade = selectedGrade == null || post['grade'] == selectedGrade;
      final matchesSubject = selectedSubject == null || post['subject'] == selectedSubject;
      final matchesGender = selectedGender == null || post['gender'] == selectedGender;
      return matchesArea && matchesGrade && matchesSubject && matchesGender;
    }).toList();
  }

  // Clear filters
  void clearFilters() {
    selectedArea = null;
    selectedGrade = null;
    selectedSubject = null;
    selectedGender = null;
    filteredPosts = List.from(allPosts); // Reset to show all posts
  }

  // Dispose resources if needed (not applicable here, but keeping for future use)
  void dispose() {}
}
