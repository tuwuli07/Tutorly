import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'feed_stuC.dart';
import 'main.dart';
import 'post_create.dart';
import 'profile.dart';

class FeedStu extends StatefulWidget {
  const FeedStu({super.key});

  @override
  State<FeedStu> createState() => _StuFeedScreenState();
}

class _StuFeedScreenState extends State<FeedStu> {
  final StuFeedController feedController = StuFeedController();
  int selectedIndex = 0;
  Stream<QuerySnapshot>? _postsStream;

  @override
  void initState() {
    super.initState();
    _postsStream = FirebaseFirestore.instance
        .collection('posts')
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

  @override
  void dispose() {
    feedController.dispose();
    super.dispose();
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
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
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
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade900
                      : Colors.lightBlue.shade50,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: Theme.of(context).brightness == Brightness.dark
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
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.blueAccent),
                        title: Text("Logout",
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
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
                              color: Theme.of(context).brightness ==
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
                              color: Theme.of(context).brightness ==
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
                          color: Theme.of(context).iconTheme.color,
                        ),
                        title: Text(
                          "Dark Mode",
                          style: TextStyle(
                            color: Theme.of(context).brightness ==
                                Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        trailing: Switch(
                          value: Provider.of<ThemeProvider>(context)
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
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.blue),
                        title: Text("About",
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
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

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFFF0F8FF),
      appBar: AppBar (
          automaticallyImplyLeading: false, // Disable the back button
          toolbarHeight: kToolbarHeight,
          backgroundColor: isDarkMode ? Colors.black : Colors.white,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'lib/icons/appbar_logo.png', // Replace with your logo image
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
                'lib/icons/sidebar_selected.png',
                width: 24,
                height: 24,
              ),
              onPressed: openSidebar,
            ),
          ]),
      body: Column(
        children: [
          // Post feed - main content
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _postsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 50, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No tutor posts available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try creating a new post to find tutors',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

                List<DocumentSnapshot> myPosts = [];
                List<DocumentSnapshot> otherPosts = [];

                for (var post in snapshot.data!.docs) {
                  var postData = post.data() as Map<String, dynamic>;
                  if (postData['userId'] == currentUserId) {
                    myPosts.add(post);
                  } else {
                    otherPosts.add(post);
                  }
                }
                return ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    if (myPosts.isNotEmpty) ...[
                      const Text(
                        "My Posts",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...myPosts.map((post) {
                        var postData = post.data() as Map<String, dynamic>;
                        return TutorPostCard(
                          title: postData['title'] ?? 'No Title',
                          description: postData['description'] ?? 'No Description',
                          area: postData['area'] ?? 'Unknown Area',
                          grade: postData['grade'] ?? 'Unknown Grade',
                          version: postData['version'] ?? 'Unknown Version',
                          subject: (postData['subject'] is List)
                              ? List<String>.from(postData['subject'].map((s) => s.toString()))
                              : (postData['subject'] is String)
                              ? [postData['subject']]
                              : ['Unknown Subject'],
                          gender: postData['gender'] ?? 'Any',
                          timestamp: postData['timestamp'],
                          creatorName: "You",
                        );
                      }).toList(),
                      const SizedBox(height: 16),
                    ],
                    if (otherPosts.isNotEmpty) ...[
                      const Text(
                        "Other's Posts",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...otherPosts.map((post) {
                        var postData = post.data() as Map<String, dynamic>;
                        return TutorPostCard(
                          title: postData['title'] ?? 'No Title',
                          description: postData['description'] ?? 'No Description',
                          area: postData['area'] ?? 'Unknown Area',
                          grade: postData['grade'] ?? 'Unknown Grade',
                          version: postData['version'] ?? 'Unknown Version',
                          subject: (postData['subject'] is List)
                              ? List<String>.from(postData['subject'].map((s) => s.toString()))
                              : (postData['subject'] is String)
                              ? [postData['subject']]
                              : ['Unknown Subject'],
                          gender: postData['gender'] ?? 'Any',
                          timestamp: postData['timestamp'],
                          creatorName: postData['creatorName'] ?? 'Unknown', // Add creator's name
                        );
                      }).toList(),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
      //backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostPage()),
          );
        },
        backgroundColor: Colors.blue.shade400,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Consistent alignment
        currentIndex: selectedIndex, // Track the selected index
        onTap: (index) {
          setState(() {
            selectedIndex = index; // Update the selected index
          });

          if (index == 0) {
            fetchUserRoleAndNavigate(context);
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, 'message');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, 'notifications');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, 'settings');
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              selectedIndex == 0
                  ? 'lib/icons/home_selected.png'
                  : 'lib/icons/home_unselected.png',
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

class TutorPostCard extends StatefulWidget {
  final String title;
  final String description;
  final String area;
  final String grade;
  final String version;
  final List<String> subject;
  final String gender;
  final dynamic timestamp;
  final String creatorName;

  const TutorPostCard({
    super.key,
    required this.title,
    required this.description,
    required this.area,
    required this.grade,
    required this.subject,
    required this.gender,
    required this.version,
    this.timestamp,
    required this.creatorName,
  });

  @override
  State<TutorPostCard> createState() => _TutorPostCardState();
}

class _TutorPostCardState extends State<TutorPostCard> {
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Just now';

    if (timestamp is Timestamp) {
      final DateTime dateTime = timestamp.toDate();
      final Duration difference = DateTime.now().difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    }

    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme
        .of(context)
        .brightness == Brightness.dark;
    return Card(
      color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.blue.shade100,
                  child: const Icon(
                    Icons.person, color: Colors.indigo, size: 20.0,),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.creatorName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            "Posted in ${widget.area}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Adding time display
                          Icon(Icons.access_time, size: 12,
                              color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimestamp(widget.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.title,
              style: const TextStyle(fontSize: 15,
                  fontWeight: FontWeight.bold),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              widget.description,
              style: const TextStyle(fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...widget.subject.map((subj) =>
                    _buildInfoChip(subj,
                        isDarkMode ? Colors.orange.shade300 : Colors.orange
                            .shade100)).toList(),
                _buildInfoChip(widget.grade,
                    isDarkMode ? Colors.green.shade300 : Colors.green.shade100),
                _buildInfoChip(widget.version,
                    isDarkMode ? Colors.teal.shade300 : Colors.teal.shade200),
                _buildInfoChip(widget.gender,
                    isDarkMode ? Colors.purple.shade300 : Colors.purple
                        .shade100),
              ],
            ),
            const SizedBox(height: 12),

          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, Color backgroundColor) {
    final bool isDarkMode = Theme
        .of(context)
        .brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isDarkMode
              ? Colors.black
              : null, // Color goes inside TextStyle
        ),
      ),
    );
  }
}