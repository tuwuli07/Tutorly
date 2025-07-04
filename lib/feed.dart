import 'package:flutter/material.dart';
import 'main.dart';
import 'package:provider/provider.dart';
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

  String formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return "${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime
          .hour}:${dateTime.minute}";
    }
    return "Invalid Date";
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme
        .of(context)
        .brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Find Tuitions',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white
                        : Colors.indigo.shade900,
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
                      showFilters = !showFilters;
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
                color: isDarkMode ? Colors.grey
                    .shade900
                    : Colors.lightBlue.shade50,
                // Background color for the filter tray
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
                            color: isDarkMode
                                ? Colors.grey
                                .shade800 // Dark gray for filter boxes
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: feedController.selectedArea,
                            hint: Row(
                              children: [
                                SizedBox(width: 5),
                                Text('Select Area',
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors
                                        .black,
                                  ),
                                )
                              ],
                            ),
                            icon: Image.asset(
                              'lib/icons/dropdown.png',
                              height: 10,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                            decoration:
                            const InputDecoration.collapsed(hintText: ''),
                            items: feedController.areas.map((area) {
                              return DropdownMenuItem(
                                value: area,
                                child: Text(area,
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors
                                        .black,
                                  ),
                                ),
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
                            color: isDarkMode
                                ? Colors.grey.shade800
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: feedController.selectedGrade,
                            hint: Row(
                              children: [
                                const SizedBox(width: 5),
                                Text('Select Class',
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors
                                        .black,
                                  ),
                                ),
                              ],
                            ),
                            icon: Image.asset(
                              'lib/icons/dropdown.png',
                              height: 10,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                            decoration:
                            const InputDecoration.collapsed(hintText: ''),
                            items: feedController.grades.map((grade) {
                              return DropdownMenuItem(
                                value: grade,
                                child: Text(grade,
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors
                                        .black,
                                  ),
                                ),
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
                            color: isDarkMode ? Colors.grey.shade800 : Colors
                                .white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: isDarkMode ? Colors.grey
                                        .shade900 : Colors.white,
                                    title: Text('Select Subjects',
                                      style: TextStyle(
                                        color: isDarkMode ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    content: StatefulBuilder(
                                      builder: (context, setDialogState) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: feedController.subjects
                                              .map((subject) {
                                            return CheckboxListTile(
                                              title: Text(subject,
                                                style: TextStyle(
                                                  color: isDarkMode ? Colors
                                                      .white : Colors.black,
                                                ),
                                              ),
                                              value: feedController
                                                  .selectedSubjects.contains(
                                                  subject),
                                              onChanged: (bool? selected) {
                                                setDialogState(() {
                                                  if (selected == true) {
                                                    feedController
                                                        .selectedSubjects.add(
                                                        subject);
                                                  } else {
                                                    feedController
                                                        .selectedSubjects
                                                        .remove(subject);
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
                                        child: Text('Cancel',
                                          style: TextStyle(
                                            color: isDarkMode ? Colors.grey
                                                .shade300 : Colors.blue,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {}); // Update UI after selection
                                          Navigator.pop(context);
                                        },
                                        child: Text('OK',
                                          style: TextStyle(
                                            color: isDarkMode ? Colors.grey
                                                .shade300 : Colors.blue,
                                          ),
                                        ),
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
                                        : feedController.selectedSubjects.join(
                                        ', '),
                                    style: TextStyle(fontSize: 16,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Image.asset(
                                  'lib/icons/dropdown.png',
                                  height: 10,
                                  color: isDarkMode ? Colors.white : Colors
                                      .black,
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
                          color: isDarkMode ? Colors.grey[800] : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: feedController.selectedGender,
                            hint: Row(
                              children: [
                                SizedBox(width: 5),
                                Text('Select Gender',
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            icon: Image.asset(
                              'lib/icons/dropdown.png',
                              height: 10,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                            decoration:
                            const InputDecoration.collapsed(hintText: ''),
                            items: feedController.genders.map((gender) {
                              return DropdownMenuItem(
                                value: gender,
                                child: Text(gender,
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                ),
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
                            color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: feedController.selectedVersion,
                            hint: Row(
                              children: [
                                SizedBox(width: 5),
                                Text('Select Version/Medium',
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            icon: Image.asset(
                              'lib/icons/dropdown.png',
                              height: 10,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                            decoration:
                            const InputDecoration.collapsed(hintText: ''),
                            items: feedController.versions.map((version) {
                              return DropdownMenuItem(
                                value: version,
                                child: Text(version,
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                ),
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
                          backgroundColor: Colors.redAccent,
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
                    Map<String, dynamic> data = doc.data() as Map<
                        String,
                        dynamic>;

                    bool areaMatch = feedController.selectedArea == null ||
                        data['area'] == feedController.selectedArea;

                    bool gradeMatch = feedController.selectedGrade == null ||
                        data['grade'] == feedController.selectedGrade;
                    bool subjectMatch = feedController.selectedSubjects
                        .isEmpty ||
                        (data['subject'] is List
                            ? (data['subject'] as List).any((subject) =>
                            feedController.selectedSubjects.contains(
                                subject.toString()))
                            : feedController.selectedSubjects.contains(
                            data['subject']?.toString() ?? ""));
                    bool genderMatch = feedController.selectedGender == null ||
                        data['gender'] == feedController.selectedGender ||
                        data['gender'] == 'Any';

                    bool versionMatch = feedController.selectedVersion ==
                        null ||
                        data['version'] == feedController.selectedVersion;

                    return areaMatch && gradeMatch && subjectMatch &&
                        genderMatch && versionMatch;
                  }).toList();
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
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
                      color: Theme
                          .of(context)
                          .brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.lightBlue.shade50,
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
                                  radius: 10,
                                  backgroundColor: Colors.blue.shade100,
                                  child: const Icon(
                                      Icons.person, color: Colors.white,
                                      size: 18),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      Text(
                                        postData['creatorName'] ?? 'Unknown',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        postData['timestamp'] != null
                                            ? formatTimestamp(
                                            postData['timestamp'])
                                            : 'Unknown Time',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
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
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 5),

                            Expanded(
                              child: Text(
                                postData['description'] ?? 'No Description',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Theme
                                        .of(context)
                                        .brightness == Brightness.dark
                                        ? Colors.grey.shade300
                                        : Colors.black54
                                ),
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
                                  if (usedWidth + chipWidth + moreChipWidth >
                                      availableWidth) {
                                    hiddenCount++;
                                  } else {
                                    visibleChips.add(chip);
                                    usedWidth += chipWidth + chipSpacing;
                                  }
                                }

                                if (postData['subject'] is List) {
                                  List<String> subjects = List<String>.from(
                                      postData['subject']);
                                  if (subjects.isNotEmpty) {
                                    addChip(
                                      _buildInfoChip(subjects.first,
                                          Colors.orange.shade100),
                                      subjects.first.length * 1.0,
                                    );
                                  }
                                  if (subjects.length > 1) {
                                    hiddenCount += subjects.length - 1;
                                  }
                                }

                                // Other chips
                                final List<MapEntry<String, Color>> chipData = [
                                  MapEntry(postData['grade'] ?? 'Grade',
                                      isDarkMode
                                          ? Colors.green.shade300
                                          : Colors.green.shade100),
                                  MapEntry(postData['version'] ?? 'Version',
                                      isDarkMode ? Colors.teal.shade300 : Colors
                                          .teal.shade200),
                                  MapEntry(postData['area'] ?? 'Area',
                                      isDarkMode ? Colors.blue.shade300 : Colors.blue.shade100),
                                  MapEntry(postData['gender'] ?? 'Gender',
                                      isDarkMode ? Colors.purple.shade300 : Colors.purple.shade100),
                                ];

                                for (var entry in chipData) {
                                  addChip(
                                      _buildInfoChip(entry.key, entry.value),
                                      entry.key.length * 2.0);
                                }

                                // Add "+X more" chip if any were hidden
                                if (hiddenCount > 0) {
                                  visibleChips.add(_buildInfoChip(
                                      "+$hiddenCount more", isDarkMode
                                      ? Colors.orange.shade300
                                      : Colors.orange
                                      .shade100));
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
                                      builder: (context) =>
                                          DetailsPage(postData: postData,
                                              postId: doc.id),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
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
        backgroundColor: isDarkMode? Colors.black: Colors.white,
        type: BottomNavigationBarType.fixed,
        // Consistent alignment
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
        style: const TextStyle(
          fontSize: 10,
          color: Colors.black, // Sets the text color to black
        ),
      ),
    );
  }
}