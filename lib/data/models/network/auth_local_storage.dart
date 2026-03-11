import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalStorage {
  static const String _tokenKey = "auth_token";
  static const String _userIdKey = "user_id";
  static const String _userRoleKey = "user_role"; // Useful for Warden vs Student logic

  // --- SAVE DATA ---
  /// Saves the essential auth data after a successful login.
  static Future<void> saveAuthData({
    required String token, 
    required String id, 
    String? role
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, id);
    if (role != null) {
      await prefs.setString(_userRoleKey, role);
    }
  }

  // --- GETTERS ---
  
  /// Fetches the Bearer Token for your AuthInterceptor.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Fetches the User ID (Owner ID) needed for Chat Setup and Profile APIs.
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Fetches the role (Warden/Student) if saved.
  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  // --- UTILS ---

  /// Quickly check if a session exists (useful for the splash screen).
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Clears all data when the user logs out.
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}