import 'package:flutter/material.dart';

class ProfileController extends ChangeNotifier {
  String username = "XYZ";
  String accountType = "Account Type";
  String phoneNumber = "123-456-7890";
  String address = "123 Coffee St, Brewtown";
  String education = "Bachelor’s in CSE";
  String description = "Coffee enthusiast and Flutter developer.";

  ProfileController();
  @override
  void dispose() {
    // Dispose any resources here if needed, such as streams or controllers.
    super.dispose();
  }
}
