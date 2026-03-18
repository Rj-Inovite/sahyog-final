import 'package:shared_preferences/shared_preferences.dart';

/// Centralized local storage for Sahyog authentication.
/// Purely functional: Stores and retrieves credentials without affecting other logic.
class AuthLocalStorage {
  // --- STORAGE KEYS ---
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';
  static const String _userNameKey = 'user_name'; 

  // Private constructor to prevent instantiation
  AuthLocalStorage._(); 

  // ================= SAVE DATA METHODS =================

  /// Save token, user id, and optional role/name after successful login.
  static Future<void> saveAuthData({
    required String token,
    required String id,
    String? role,
    String? name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, id);
    if (role != null) await prefs.setString(_userRoleKey, role);
    if (name != null) await prefs.setString(_userNameKey, name);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // ================= GETTER METHODS =================

  /// Returns stored Bearer token.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// HELPER: Returns the full Authorization Header Map.
  /// Use this in your Dio/HTTP calls to keep code clean.
  static Future<Map<String, String>> getAuthHeader() async {
    final token = await getToken();
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  // ================= UTILITY METHODS =================

  /// Decides whether to show Login or Dashboard on App Start.
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Safe Logout: Removes credentials but keeps app settings (like theme).
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userNameKey);
  }

  /// Total Reset: Use with caution.
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}