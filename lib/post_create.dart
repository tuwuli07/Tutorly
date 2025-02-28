import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'profile.dart';
import 'post_create_c.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final CreatePostController postController = CreatePostController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  int selectedIndex=-1;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
            Image.asset('lib/icons/logo.png', height: 40),
          ],
        ),
        actions: [
          IconButton(
            icon: Image.asset('lib/icons/profile.png', width: 24, height: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          IconButton(
            icon: Image.asset('lib/icons/sidebar.png', width: 24, height: 24),
            onPressed: openSidebar,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "Post Title"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: "Description"),
              maxLines: 3,
            ),
            SizedBox(height: 10),
            // Using Flexible instead of Expanded
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    buildFilterDropdown("Select Area", postController.areas, (value) {
                      setState(() => postController.selectedArea = value);
                    }),
                    buildFilterDropdown("Select Class", postController.grades, (value) {
                      setState(() => postController.selectedGrade = value);
                    }),
                    buildFilterDropdown("Select Version", postController.versions, (value) {
                      setState(() => postController.selectedVersion = value);
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: MultiSelectDialogField(
                        items: postController.subjects
                            .map((subject) => MultiSelectItem<String>(subject, subject))
                            .toList(),
                        title: const Text("Select Subjects"),
                        buttonText: const Text("Select Subjects"),
                        initialValue: postController.selectedSubjects, // Bind selected values
                        onConfirm: (values) {
                          setState(() => postController.selectedSubjects = values);
                        },
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                      ),
                    ),
                    buildFilterDropdown("Select Gender", postController.genders, (value) {
                      setState(() => postController.selectedGender = value);
                    }),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                // Call the method to create the post
                await postController.createPost(
                  titleController.text,
                  descriptionController.text,
                  context,
                );

                titleController.clear();
                descriptionController.clear();

                Navigator.of(context).pop();
              },
              child: Text("Create Post"),
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

  Widget buildFilterDropdown(String hint, List<String> options, ValueChanged<String?> onChanged) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration.collapsed(hintText: ''),
        hint: Text(hint),
        items: options.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}