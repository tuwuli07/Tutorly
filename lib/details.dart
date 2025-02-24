import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile.dart';

class DetailsPage extends StatefulWidget {
  final Map<String, dynamic> postData;
  final String postId;

  @override
  State<DetailsPage> createState() => _DetailsPageState();
  const DetailsPage({required this.postData, required this.postId, super.key});
}

class _DetailsPageState extends State<DetailsPage> {
  String studentName = "Unknown Student";
  String postTimestamp = "Unknown Time";

  @override
  void initState() {
    super.initState();
    fetchStudentNameAndTimestamp();
  }

  final TextEditingController _messageController = TextEditingController();
  int selectedIndex=-1;

  Future<void> fetchStudentNameAndTimestamp() async {
    try {
      String studentId = widget.postData['userId'] ?? '';
      Timestamp? timestamp = widget.postData['timestamp'];

      if (studentId.isNotEmpty) {
        DocumentSnapshot studentDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(studentId)
            .get();

        if (studentDoc.exists) {
          setState(() {
            studentName =
                "${studentDoc['firstName'] ?? 'Unknown'} ${studentDoc['lastName'] ?? ''}".trim();
            if (studentName.isEmpty) studentName = "Unknown Student";
          });
        }
      }

      if (timestamp != null) {
        DateTime date = timestamp.toDate();
        setState(() {
          postTimestamp = "${date.day}-${date.month}-${date.year} ${date.hour}:${date.minute}";
        });
      }
    } catch (e) {
      print("Error fetching student details: $e");
    }
  }
  Future<void> fetchUserRoleAndNavigate(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (kDebugMode) {
          print("No user logged in.");
        }
        return;
      }

      DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (!userSnapshot.exists) {
        if (kDebugMode) {
          print("User data not found.");
        }
        return;
      }

      final userData = userSnapshot.data() as Map<String, dynamic>? ?? {};
      List<dynamic> roles = List.from(userData['role'] ?? []);

      if (roles.isNotEmpty) {
        String userRole = roles.first.toString(); // Convert to string
        navigateToFeed(context, userRole);
      } else {
        if (kDebugMode) {
          print("No role assigned to user.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user role: $e");
      }
    }
  }
  void navigateToFeed(BuildContext context, String role) {
    if (role == "student") {
      Navigator.pushReplacementNamed(context, 'stu_feed');
    } else if (role == "teacher") {
      Navigator.pushReplacementNamed(context, 'feed');
    } else {
      if (kDebugMode) {
        print("Unknown role: $role");
      }
    }
  }
  void openSidebar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.65,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  offset: Offset(-2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  color: Colors.lightBlue.shade50,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.blue),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    children: [
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.blueAccent),
                        title: const Text("Logout"),
                        onTap: () {
                          Navigator.pushReplacementNamed(context, 'login');
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: Image.asset(
                          'lib/icons/settings_selected.png',
                          width: 24,
                          height: 24,
                        ),
                        title: const Text("Settings"),
                        onTap: () {
                          Navigator.pushReplacementNamed(context, 'settings');
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: Image.asset('lib/icons/sidebar_feedback.png', height: 24, width: 24),
                        title: const Text("Feedback"),
                        onTap: () {
                          Navigator.pushReplacementNamed(context, 'feedback');
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.info, color: Colors.blue),
                        title: const Text("About"),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> applyForPost() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You need to be logged in to apply')),
        );
        return;
      }

      // Get current user data to include in application
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User profile not found')),
        );
        return;
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String message = _messageController.text.trim();

      if (message.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a message.")),
        );
        return;
      }

      // Create application document
      await FirebaseFirestore.instance.collection('applications').add({
        'postId': widget.postId,
        'teacherId': user.uid,
        'teacherName': '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim().isEmpty ? 'Unknown Teacher' : '${userData['firstName']} ${userData['lastName']}',
        'teacherEmail': user.email,
        'teacherPhone': userData['phoneNumber'] ?? 'No phone provided',
        'studentId': widget.postData['userId'] ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending', // pending, accepted, rejected
        'message': message,
        'postDetails': {
          'title': widget.postData['title'] ?? '',
          'subject': widget.postData['subject'] ?? '',
          'grade': widget.postData['grade'] ?? '',
          'area': widget.postData['area'] ?? '',
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted successfully!')),
      );
      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to apply. Please try again later.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false, // Disable the back button
          toolbarHeight: kToolbarHeight,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/icons/banner_top.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'lib/icons/logo.png', // Replace with your logo image
                height: 40,
              ),
              //const SizedBox(width: 10),
            ],
          ),
          actions: [
            IconButton(
              icon: Image.asset(
                'lib/icons/profile.png',
                width: 24,
                height: 24,
              ),
              onPressed: () {
                // Navigate to ProfilePage wrapped with Provider
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ),
                );
              },
            ),
            IconButton(
              icon: Image.asset(
                'lib/icons/sidebar.png',
                width: 24,
                height: 24,
              ),
              onPressed: openSidebar,
            ),
          ]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display student name and timestamp
            Text("Posted by: $studentName",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("Posted on: $postTimestamp",
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 10),
            Text(widget.postData['description'] ?? 'No Description',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("Subject: ${widget.postData['subject'] ?? 'Unknown'}"),
            Text("Grade: ${widget.postData['grade'] ?? 'Unknown'}"),
            Text("Area: ${widget.postData['area'] ?? 'Unknown'}"),
            Text("Gender: ${widget.postData['gender'] ?? 'Unknown'}"),
            const SizedBox(height: 20),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Enter your message",
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: applyForPost,
                child: const Text("Apply"),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Consistent alignment
        currentIndex: selectedIndex == -1 ? 0 : selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index; // Update the selected index
          });

          if (index == 0) {
            fetchUserRoleAndNavigate(context);
          } else if (index == 1) {
            // Navigate to Messages screen (replace with your messages screen route)
            Navigator.pushReplacementNamed(context, 'message');
          } else if (index == 2) {
            // Navigate to Notifications screen
            Navigator.pushReplacementNamed(context, 'notifications');
          } else if (index == 3) {
            // Navigate to Settings screen
            Navigator.pushReplacementNamed(context, 'settings');
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              selectedIndex == 0
                  ? 'lib/icons/home_selected.png' // Icon when selected
                  : 'lib/icons/home_unselected.png', // Icon when unselected
              width: 24,
              height: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              selectedIndex == 1
                  ? 'lib/icons/message_selected.png'
                  : 'lib/icons/message_unselected.png',
              width: 24,
              height: 24,
            ),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              selectedIndex == 2
                  ? 'lib/icons/notif_selected.png'
                  : 'lib/icons/notif_unselected.png',
              width: 24,
              height: 24,
            ),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              selectedIndex == 3
                  ? 'lib/icons/settings_selected.png'
                  : 'lib/icons/settings_unselected.png',
              width: 24,
              height: 24,
            ),
            label: 'Settings',
          ),
        ],
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
}
