import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SettingsController {
  // Name editing logic
  static Future<void> editName(BuildContext context) async {
    _showEditDialog(
      context,
      "Edit Name",
      "Enter your new name",
          (newName) {
        if (newName != null && newName.isNotEmpty) {
          // Add logic to save the new name (e.g., API call, local database, etc.)
          if (kDebugMode) {
            print("Name updated to: $newName");
          }
          _showSuccessSnackbar(context, "Name updated successfully!");
        }
      },
    );
  }

  // Password editing logic
  static Future<void> editPassword(BuildContext context) async {
    _showEditDialog(
      context,
      "Edit Password",
      "Enter your new password",
          (newPassword) {
        if (newPassword != null && newPassword.isNotEmpty) {
          // Add logic to save the new password
          if (kDebugMode) {
            print("Password updated to: $newPassword");
          }
          _showSuccessSnackbar(context, "Password updated successfully!");
        }
      },
    );
  }

  // Phone number editing logic
  static Future<void> editPhoneNumber(BuildContext context) async {
    _showEditDialog(
      context,
      "Edit Phone Number",
      "Enter your new phone number",
          (newPhoneNumber) {
        if (newPhoneNumber != null && newPhoneNumber.isNotEmpty) {
          // Add logic to save the new phone number
          if (kDebugMode) {
            print("Phone number updated to: $newPhoneNumber");
          }
          _showSuccessSnackbar(context, "Phone number updated successfully!");
        }
      },
    );
  }

  // Address editing logic
  static Future<void> editAddress(BuildContext context) async {
    _showEditDialog(
      context,
      "Edit Address",
      "Enter your new address",
          (newAddress) {
        if (newAddress != null && newAddress.isNotEmpty) {
          // Add logic to save the new address
          if (kDebugMode) {
            print("Address updated to: $newAddress");
          }
          _showSuccessSnackbar(context, "Address updated successfully!");
        }
      },
    );
  }
  static Future<void> editEducation(BuildContext context) async {
    _showEditDialog(
      context,
      "Edit Education",
      "Enter your education level",
          (newEducation) {
        if (newEducation != null && newEducation.isNotEmpty) {
          // Add logic to save the new address
          if (kDebugMode) {
            print("Address updated to: $newEducation");
          }
          _showSuccessSnackbar(context, "Education updated successfully!");
        }
      },
    );
  }

  // Helper method to show an edit dialog
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

  // Helper method to show a success message
  static void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }
}
