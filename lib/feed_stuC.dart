import 'package:flutter/material.dart';

class StuFeedController {
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
    {
      'title': 'Math Tutor Needed',
      'description': 'Looking for a Math tutor in Azimpur for Class 1.',
      'area': 'Azimpur',
      'grade': 'Class 1',
      'subject': 'Math',
      'gender': 'Any',
    },
    {
      'title': 'Science Tutor Wanted',
      'description': 'Science tutor needed in Mirpur for Class 3.',
      'area': 'Mirpur',
      'grade': 'Class 3',
      'subject': 'Science',
      'gender': 'Female',
    },
    {
      'title': 'English Tutor Required',
      'description': 'Seeking English tutor in Tejgaon for Class 2.',
      'area': 'Tejgaon',
      'grade': 'Class 2',
      'subject': 'English',
      'gender': 'Male',
    },
    {
      'title': 'History Guidance Needed',
      'description': 'Need a History tutor for Class 4 in Kuril.',
      'area': 'Kuril',
      'grade': 'Class 4',
      'subject': 'History',
      'gender': 'Any',
    },
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
