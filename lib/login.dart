// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/data/models/network/api_service.dart';
import 'package:my_app/data/models/network/auth_local_storage.dart';
import 'package:dio/dio.dart';

// Dashboard imports
import 'student.dart'; 
import 'parent.dart';
import 'warden.dart';
import 'admin.dart';

class LoginPage extends StatefulWidget {
  final Function(String) onRoleChange;
  const LoginPage({super.key, required this.onRoleChange});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final Color primaryIndigo = const Color(0xFF4F46E5);

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // ✅ Backend expects "login" not "email"
      final response = await apiService.client.login({
        "login": _identifierController.text.trim(),
        "password": _passwordController.text.trim(),
      });

      // --- Safe extraction with null handling ---
      String serverRole = (response.role ?? "").toString().trim();
      String authToken  = (response.token ?? "").toString();

      var userObj       = response.user;
      String userId     = (userObj?.id ?? 0).toString();
      String userUnique = (userObj?.userId ?? "").toString();
      String firstName  = (userObj?.firstName ?? "User").toString();
      String lastName   = (userObj?.lastName ?? "").toString();
      String email      = (userObj?.email ?? "").toString();

      if (authToken.isEmpty) {
        _showFeedback("Error: Server returned no token.", Colors.redAccent);
        return;
      }

      // Save auth data
      await AuthLocalStorage.saveAuthData(
        token: authToken,
        id: userId,
        role: serverRole,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("user_name", firstName);

      Map<String, String> userData = {
        "identifier": _identifierController.text.trim(),
        "role": serverRole,
        "name": firstName,
        "last_name": lastName,
        "id": userId,
        "user_unique_id": userUnique,
        "email": email,
      };

      if (!mounted) return;

      // Normalize role string to avoid mismatch
      String normalizedRole = serverRole.toLowerCase();

      Widget targetScreen;
      if (normalizedRole.contains("warden") || normalizedRole.contains("hostel manager")) {
        targetScreen = WardenDashboard(userData: userData);
      } else if (normalizedRole.contains("student") || normalizedRole.contains("hosteller")) {
        targetScreen = StudentDashboard(userData: userData);
      } else if (normalizedRole.contains("parent")) {
        targetScreen = ParentPortal(userData: userData);
      } else if (normalizedRole.contains("admin")) {
        targetScreen = AdminDashboard(userData: userData);
      } else {
        // Fallback
        targetScreen = AdminDashboard(userData: userData);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => targetScreen),
      );

    } on DioException catch (e) {
      String errorMsg = "Login failed";
      if (e.response?.statusCode == 401) {
        errorMsg = "Invalid Email or Password.";
      }
      _showFeedback(errorMsg, Colors.redAccent);
    } catch (e) {
      debugPrint("CRITICAL ERROR: $e");
      _showFeedback("Check your internet or server.", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showFeedback(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text("SAHYOG",
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: primaryIndigo)),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _identifierController,
                  decoration: InputDecoration(
                      labelText: "Email", prefixIcon: const Icon(Icons.email)),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primaryIndigo),
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("LOGIN",
                            style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
