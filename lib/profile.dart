import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'profileC.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfileController(),
      child: const ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
            icon: Image.asset('lib/icons/profile_selected.png', width: 24, height: 24),
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: ProfileController().userProfileStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
            return const Center(child: Text("No profile data found."));
          }
          var userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Profile",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[900],
                  ),
                ),
                const SizedBox(height: 5),
                Image.asset(
                  'lib/icons/profile.png',
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 10),
                Text(
                  "username: ${userData['username'] ?? 'Unknown User'}",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                _buildInfoBox(
                  "Name",
                    "${userData['firstName'] ?? 'N/A'} ${userData['lastName'] ?? ''}",
                ),

                const SizedBox(height: 10),
                _buildInfoBox(
                  "Account Type",
                  (userData['role'] is List)
                      ? (userData['role'] as List).join(', ')
                      : userData['role'] ?? 'N/A',
                ),
                const SizedBox(height: 10),
                _buildInfoBox("Bio", userData['description'] ?? 'N/A'),
                const SizedBox(height: 10),
                _buildInfoBox("Phone Number", userData['phoneNumber'] ?? 'N/A'),
                const SizedBox(height: 10),
                _buildInfoBox("Address", userData['address'] ?? 'N/A'),
                const SizedBox(height: 10),
                _buildInfoBox("Education", userData['education'] ?? 'N/A'),
              ],
            ),
          );
        },
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
  Widget _buildInfoBox(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87)),
        ],
      ),
    );
  }
}
