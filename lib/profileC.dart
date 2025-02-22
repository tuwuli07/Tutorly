import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<DocumentSnapshot> get userProfileStream {
    User? user = _auth.currentUser;
    if (user != null) {
      return _firestore.collection("Users").doc(user.uid).snapshots();
    } else {
      return const Stream.empty();
    }
  }
}
