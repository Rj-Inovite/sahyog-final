import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalStorage {
  static const String _tokenKey = "auth_token";
  static const String _userIdKey = "user_id";

  // Save both after Login
  static Future<void> saveAuthData(String token, String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, id);
  }

  // Get Token for the Interceptor
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get ID for Profile/Chat logic
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Clear when Logout
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}