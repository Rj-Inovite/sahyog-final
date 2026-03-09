// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/data/models/network/api_service.dart';

// Updated Dashboard imports
import 'student.dart'; // Import your new student dashboard
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
  final ApiService _apiService = ApiService();

  // Updated Roles List
  final List<String> roles = ['Student', 'Parent', 'Warden', 'Biometric Admin'];

  // State Variables
  String selectedRole = 'Student'; // Defaulted to Student
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

  // ================= THEME & IMAGE MAPPING =================

  Color _getThemeColor() {
    switch (selectedRole) {
      case 'Student': return const Color.fromARGB(255, 115, 41, 212); // Deep Blue
      case 'Parent': return const Color.fromRGBO(28, 128, 33, 1);  // Green
      case 'Warden': return const Color(0xFFEB8F05);  // Orange
      default: return const Color(0xFF0B9FDA);        // Light Blue for Admin
    }
  }

  String _getRoleImageUrl() {
    switch (selectedRole) {
      case 'Student': 
        return 'https://cdn-icons-png.flaticon.com/512/3549/3549155.png';
      case 'Parent': 
        return 'https://cdn-icons-png.flaticon.com/512/8955/8955352.png';
      case 'Warden': 
        return 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png';
      default: 
        return 'https://cdn-icons-png.flaticon.com/512/9131/9131529.png';
    }
  }

  // ================= LOGIN FUNCTION =================

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.client.login({
        "login": _identifierController.text.trim(),
        "password": _passwordController.text.trim(),
      });

      String serverRole = response.role; 
      String authToken = response.token;
      String firstName = response.user.firstName;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", authToken);
      await prefs.setString("role", serverRole);

      Map<String, String> userData = {
        "identifier": _identifierController.text.trim(),
        "role": serverRole,
        "name": firstName,
      };

      if (!mounted) return;

      _showFeedback("Welcome, $firstName!", Colors.green);

      // ================= UPDATED REDIRECT LOGIC =================
      
      Widget targetScreen;

      // 1. Check if Warden
      if (selectedRole == "Warden" || serverRole == "Warden") {
        targetScreen = WardenDashboard(userData: userData);
      } 
      // 2. Check if Student (Maps to API "Hosteller")
      else if (selectedRole == "Student" || serverRole == "Hosteller") {
        targetScreen = StudentDashboard(userData: userData);
      } 
      // 3. Check if Parent
      else if (selectedRole == "Parent" || serverRole == "Parent") {
        targetScreen = ParentPortal(userData: userData);
      } 
      // 4. Default to Admin
      else {
        targetScreen = AdminDashboard(userData: userData);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => targetScreen),
      );

    } catch (e) {
      debugPrint("LOGIN ERROR: $e");
      _showFeedback("Login failed. Check credentials.", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showFeedback(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ================= UI COMPONENTS =================

  @override
  Widget build(BuildContext context) {
    final themeColor = _getThemeColor();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("SAHYOG LOGIN", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: themeColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            
            // --- DYNAMIC PROFILE IMAGE ---
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: themeColor.withOpacity(0.5), width: 4),
                ),
                child: CircleAvatar(
                  radius: 65,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: NetworkImage(_getRoleImageUrl()),
                ),
              ),
            ),
            
            const SizedBox(height: 30),

            // --- ROLE SELECTOR ---
            _buildRolePills(themeColor),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _identifierController,
                      label: "Email / Username",
                      icon: Icons.person_outline,
                      color: themeColor,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _passwordController,
                      label: "Password",
                      icon: Icons.lock_outline,
                      color: themeColor,
                      isPassword: true,
                    ),
                    const SizedBox(height: 40),

                    _buildShinyButton(themeColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRolePills(Color themeColor) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: roles.map((role) {
          bool isSelected = selectedRole == role;
          return GestureDetector(
            onTap: () {
              setState(() => selectedRole = role);
              widget.onRoleChange(role);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? themeColor : Colors.grey[100],
                borderRadius: BorderRadius.circular(30),
                boxShadow: isSelected 
                  ? [BoxShadow(color: themeColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
                  : [],
              ),
              child: Text(
                role,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black54,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? !_isPasswordVisible : false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: color),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              )
            : null,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: color, width: 2),
        ),
      ),
      validator: (value) => (value == null || value.isEmpty) ? "Field required" : null,
    );
  }

  Widget _buildShinyButton(Color themeColor) {
    return AnimatedBuilder(
      animation: _shinyController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                _shinyController.value - 0.4,
                _shinyController.value,
                _shinyController.value + 0.4,
              ],
              colors: [themeColor, Colors.white.withOpacity(0.5), themeColor],
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
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("LOG IN", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        );
      },
    );
  }
}