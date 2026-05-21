import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';
import 'supabase_service.dart';
import 'models.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final SupabaseService _supabaseService = SupabaseService();

  User? _user;
  Profile? _profile;
  bool _loading = true;
  String? _error;

  User? get user => _user;
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

    await _firebaseService.init();
    await _supabaseService.init();

    _firebaseService.authStateChanges.listen((User? user) async {
      _user = user;
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
    try {
      await _firebaseService.signInWithEmail(email, password);
      return true;
    } on FirebaseAuthException catch (e) {
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
    try {
      final credentials = await _firebaseService.signUpWithEmail(email, password);
      final uid = credentials.user?.uid;
      
      if (uid != null) {
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
      }
      
      return true;
    } on FirebaseAuthException catch (e) {
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
    try {
      final credential = await _firebaseService.signInWithGoogle();
      if (credential != null && credential.user != null) {
        final uid = credential.user!.uid;
        _profile = await _supabaseService.getProfile(uid);
        
        // If profile doesn't exist, create it
        if (_profile == null) {
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
    await _firebaseService.signOut();
    _user = null;
    _profile = null;
    _loading = false;
    notifyListeners();
  }

  Future<bool> updateUserProfile(String fullName, String jobTitle) async {
    if (_user == null) return false;
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
