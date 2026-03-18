// ignore_for_file: use_build_context_synchronously

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/data/models/network/api_service.dart';
import 'package:my_app/data/models/network/auth_local_storage.dart';
import 'package:dio/dio.dart';

// Dashboard imports
import 'student.dart'; 
import 'parent.dart';
import 'warden.dart'; // Ensure WardenDashboard is defined here
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

  final Color deepBlue = const Color(0xFF1E3A8A);
  final Color vibrantPink = const Color.fromRGBO(34, 14, 209, 1);
  final Color softBlue = const Color(0xFF60A5FA);

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
      final response = await apiService.client.login({
        "login": _identifierController.text.trim(),
        "password": _passwordController.text.trim(),
      });

      String serverRole = (response.role ?? "").toString().trim();
      String authToken  = (response.token ?? "").toString();

      var userObj       = response.user;
      String userId     = (userObj?.id ?? 0).toString();
      String userUnique = (userObj?.userId ?? "").toString();
      String firstName  = (userObj?.firstName ?? "User").toString();
      String lastName   = (userObj?.lastName ?? "").toString();
      String email      = (userObj?.email ?? _identifierController.text.trim()).toString();

      if (authToken.isEmpty) {
        _showFeedback("Error: Server returned no token.", Colors.redAccent);
        return;
      }

      // Save Auth Data locally
      await AuthLocalStorage.saveAuthData(
        token: authToken,
        id: userId,
        role: serverRole,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("user_name", firstName);
      await prefs.setString("user_email", email); // Store email for profile use

      // Prepare data map for Dashboards
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

      String normalizedRole = serverRole.toLowerCase();
      widget.onRoleChange(serverRole); // Notify parent of role change

      Widget targetScreen;
      
      // --- ROLE BASED NAVIGATION ---
      if (normalizedRole.contains("warden") || normalizedRole.contains("hostel manager")) {
        // Passing the full userData map to the WardenDashboard
        targetScreen = WardenDashboard(userData: userData);
      } else if (normalizedRole.contains("student") || normalizedRole.contains("hosteller")) {
        targetScreen = StudentDashboard(userData: userData);
      } else if (normalizedRole.contains("parent")) {
        targetScreen = ParentPortal(userData: userData);
      } else {
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

  // --- UI COMPONENTS (UNCHANGED TO PRESERVE YOUR AESTHETIC) ---

  void _showFeedback(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [deepBlue, softBlue],
              ),
            ),
          ),
          Positioned(
            top: -50,
            left: -50,
            child: _buildBlurCircle(300, vibrantPink.withOpacity(0.4)),
          ),
          Positioned(
            bottom: 100,
            right: -80,
            child: _buildBlurCircle(400, vibrantPink.withOpacity(0.3)),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: [vibrantPink, Colors.white]),
                            boxShadow: [
                              BoxShadow(color: vibrantPink.withOpacity(0.5), blurRadius: 15)
                            ],
                          ),
                          child: const Icon(Icons.apartment_rounded, size: 40, color: Color(0xFF1E3A8A)),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "SAHYOG",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "WELCOME BACK",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.7),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),
                        _buildCustomField(
                          controller: _identifierController,
                          label: "Email Address",
                          icon: Icons.person_outline_rounded,
                          validator: (v) => v!.isEmpty ? "Enter your email" : null,
                        ),
                        const SizedBox(height: 20),
                        _buildCustomField(
                          controller: _passwordController,
                          label: "Password",
                          icon: Icons.lock_open_rounded,
                          isPassword: true,
                          isVisible: _isPasswordVisible,
                          onToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                          validator: (v) => v!.isEmpty ? "Enter your password" : null,
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: vibrantPink.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: vibrantPink,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                elevation: 0,
                              ),
                              onPressed: _isLoading ? null : _handleLogin,
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                                  : const Text(
                                      "LOGIN TO DASHBOARD",
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _buildCustomField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !isVisible,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.white, size: 22),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility, color: Colors.white.withOpacity(0.5)),
                onPressed: onToggle,
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}