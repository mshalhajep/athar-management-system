import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final bool isGoogleAuth;
  final String? lastBackupDate;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.isGoogleAuth = false,
    this.lastBackupDate,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    bool? isGoogleAuth,
    String? lastBackupDate,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isGoogleAuth: isGoogleAuth ?? this.isGoogleAuth,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'isGoogleAuth': isGoogleAuth,
      'lastBackupDate': lastBackupDate,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String? ?? 'guest-id',
      name: map['name'] as String? ?? 'مستخدم أثر',
      email: map['email'] as String? ?? 'user@athar.com',
      photoUrl: map['photoUrl'] as String?,
      isGoogleAuth: map['isGoogleAuth'] as bool? ?? false,
      lastBackupDate: map['lastBackupDate'] as String?,
    );
  }
}

class AuthService extends ChangeNotifier {
  static const String _userStorageKey = 'athar_user_session_v1';

  UserModel? _currentUser;
  bool _isLoading = true;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  AuthService() {
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_userStorageKey);
      if (raw != null && raw.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(raw) as Map<String, dynamic>;
        _currentUser = UserModel.fromJson(map);
      }
    } catch (e) {
      debugPrint('Error loading user session: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle({String? customEmail, String? customName}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate/perform Google Account linking
      await Future.delayed(const Duration(milliseconds: 700));

      final email = customEmail ?? 'athar.admin@gmail.com';
      final name = customName ?? 'إدارة مخزون أثر';

      _currentUser = UserModel(
        id: 'google_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        photoUrl: 'https://lh3.googleusercontent.com/a/default-user',
        isGoogleAuth: true,
        lastBackupDate: DateTime.now().toIso8601String(),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userStorageKey, jsonEncode(_currentUser!.toJson()));

      return true;
    } catch (e) {
      debugPrint('Sign in error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> continueAsGuest() async {
    _currentUser = const UserModel(
      id: 'guest_user',
      name: 'مستخدم محلي (ضيف)',
      email: 'local@device',
      isGoogleAuth: false,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userStorageKey, jsonEncode(_currentUser!.toJson()));
    notifyListeners();
  }

  Future<void> updateLastBackup(String dateStr) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(lastBackupDate: dateStr);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userStorageKey, jsonEncode(_currentUser!.toJson()));
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userStorageKey);
    notifyListeners();
  }
}
