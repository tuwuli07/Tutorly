import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SettingsController {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static bool _nameSnackbarShown = false;

  static Future<void> editName(BuildContext context) async {
    TextEditingController firstNameController = TextEditingController();
    TextEditingController lastNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Name"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: "Enter First Name"),
              ),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: "Enter Last Name"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String newFirstName = firstNameController.text.trim();
                String newLastName = lastNameController.text.trim();

                if (newFirstName.isNotEmpty) {
                  await _updateFirestoreData(context, "firstName", newFirstName);
                }
                if (newLastName.isNotEmpty) {
                  await _updateFirestoreData(context, "lastName", newLastName);
                }

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
  static Future<void> editUsername(BuildContext context) async {
    _showEditDialog(
      context,
      "Edit Username",
      "Enter your new username",
          (newUsername) async {
        if (newUsername != null && newUsername.isNotEmpty) {
          await _updateFirestoreData(context, "username", newUsername);
        }
      },
    );
  }
  static Future<void> editBio(BuildContext context) async {
    _showEditDialog(
      context,
      "Edit Bio",
      "Enter your new bio",
          (newBio) async {
        if (newBio != null && newBio.isNotEmpty) {
          await _updateFirestoreData(context, "description", newBio);
        }
      },
    );
  }

  static Future<void> editPassword(BuildContext context) async {
    _showEditDialog(
      context,
      "Edit Password",
      "Enter your new password",
          (newPassword) async {
        if (newPassword != null && newPassword.isNotEmpty) {
          await _updatePassword(context, newPassword);
        }
      },
    );
  }

  static Future<void> editPhoneNumber(BuildContext context) async {
    _showEditDialog(
      context,
      "Edit Phone Number",
      "Enter your new phone number",
          (newPhoneNumber) async {
        if (newPhoneNumber != null && newPhoneNumber.isNotEmpty) {
          await _updateFirestoreData(context, "phoneNumber", newPhoneNumber);
        }
      },
    );
  }

  static Future<void> editAddress(BuildContext context) async {
    _showEditDialog(
      context,
      "Edit Address",
      "Enter your new address",
          (newAddress) async {
        if (newAddress != null && newAddress.isNotEmpty) {
          await _updateFirestoreData(context, "address", newAddress);
        }
      },
    );
  }

  static Future<void> editEducation(BuildContext context) async {
    _showEditDialog(
      context,
      "Edit Education",
      "Enter your education level",
          (newEducation) async {
        if (newEducation != null && newEducation.isNotEmpty) {
          await _updateFirestoreData(context, "education", newEducation);
        }
      },
    );
  }

  static Future<void> _updateFirestoreData(BuildContext context, String field, String value) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String userId = user.uid;
        DocumentReference userDocRef = _firestore.collection("users").doc(userId);

        // Fetch user roles
        DocumentSnapshot userSnapshot = await userDocRef.get();
        if (!userSnapshot.exists) {
          throw Exception("User document does not exist");
        }
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>? ?? {};
        List<dynamic> roles = List.from(userData['role'] ?? []);

        // Update "users" collection
        await userDocRef.update({field: value});
        for (String role in roles) {
          if (role == "teacher") {
            await _firestore.collection("teachers").doc(userId).update({field: value});
          } else if (role == "student") {
            await _firestore.collection("students").doc(userId).update({field: value});
          }
        }
        if (context.mounted) {
          if (field == "firstName" || field == "lastName") {
            if (!_nameSnackbarShown) {
              _nameSnackbarShown = true;
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text("Name updated successfully!"), backgroundColor: Colors.green),
              );
            }
          } else {
            scaffoldMessenger.showSnackBar(
              SnackBar(content: Text("$field updated successfully!"), backgroundColor: Colors.green),
            );
          }
        }
      } else {
        if (context.mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text("User not logged in."), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text("Failed to update $field: $e"), backgroundColor: Colors.red),
        );
      }
      if (kDebugMode) {
        print("Error updating $field: $e");
      }
    }
  }

  static Future<void> _updatePassword(BuildContext context, String newPassword) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);

        if (context.mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text("Password updated successfully!"), backgroundColor: Colors.green),
          );
        }
      } else {
        if (context.mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text("User not logged in."), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text("Failed to update password: $e"), backgroundColor: Colors.red),
        );
      }
      if (kDebugMode) {
        print("Error updating password: $e");
      }
    }
  }

  static void _showEditDialog(
      BuildContext context,
      String title,
      String hintText,
      void Function(String? value) onSave,
      ) {
    TextEditingController controller = TextEditingController();

    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: hintText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                onSave(controller.text);
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
