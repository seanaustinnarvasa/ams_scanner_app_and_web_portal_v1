import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  User? _user;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider() {
    _auth.authStateChanges().listen((user) async {
      _user = user;
      if (user != null) {
        await _loadUserProfile(user.uid);
      } else {
        _userProfile = null;
      }
      _errorMessage = null;
      notifyListeners();
    });
  }

  User? get user => _user;
  UserProfile? get userProfile => _userProfile;
  String? get userRole => _userProfile?.role;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _loadUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        _userProfile = UserProfile.fromFirestore(doc);
      } else {
        _userProfile = UserProfile(
          id: uid,
          email: _user?.email ?? '',
          role: 'user',
          createdAt: DateTime.now(),
        );
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _userProfile = null;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _errorMessage = 'Unable to Login. ${e.message}';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Unable to Login. ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
    String userRole = 'user',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _userProfile = null;
    notifyListeners();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        final profile = UserProfile(
          id: credential.user!.uid,
          email: email,
          role: userRole,
          createdAt: DateTime.now(),
        );
        await _db.collection('users').doc(credential.user!.uid).set(profile.toFirestore());
        _userProfile = profile;
      }
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
