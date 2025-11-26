import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;

  // Initialize auth state from saved data
  Future<void> initializeAuth() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId != null) {
        // Load user from database
        final db = await DatabaseHelper.instance.database;
        final users = await db.query(
          'users',
          where: 'id = ?',
          whereArgs: [userId],
        );

        if (users.isNotEmpty) {
          _currentUser = User.fromMap(users.first);
        }
      }

      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String role = 'customer',
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final db = await DatabaseHelper.instance.database;

      // Check if email already exists (case-insensitive)
      final normalizedEmail = email.toLowerCase();
      final existing = await db.query(
        'users',
        where: 'LOWER(email) = ?',
        whereArgs: [normalizedEmail],
      );

      if (existing.isNotEmpty) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create new user
      final user = User(
        name: name,
        email: normalizedEmail,
        password: password, // In production, hash this!
        phone: phone,
        role: role,
        createdAt: DateTime.now(),
      );

      final id = await db.insert('users', user.toMap());
      _currentUser = user.copyWith(id: id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final db = await DatabaseHelper.instance.database;
      final normalizedEmail = email.toLowerCase();
      final result = await db.query(
        'users',
        where: 'LOWER(email) = ? AND password = ?',
        whereArgs: [normalizedEmail, password],
      );

      if (result.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = User.fromMap(result.first);

      // Save user ID to SharedPreferences for persistent login
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', _currentUser!.id!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    
    // Clear saved login data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    
    notifyListeners();
  }

  // Update user profile
  Future<bool> updateProfile({
    required int userId,
    required String name,
    required String phone,
    String? newPassword,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final db = await DatabaseHelper.instance.database;
      
      final updateData = <String, dynamic>{
        'name': name,
        'phone': phone,
      };
      
      if (newPassword != null && newPassword.isNotEmpty) {
        updateData['password'] = newPassword;
      }

      await db.update(
        'users',
        updateData,
        where: 'id = ?',
        whereArgs: [userId],
      );

      // Reload user data
      final users = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (users.isNotEmpty) {
        _currentUser = User.fromMap(users.first);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

extension UserCopy on User {
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? phone,
    String? role,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
