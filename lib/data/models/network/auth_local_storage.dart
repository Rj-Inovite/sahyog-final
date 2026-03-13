import 'package:shared_preferences/shared_preferences.dart';

/// Centralized local storage for authentication-related values.
/// Designed to be non-intrusive to other APIs like Leaves or Face Registration.
class AuthLocalStorage {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';

  // Private constructor to prevent instantiation
  AuthLocalStorage._(); 

  // --- SAVE DATA ---

  /// Save token, user id, and optional role after successful login.
  /// Stores values as strings for maximum compatibility across the app.
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

  /// Save only token (useful for token refresh or profile sync flows).
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Save only user id.
  static Future<void> saveUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, id);
  }

  // --- GETTERS ---

  /// Returns stored Bearer token. Essential for Dio Interceptors.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Returns stored user id. Used by StudentProfile to fetch web data.
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Returns stored user role (e.g., "student", "warden").
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

  /// Clears only auth-related keys.
  /// This is the "Safe Logout" - it doesn't touch your other app settings.
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userRoleKey);
  }

  /// Full reset. Use only if a total app reset is required.
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}