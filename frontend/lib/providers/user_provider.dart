import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? _userId;
  String? _userName;
  String? _userEmail;

  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;

  // This function saves the user data after a successful login
  void setUser(Map<String, dynamic> userData) {
    _userId = userData['_id']; // Maps to the _id from your authController.js
    _userName = userData['name'];
    _userEmail = userData['email'];
    notifyListeners(); // Tells the app to refresh with the new user data
  }

  void logout() {
    _userId = null;
    _userName = null;
    _userEmail = null;
    notifyListeners();
  }

  // ក្នុង UserProvider.dart
  void updateUserLocal(String newName, String newEmail) {
    _userName = newName;
    _userEmail = newEmail;
    notifyListeners();
  }
}
