import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider with ChangeNotifier {
  String? _userId;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;

  // Getters
  String? get userId => _userId;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  // Initialize the provider
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _userId = user.uid;
        await _loadProfile();
      }
    } catch (e) {
      debugPrint('Error initializing user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user profile from Firestore
  Future<void> _loadProfile() async {
    if (_userId == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get();
      
      if (doc.exists) {
        _userProfile = doc.data();
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  // Update user profile
  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_userId == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .set(data, SetOptions(merge: true));

      await _loadProfile(); // Refresh local profile
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      _userId = null;
      _userProfile = null;
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    } finally {
      notifyListeners();
    }
  }
}