import 'package:flutter/material.dart';

class FeedController {
  // Filter options
  final List<String> areas = ['Mirpur', 'Azimpur', 'Tejgaon'];
  final List<String> grades = ['Grade 1', 'Grade 2', 'Grade 3', 'Grade 4'];
  final List<String> subjects = ['Math', 'Science', 'English', 'History'];
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
      'description': 'Looking for a Math tutor in Azimpur for Grade 1.',
      'area': 'Azimpur',
      'grade': 'Grade 1',
      'subject': 'Math',
      'gender': 'Any',
    },
    {
      'title': 'Science Tutor Wanted',
      'description': 'Science tutor needed in Mirpur for Grade 3.',
      'area': 'Mirpur',
      'grade': 'Grade 3',
      'subject': 'Science',
      'gender': 'Female',
    },
    {
      'title': 'English Tutor Required',
      'description': 'Seeking English tutor in Tejgaon for Grade 2.',
      'area': 'Tejgaon',
      'grade': 'Grade 2',
      'subject': 'English',
      'gender': 'Male',
    },
    {
      'title': 'History Guidance Needed',
      'description': 'Need a History tutor for Grade 4 in Mirpur.',
      'area': 'Mirpur',
      'grade': 'Grade 4',
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
