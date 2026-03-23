import 'package:shared_preferences/shared_preferences.dart';

/// Centralized local storage for Sahyog authentication.
class AuthLocalStorage {
  // --- STORAGE KEYS ---
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';
  static const String _userNameKey = 'user_name';

  AuthLocalStorage._(); // Private constructor

  // ================= SAVE DATA METHODS =================

  /// Save auth data. Handles ID as dynamic to support both String and Int from APIs.
  static Future<void> saveAuthData({
    required String token,
    required dynamic id, // Dynamic to handle int or string from different APIs
    String? role,
    String? name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    
    // Safety: Convert ID to string before saving to SharedPreferences
    if (id != null) {
      await prefs.setString(_userIdKey, id.toString());
    }
    
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
    final token = prefs.getString(_tokenKey);
    // Returns null if empty or missing
    return (token != null && token.trim().isNotEmpty) ? token : null;
  }

  /// HELPER: Returns the full Authorization Header Map for Dio/HTTP calls.
  static Future<Map<String, String>> getAuthHeader() async {
    final token = await getToken();
    return {
      'Authorization': 'Bearer ${token ?? ""}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  /// Returns User ID as a String. 
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
    return token != null;
  }

  /// Quick check for role-based UI rendering.
  static Future<bool> isWarden() async {
    final role = (await getUserRole())?.toLowerCase();
    // Supporting manager role as well for Sahyog hierarchy
    return role == 'warden' || role == 'manager';
  }

  /// Specific check for Parent role (Useful for your current Parent View integration)
  static Future<bool> isParent() async {
    final role = (await getUserRole())?.toLowerCase();
    return role == 'parent' || role == 'guardian';
  }

  /// Safe Logout: Removes credentials but keeps app settings.
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userNameKey);
  }

  /// Total Reset: Use for debugging or factory reset logic.
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}