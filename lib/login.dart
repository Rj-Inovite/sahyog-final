// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/data/models/network/api_service.dart';

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

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // State Variables
  final List<String> roles = ['Student', 'Parent', 'Warden', 'Biometric Admin'];
  String selectedRole = 'Student'; 
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late AnimationController _shinyController;

  @override
  void initState() {
    super.initState();
    _shinyController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _shinyController.dispose();
    super.dispose();
  }

  // ================= THEME CONFIGURATION =================
  // Using the Universal Modern Theme (Indigo/Slate)
  final Color primaryIndigo = const Color(0xFF4F46E5);
  final Color secondaryTeal = const Color(0xFF14B8A6);
  final Color backgroundWhite = Colors.white;

  String _getRoleImageUrl() {
    switch (selectedRole) {
      case 'Student': return 'https://cdn-icons-png.flaticon.com/512/3549/3549155.png';
      case 'Parent': return 'https://cdn-icons-png.flaticon.com/512/8955/8955352.png';
      case 'Warden': return 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png';
      default: return 'https://cdn-icons-png.flaticon.com/512/9131/9131529.png';
    }
  }

  // ================= LOGIN LOGIC =================

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Calling your API Service
      final response = await apiService.client.login({
        "login": _identifierController.text.trim(),
        "password": _passwordController.text.trim(),
      });

      // 1. Extract Data from Response
      String serverRole = response.role; 
      String authToken = response.token;
      String userId = response.user.id.toString(); // Extracting the User ID
      String firstName = response.user.firstName;

      // 2. IMPORTANT: Save to SharedPreferences for the Interceptor
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("auth_token", authToken); // Matches Interceptor
      await prefs.setString("user_id", userId);       // Matches Interceptor
      await prefs.setString("role", serverRole);
      await prefs.setString("user_name", firstName);

      Map<String, String> userData = {
        "identifier": _identifierController.text.trim(),
        "role": serverRole,
        "name": firstName,
        "id": userId,
      };

      if (!mounted) return;
      _showFeedback("Welcome back, $firstName!", secondaryTeal);

      // 3. Navigation Logic
      Widget targetScreen;
      if (serverRole.toLowerCase() == "warden") {
        targetScreen = WardenDashboard(userData: userData);
      } else if (serverRole.toLowerCase() == "hosteller" || selectedRole == "Student") {
        targetScreen = StudentDashboard(userData: userData);
      } else if (serverRole.toLowerCase() == "parent") {
        targetScreen = ParentPortal(userData: userData);
      } else {
        targetScreen = AdminDashboard(userData: userData);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => targetScreen),
      );

    } catch (e) {
      debugPrint("LOGIN ERROR: $e");
      _showFeedback("Invalid credentials. Please try again.", Colors.redAccent);
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
        margin: const EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ================= UI BUILDER =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // --- HEADER ---
              Text(
                "SAHYOG",
                style: TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.w900, // ✅ Use w900 for the "Black" weight
  color: primaryIndigo,
),
              ),
              const Text("Management Portal", style: TextStyle(color: Colors.grey)),
              
              const SizedBox(height: 40),
              
              // --- DYNAMIC AVATAR ---
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: primaryIndigo.withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[100],
                  backgroundImage: NetworkImage(_getRoleImageUrl()),
                ),
              ),
              
              const SizedBox(height: 35),

              // --- ROLE SELECTOR ---
              _buildRoleSelector(),

              const SizedBox(height: 30),

              // --- LOGIN FORM ---
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildInputField(
                      controller: _identifierController,
                      label: "Email or Username",
                      icon: Icons.alternate_email_rounded,
                    ),
                    const SizedBox(height: 18),
                    _buildInputField(
                      controller: _passwordController,
                      label: "Password",
                      icon: Icons.lock_open_rounded,
                      isPassword: true,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text("Forgot Password?", style: TextStyle(color: primaryIndigo)),
                      ),
                    ),
                    const SizedBox(height: 30),

                    _buildActionButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: roles.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedRole == roles[index];
          return GestureDetector(
            onTap: () {
              setState(() => selectedRole = roles[index]);
              widget.onRoleChange(roles[index]);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? primaryIndigo : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? primaryIndigo : Colors.grey[200]!,
                ),
              ),
              child: Text(
                roles[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? !_isPasswordVisible : false,
      style: const TextStyle(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, color: primaryIndigo, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(_isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded, size: 20),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              )
            : null,
        filled: true,
        fillColor: Colors.grey[50],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primaryIndigo, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
      validator: (value) => (value == null || value.isEmpty) ? "Required" : null,
    );
  }

  Widget _buildActionButton() {
    return AnimatedBuilder(
      animation: _shinyController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: primaryIndigo.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryIndigo, const Color(0xFF6366F1)],
            ),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            onPressed: _isLoading ? null : _handleLogin,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    "LOGIN TO ACCOUNT",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
          ),
        );
      },
    );
  }
}