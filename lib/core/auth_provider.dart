import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'firebase_service.dart';
import 'supabase_service.dart';
import 'models.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final SupabaseService _supabaseService = SupabaseService();

  AppUser? _user;
  Profile? _profile;
  bool _loading = true;
  String? _error;

  AppUser? get user => _user;
  Profile? get profile => _profile;
  bool get loading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _loading = true;
    notifyListeners();

    if (const bool.fromEnvironment('INTEGRATION_TEST', defaultValue: false)) {
      _user = null;
      _profile = null;
      _loading = false;
      notifyListeners();
      return;
    }

    await _firebaseService.init();
    await _supabaseService.init();

    _firebaseService.authStateChanges.listen((fb.User? user) async {
      _user = user != null ? AppUser(uid: user.uid, email: user.email) : null;
      if (user != null) {
        _profile = await _supabaseService.getProfile(user.uid);
      } else {
        _profile = null;
      }
      _loading = false;
      _error = null;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    if (const bool.fromEnvironment('INTEGRATION_TEST', defaultValue: false)) {
      await Future.delayed(const Duration(milliseconds: 200));
      _user = AppUser(uid: 'test-user-uid', email: email);
      _profile = Profile(
        id: 'test-user-uid',
        userId: 'test-user-uid',
        fullName: 'Test User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        jobTitle: 'Developer Ops',
      );
      _loading = false;
      notifyListeners();
      return true;
    }

    try {
      await _firebaseService.signInWithEmail(email, password);
      return true;
    } on fb.FirebaseAuthException catch (e) {
      _error = e.message ?? 'Prihlásenie zlyhalo.';
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Vyskytla sa neočakávaná chyba.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String fullName) async {
    _loading = true;
    _error = null;
    notifyListeners();

    if (const bool.fromEnvironment('INTEGRATION_TEST', defaultValue: false)) {
      await Future.delayed(const Duration(milliseconds: 200));
      _user = AppUser(uid: 'test-user-uid', email: email);
      _profile = Profile(
        id: 'test-user-uid',
        userId: 'test-user-uid',
        fullName: fullName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        jobTitle: 'Developer Ops',
      );
      _loading = false;
      notifyListeners();
      return true;
    }

    try {
      final credentials = await _firebaseService.signUpWithEmail(email, password);
      final uid = credentials.user?.uid;
      
      if (uid != null) {
        if (_supabaseService.isUuid(uid)) {
          // Create user profile in Supabase profiles table
          final now = DateTime.now();
          final newProfile = Profile(
            id: uid, // Use firebase UID
            userId: uid,
            fullName: fullName,
            createdAt: now,
            updatedAt: now,
          );
          
          await _supabaseService.client.from('profiles').insert(newProfile.toMap());
          _profile = newProfile;
        } else {
          print('Firebase UID is not a UUID ($uid); skipping profiles table insert.');
          _profile = null;
        }
      }
      
      return true;
    } on fb.FirebaseAuthException catch (e) {
      _error = e.message ?? 'Registrácia zlyhala.';
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Vyskytla sa neočakávaná chyba pri vytváraní profilu.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _loading = true;
    _error = null;
    notifyListeners();

    if (const bool.fromEnvironment('INTEGRATION_TEST', defaultValue: false)) {
      await Future.delayed(const Duration(milliseconds: 200));
      _user = AppUser(uid: 'test-user-uid', email: 'google-user@example.com');
      _profile = Profile(
        id: 'test-user-uid',
        userId: 'test-user-uid',
        fullName: 'Google Test User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        jobTitle: 'Google Auth Tester',
      );
      _loading = false;
      notifyListeners();
      return true;
    }

    try {
      final credential = await _firebaseService.signInWithGoogle();
      if (credential != null && credential.user != null) {
        final uid = credential.user!.uid;
        _profile = await _supabaseService.getProfile(uid);
        
        // If profile doesn't exist, create it
        if (_profile == null && _supabaseService.isUuid(uid)) {
          final now = DateTime.now();
          final newProfile = Profile(
            id: uid,
            userId: uid,
            fullName: credential.user!.displayName ?? 'Google User',
            avatarUrl: credential.user!.photoURL,
            createdAt: now,
            updatedAt: now,
          );
          await _supabaseService.client.from('profiles').insert(newProfile.toMap());
          _profile = newProfile;
        }
      }
      return true;
    } catch (e) {
      _error = 'Prihlásenie cez Google zlyhalo.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _loading = true;
    notifyListeners();

    if (const bool.fromEnvironment('INTEGRATION_TEST', defaultValue: false)) {
      _user = null;
      _profile = null;
      _loading = false;
      notifyListeners();
      return;
    }

    await _firebaseService.signOut();
    _user = null;
    _profile = null;
    _loading = false;
    notifyListeners();
  }

  Future<bool> updateUserProfile(String fullName, String jobTitle) async {
    if (_user == null) return false;

    if (const bool.fromEnvironment('INTEGRATION_TEST', defaultValue: false)) {
      _profile = Profile(
        id: _profile!.id,
        userId: _profile!.userId,
        fullName: fullName,
        jobTitle: jobTitle,
        avatarUrl: _profile!.avatarUrl,
        createdAt: _profile!.createdAt,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
      return true;
    }

    if (!_supabaseService.isUuid(_user!.uid)) {
      print('Firebase UID is not a UUID (${_user!.uid}); skipping profile update.');
      return false;
    }

    try {
      final updates = {
        'full_name': fullName,
        'job_title': jobTitle,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      await _supabaseService.client.from('profiles').update(updates).eq('user_id', _user!.uid);
      _profile = await _supabaseService.getProfile(_user!.uid);
      notifyListeners();
      return true;
    } catch (e) {
      print('Failed to update profile: $e');
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
