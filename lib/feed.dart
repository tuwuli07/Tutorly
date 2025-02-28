import 'package:flutter/material.dart';
import 'feedC.dart';
import 'profile.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'details.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final FeedController feedController = FeedController();
  bool showFilters = false;
  int selectedIndex = 0;
  Stream<QuerySnapshot>? _postsStream;

  @override
  void initState() {
    super.initState();
    feedController.initFilters();
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
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  offset: Offset(-2, 0), // Shadow on the left
                ),
              ],
            ),
            child: Column(
              children: [
                // Back Button at the Top
                Container(
                  alignment: Alignment.centerLeft,
                  color: Colors.lightBlue.shade50,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.blue),
                    onPressed: () {
                      Navigator.pop(context); // Close the sidebar
                    },
                  ),
                ),
                // Sidebar Items
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
                        leading:
                        Image.asset('lib/icons/sidebar_feedback.png',
                          height: 24,
                          width: 24,
                        ),
                        title: const Text("Feedback"),
                        onTap: () {
                          Navigator.pushReplacementNamed(context, 'feedback');
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.info, color: Colors.blue),
                        title: const Text("About"),
                        onTap: () {
                          // Navigate to about
                        },
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

  String formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return "${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
    }
    return "Invalid Date";
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Find Tuition',
                  style: TextStyle(
                    color: Colors.indigo,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Image.asset(
                    'lib/icons/filter.png',
                    height: 40,
                  ),
                  onPressed: () {
                    setState(() {
                      showFilters = !showFilters; // Toggle filter tray
                    });
                  },
                ),
              ],
            ),
          ),
          if (showFilters)
            Container(
              margin:
              const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors
                    .lightBlue.shade50, // Background color for the filter tray
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey
                        .withOpacity(0.5),
                    spreadRadius: 0.5,
                    blurRadius: 5,
                    offset: const Offset(
                        0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: feedController.selectedArea,
                            hint: const Row(
                              children: [
                                SizedBox(width: 5),
                                Text('Select Area'),
                              ],
                            ),
                            icon: Image.asset(
                              'lib/icons/dropdown.png',
                              height: 10,
                            ),
                            decoration:
                            const InputDecoration.collapsed(hintText: ''),
                            items: feedController.areas.map((area) {
                              return DropdownMenuItem(
                                value: area,
                                child: Text(area),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                feedController.selectedArea = value;
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: feedController.selectedGrade,
                            hint: const Row(
                              children: [
                                SizedBox(width: 5),
                                Text('Select Class'),
                              ],
                            ),
                            icon: Image.asset(
                              'lib/icons/dropdown.png',
                              height: 10,
                            ),
                            decoration:
                            const InputDecoration.collapsed(hintText: ''),
                            items: feedController.grades.map((grade) {
                              return DropdownMenuItem(
                                value: grade,
                                child: Text(grade),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                feedController.selectedGrade = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Select Subjects'),
                                    content: StatefulBuilder(
                                      builder: (context, setDialogState) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: feedController.subjects.map((subject) {
                                            return CheckboxListTile(
                                              title: Text(subject),
                                              value: feedController.selectedSubjects.contains(subject),
                                              onChanged: (bool? selected) {
                                                setDialogState(() {
                                                  if (selected == true) {
                                                    feedController.selectedSubjects.add(subject);
                                                  } else {
                                                    feedController.selectedSubjects.remove(subject);
                                                  }
                                                });
                                              },
                                            );
                                          }).toList(),
                                        );
                                      },
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {}); // Update UI after selection
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    feedController.selectedSubjects.isEmpty
                                        ? 'Select Subjects'
                                        : feedController.selectedSubjects.join(', '),
                                    style: const TextStyle(fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Image.asset(
                                  'lib/icons/dropdown.png',
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: feedController.selectedGender,
                            hint: const Row(
                              children: [
                                SizedBox(width: 5),
                                Text('Select Gender'),
                              ],
                            ),
                            icon: Image.asset(
                              'lib/icons/dropdown.png',
                              height: 10,
                            ),
                            decoration:
                            const InputDecoration.collapsed(hintText: ''),
                            items: feedController.genders.map((gender) {
                              return DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                feedController.selectedGender = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: feedController.selectedVersion,
                            hint: const Row(
                              children: [
                                SizedBox(width: 5),
                                Text('Select Version/Medium'),
                              ],
                            ),
                            icon: Image.asset(
                              'lib/icons/dropdown.png',
                              height: 10,
                            ),
                            decoration:
                            const InputDecoration.collapsed(hintText: ''),
                            items: feedController.versions.map((version) {
                              return DropdownMenuItem(
                                value: version,
                                child: Text(version),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                feedController.selectedVersion = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            feedController.clearFilters();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          minimumSize:
                          const Size(70, 30),
                          textStyle:
                          const TextStyle(fontSize: 14),
                        ),
                        child: const Text('Clear Filters'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          // Tuition Posts Section
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
                          'No tuition posts available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Check back later for new opportunities',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                List<QueryDocumentSnapshot> filteredDocs = snapshot.data!.docs;
                if (feedController.selectedArea != null ||
                    feedController.selectedGrade != null ||
                    (feedController.selectedSubjects.isNotEmpty) ||
                    feedController.selectedGender != null ||
                  feedController.selectedVersion != null) {

                  filteredDocs = filteredDocs.where((doc) {
                    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

                    bool areaMatch = feedController.selectedArea == null ||
                        data['area'] == feedController.selectedArea;

                    bool gradeMatch = feedController.selectedGrade == null ||
                        data['grade'] == feedController.selectedGrade;
                    bool subjectMatch = feedController.selectedSubjects.isEmpty ||
                        (data['subject'] is List
                            ? (data['subject'] as List).any((subject) => feedController.selectedSubjects.contains(subject.toString()))
                            : feedController.selectedSubjects.contains(data['subject']?.toString() ?? ""));
                    bool genderMatch = feedController.selectedGender == null ||
                        data['gender'] == feedController.selectedGender ||
                        data['gender'] == 'Any';

                    bool versionMatch = feedController.selectedVersion == null ||
                        data['version'] == feedController.selectedVersion;

                    return areaMatch && gradeMatch && subjectMatch && genderMatch && versionMatch;
                  }).toList();
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2 / 3,
                  ),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    var doc = filteredDocs[index];
                    var postData = doc.data() as Map<String, dynamic>;

                    return Card(
                      color: Colors.lightBlue.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.blue.shade100,
                                  child: Icon(Icons.person, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 6),
                                Expanded( // Prevents overflow in Row
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        postData['creatorName'] ?? 'Unknown',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis, // Prevents text overflow
                                      ),
                                      Text(
                                        postData['timestamp'] != null
                                            ? formatTimestamp(postData['timestamp'])
                                            : 'Unknown Time',
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 5),

                            Text(
                              postData['title'] ?? 'No Title',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis, // Prevents overflow
                            ),

                            const SizedBox(height: 5),

                            Expanded(
                              child: Text(
                                postData['description'] ?? 'No Description',
                                style: const TextStyle(fontSize: 14, color: Colors.black54),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            const SizedBox(height: 8),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                double availableWidth = constraints.maxWidth;
                                double usedWidth = 0;
                                const double chipSpacing = 2;
                                const double moreChipWidth = 60;
                                List<Widget> visibleChips = [];
                                int hiddenCount = 0;

                                void addChip(Widget chip, double chipWidth) {
                                  if (usedWidth + chipWidth + moreChipWidth > availableWidth) {
                                    hiddenCount++;
                                  } else {
                                    visibleChips.add(chip);
                                    usedWidth += chipWidth + chipSpacing;
                                  }
                                }

                                if (postData['subject'] is List) {
                                  List<String> subjects = List<String>.from(postData['subject']);
                                  if (subjects.isNotEmpty) {
                                    addChip(
                                      _buildInfoChip(subjects.first, Colors.orange.shade100),
                                      subjects.first.length * 1.0,
                                    );
                                  }
                                  if (subjects.length > 1) {
                                    hiddenCount += subjects.length - 1;
                                  }
                                }

                                // Other chips
                                final List<MapEntry<String, Color>> chipData = [
                                  MapEntry(postData['grade'] ?? 'Grade', Colors.green.shade100),
                                  MapEntry(postData['version'] ?? 'Version', Colors.teal.shade100),
                                  MapEntry(postData['area'] ?? 'Area', Colors.blue.shade100),
                                  MapEntry(postData['gender'] ?? 'Gender', Colors.indigoAccent.shade100),
                                ];

                                for (var entry in chipData) {
                                  addChip(_buildInfoChip(entry.key, entry.value), entry.key.length * 2.0);
                                }

                                // Add "+X more" chip if any were hidden
                                if (hiddenCount > 0) {
                                  visibleChips.add(_buildInfoChip("+$hiddenCount more", Colors.orange.shade100));
                                }

                                return Wrap(
                                  spacing: 2,
                                  runSpacing: 4,
                                  children: visibleChips,
                                );
                              },
                            ),
                            const SizedBox(height: 15),
                            /// view details Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailsPage(postData: postData, postId: doc.id),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                                child: const Text('View Details'),
                              ),
                            ),
                          ],
                        ),

                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
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

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10),
      ),
    );
  }
}