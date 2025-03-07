import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'profile.dart';
import 'chat_screen.dart';

class DetailsPage extends StatefulWidget {
  final Map<String, dynamic> postData;
  final String postId;
  const DetailsPage({required this.postData, required this.postId, super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  String studentName = "Unknown Student";
  String postTimestamp = "Unknown Time";
  bool hasApplied = false;
  String chatId = "";
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    fetchStudentNameAndTimestamp();
    checkIfApplied();
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
  Future<void> checkIfApplied() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String generatedChatId = "${widget.postData['userId']}_${user.uid}";

    var chatSnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(generatedChatId)
        .get();

    if (chatSnapshot.exists) {
      setState(() {
        hasApplied = true;
        chatId = generatedChatId;
      });
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
            width: MediaQuery
                .of(context)
                .size
                .width * 0.65,
            height: MediaQuery
                .of(context)
                .size
                .height,
            decoration: BoxDecoration(
              color: Theme
                  .of(context)
                  .brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
              boxShadow: const [
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
                  color: Theme
                      .of(context)
                      .brightness == Brightness.dark
                      ? Colors.grey.shade900
                      : Colors.lightBlue.shade50,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: Theme
                            .of(context)
                            .brightness == Brightness.dark
                            ? Colors.white
                            : Colors.blue),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    children: [
                      ListTile(
                        leading: Icon(Icons.logout,
                            color: Theme
                                .of(context)
                                .brightness == Brightness.dark
                                ? Colors.white
                                : Colors.blueAccent),
                        title: Text("Logout",
                            style: TextStyle(
                              color: Theme
                                  .of(context)
                                  .brightness ==
                                  Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            )),
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
                        title: Text("Settings",
                            style: TextStyle(
                              color: Theme
                                  .of(context)
                                  .brightness ==
                                  Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            )),
                        onTap: () {
                          Navigator.pushReplacementNamed(context, 'settings');
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: Image.asset(
                          'lib/icons/sidebar_feedback.png',
                          height: 24,
                          width: 24,
                        ),
                        title: Text("Feedback",
                            style: TextStyle(
                              color: Theme
                                  .of(context)
                                  .brightness ==
                                  Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            )),
                        onTap: () {
                          Navigator.pushReplacementNamed(context, 'feedback');
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: Icon(
                          Icons.dark_mode,
                          color: Theme
                              .of(context)
                              .iconTheme
                              .color,
                        ),
                        title: Text(
                          "Dark Mode",
                          style: TextStyle(
                            color: Theme
                                .of(context)
                                .brightness ==
                                Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        trailing: Switch(
                          value: Provider
                              .of<ThemeProvider>(context)
                              .themeMode ==
                              ThemeMode.dark,
                          onChanged: (value) {
                            Provider.of<ThemeProvider>(context, listen: false)
                                .toggleTheme();
                          },
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: Icon(Icons.info,
                            color: Theme
                                .of(context)
                                .brightness == Brightness.dark
                                ? Colors.white
                                : Colors.blue),
                        title: Text("About",
                            style: TextStyle(
                              color: Theme
                                  .of(context)
                                  .brightness ==
                                  Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            )),
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

      String generatedChatId = "${widget.postData['userId']}_${user.uid}";

      await FirebaseFirestore.instance.collection('chats').doc(generatedChatId).set({
        'chatId': generatedChatId,
        'postId': widget.postId,
        'studentId': widget.postData['userId'],
        'tutorId': user.uid,
        'studentName': studentName,
        'tutorName': '${userData['firstName']} ${userData['lastName']}'.trim(),
        'lastMessage': '',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Create application document
      await FirebaseFirestore.instance.collection('applications').add({
        'postId': widget.postId,
        'teacherId': user.uid,
        'teacherName': '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim().isEmpty ? 'Unknown Teacher' : '${userData['firstName']} ${userData['lastName']}',
        'teacherEmail': user.email,
        'teacherPhone': userData['phoneNumber'] ?? 'No phone provided',
        'studentId': widget.postData['userId'] ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
        'postDetails': {
          'title': widget.postData['title'] ?? '',
          'subject': widget.postData['subject'] ?? '',
          'version': widget.postData['version'] ?? '',
          'grade': widget.postData['grade'] ?? '',
          'area': widget.postData['area'] ?? '',
        }
      });
      setState(() {
        hasApplied = true;
        chatId = generatedChatId;
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
    final bool isDarkMode = Theme
        .of(context)
        .brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: kToolbarHeight,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        surfaceTintColor: isDarkMode ? Colors.black : Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              isDarkMode? 'lib/icons/appbar_logo_dark.png' : 'lib/icons/appbar_logo.png',
              height: 38,
            ),
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
              isDarkMode? 'lib/icons/sidebar.png': 'lib/icons/sidebar_selected.png',
              width: 24,
              height: 24,
            ),
            onPressed: openSidebar,
          ),
        ],
      ),
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
            hasApplied
                ? ListTile(
              leading: const Icon(Icons.person, size: 30),
              title: Text(studentName),
              trailing: IconButton(
                icon: const Icon(Icons.message, color: Colors.blue),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ChatScreen(chatData: {'chatId': chatId}),
                    ),
                  );
                },
              ),
            )
            : SizedBox(
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
        backgroundColor: isDarkMode? Colors.black: Colors.white,
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
