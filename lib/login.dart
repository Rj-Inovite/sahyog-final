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
import 'warden.dart'; 
import 'admin.dart';

class LoginPage extends StatefulWidget {
  final Function(String) onRoleChange;
  const LoginPage({super.key, required this.onRoleChange});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // --- ELEGANT PINK PALETTE ---
  final Color deepBerry = const Color(0xFF881337); 
  final Color softRose = const Color(0xFFFB7185);  
  final Color accentPink = const Color(0xFFE11D48); 

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _controller.dispose();
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

      await AuthLocalStorage.saveAuthData(
        token: authToken,
        id: userId,
        role: serverRole,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("user_name", firstName);
      await prefs.setString("user_email", email);

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
      widget.onRoleChange(serverRole); 

      Widget targetScreen;
      
      if (normalizedRole.contains("warden") || normalizedRole.contains("hostel manager")) {
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
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [deepBerry, softRose],
              ),
            ),
          ),
          
          // Animated Background Drifting Circles
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: -40 + (30 * _controller.value),
                    left: -30 + (20 * _controller.value),
                    child: _buildBlurCircle(280, Colors.white.withOpacity(0.15)),
                  ),
                  Positioned(
                    bottom: 80 - (50 * _controller.value),
                    right: -60 + (40 * _controller.value),
                    child: _buildBlurCircle(350, accentPink.withOpacity(0.25)),
                  ),
                ],
              );
            },
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // --- YOUR CUSTOM LOGO ADDED HERE ---
                          Container(
                            height: 100,
                            width: 100,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.9),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/g_logo.png', // Ensure extension is correct
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback icon if the image path is wrong
                                return Icon(Icons.apartment_rounded, size: 40, color: deepBerry);
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "SAHYOG",
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "HOSTEL MANAGEMENT SYSTEM",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.7),
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 40),
                          _buildCustomField(
                            controller: _identifierController,
                            label: "Email Address",
                            icon: Icons.person_pin_rounded,
                            validator: (v) => v!.isEmpty ? "Required" : null,
                          ),
                          const SizedBox(height: 18),
                          _buildCustomField(
                            controller: _passwordController,
                            label: "Password",
                            icon: Icons.lock_person_rounded,
                            isPassword: true,
                            isVisible: _isPasswordVisible,
                            onToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            validator: (v) => v!.isEmpty ? "Required" : null,
                          ),
                          const SizedBox(height: 35),
                          
                          // Elevated Button with White/Pink contrast
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: deepBerry,
                                elevation: 5,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: _isLoading ? null : _handleLogin,
                              child: _isLoading
                                  ? CircularProgressIndicator(color: deepBerry, strokeWidth: 3)
                                  : const Text(
                                      " LOGIN ",
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5),
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
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.white70, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility, color: Colors.white60),
                onPressed: onToggle,
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white, width: 1.2),
        ),
      ),
    );
  }
}