import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile.dart';
import 'chat_screen.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  int selectedIndex = 1;
  Stream<QuerySnapshot> getChatRooms() {
    return FirebaseFirestore.instance
        .collection('chats')
        .where(Filter.or(
          Filter('tutorId', isEqualTo: user?.uid),
          Filter('studentId', isEqualTo: user?.uid),
        ))
        .orderBy('timestamp', descending: true)
        .snapshots();
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

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.blue),
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
                        leading:
                            const Icon(Icons.logout, color: Colors.blueAccent),
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
                        leading: Image.asset('lib/icons/sidebar_feedback.png',
                            height: 24, width: 24),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Text(
              'Messages',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
          ),
          Expanded(child: StreamBuilder<QuerySnapshot>(
            stream: getChatRooms(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
          
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No messages yet"));
              }
              return ListView(
                children: snapshot.data!.docs.map((doc) {
                  var chatData = doc.data() as Map<String, dynamic>;
          
                  String chatPartnerName =
                  (user?.uid == chatData['studentId']) ? chatData['tutorName'] : chatData['studentName'];
                  String senderLabel = (chatData['lastMessageSenderId'] == user?.uid) ? "You"
                      : (chatData['lastMessageSenderId'] == chatData['studentId']) ? "Student"
                      : "Tutor";
                  DateTime timestamp;
                  if (chatData['timestamp'] != null) {
                    timestamp = chatData['timestamp'].toDate();
                  } else {
                    timestamp = DateTime.now();
                  }
                  String formattedTime = "${timestamp.month}/${timestamp.day} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(chatData: chatData),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Image.asset(
                              'lib/icons/profile.png',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  chatPartnerName,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    // Message Text (with overflow handling)
                                    Expanded(
                                      child: Text(
                                        "$senderLabel: ${chatData['lastMessage'] ?? 'Tap to chat'}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis, // Truncates the message text if it overflows
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                    ),
          
                                    // Timestamp (Always visible)
                                    Text(
                                        "· $formattedTime",
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Image.asset(
                              'lib/icons/right_arrow.png',
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex == -1 ? 3 : selectedIndex,
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
