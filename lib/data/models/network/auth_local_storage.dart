// File: auth_local_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized local storage for authentication-related values.
/// Keeps API surface minimal and stable so other APIs remain unaffected.
class AuthLocalStorage {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';

  AuthLocalStorage._(); // prevent instantiation

  // --- SAVE DATA ---

  /// Save token and user id (and optional role) after successful login.
  /// Stores values as strings to keep compatibility with existing code.
  static Future<void> saveAuthData({
    required String token,
    required String id,
    String? role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, id);
    if (role != null) {
      await prefs.setString(_userRoleKey, role);
    }
  }

  /// Save only token (useful for token refresh flows).
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Save only user id (if needed separately).
  static Future<void> saveUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, id);
  }

  // --- GETTERS ---

  /// Returns stored Bearer token or null if not present.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Returns stored user id as string or null if not present.
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Returns stored user role (e.g., "student", "warden") or null.
  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  // --- UTILITIES ---

  /// Quick check whether a valid session exists.
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Clears only auth-related keys (safer than prefs.clear()).
  /// Use this on logout to avoid disturbing other stored app data.
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userRoleKey);
  }

  /// Completely clears all SharedPreferences (use with caution).
  /// Provided for completeness but not used by default to avoid disturbing other APIs.
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
