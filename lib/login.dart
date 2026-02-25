// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/data/models/network/api_service.dart';

// Dashboard imports
import 'boy.dart';
import 'girl.dart';
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
  
  // API Service instance (kept for general use)
  final ApiService _apiService = ApiService();

  // Screen State variables
  String selectedRole = 'Girl';
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Input Controllers
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ================= 1. DYNAMIC IMAGE LOGIC =================
  String getRoleImageUrl() {
    if (selectedRole == 'Girl') {
      return 'https://media.istockphoto.com/id/617590498/vector/girl-icon-cartoon-single-avatar-people-icon.jpg?s=612x612&w=0&k=20&c=jvZMLSb6iQwv3v7m2FHo4TsdW_m7TE-raytwiW4OEks=';
    } else if (selectedRole == 'Boy') {
      return 'https://cdn-icons-png.flaticon.com/512/1999/1999625.png';
    } else if (selectedRole == 'Parent') {
      return 'https://cdn-icons-png.flaticon.com/512/8955/8955352.png';
    } else if (selectedRole == 'Warden') {
      return 'https://cdn.pixabay.com/photo/2024/02/14/05/34/girl-8572395_640.png';
    } else if (selectedRole == 'Biometric Admin') {
      return 'https://www.shutterstock.com/image-vector/face-recognition-icon-biometrical-sign-260nw-2594701351.jpg';
    } else {
      return 'https://images.unsplash.com/photo-1503467913725-8487b65262ad?q=80&w=400&auto=format&fit=crop';
    }
  }

  // ================= 2. DYNAMIC COLOR LOGIC =================
  Color getSelectedRoleColor() {
    if (selectedRole == 'Girl') {
      return const Color.fromRGBO(185, 38, 87, 1);
    } else if (selectedRole == 'Boy') {
      return const Color(0xFF1A237E);
    } else if (selectedRole == 'Parent') {
      return const Color(0xFF2E7D32);
    } else if (selectedRole == 'Warden') {
      return const Color.fromARGB(255, 235, 143, 5);
    } else if (selectedRole == 'Biometric Admin') {
      return const Color.fromARGB(255, 11, 159, 218);
    } else {
      return const Color.fromRGBO(185, 38, 87, 1);
    }
  }

  // ================= 3. LOGIN EXECUTION =================
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate() == false) return;

    final String email = _identifierController.text.trim();
    final String password = _passwordController.text.trim();

    setState(() {
      _isLoading = true;
    });

    // --- LOGIC UPDATED FOR admin@gmail.com and Success2026$ ---
    if (email == "admin@gmail.com" && password == "Success2026\$") {
      
      // 1. Success Message
      _showFeedback("You have been logged in", Colors.green);

      // 2. Local Session Storage
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", "local_auth_token_2026");
      await prefs.setString("role", selectedRole);

      Map<String, String> userData = {
        "identifier": email,
        "role": selectedRole,
      };

      // 3. Page Redirection based on selectedRole
      Widget targetScreen;
      if (selectedRole == 'Girl') {
        targetScreen = GirlDashboard(userData: userData);
      } else if (selectedRole == 'Boy') {
        targetScreen = BoyDashboard(userData: userData);
      } else if (selectedRole == 'Parent') {
        targetScreen = ParentPortal(userData: userData);
      } else if (selectedRole == 'Warden') {
        targetScreen = WardenDashboard(userData: userData);
      } else {
        targetScreen = AdminDashboard(userData: userData);
      }

      if (!mounted) return;

      // 4. Navigate to the dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => targetScreen),
      );
      
    } else {
      // Wrong Credentials
      _showFeedback("Wrong credentials. Access denied.", Colors.redAccent);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showFeedback(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ================= 4. MAIN BUILD METHOD =================
  @override
  Widget build(BuildContext context) {
    final Color currentColor = getSelectedRoleColor();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "SAHYOG LOGIN",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        centerTitle: true,
        backgroundColor: currentColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [currentColor.withOpacity(0.1), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 30),
                _buildHeaderImage(currentColor),
                const SizedBox(height: 30),
                _buildRoleSelector(currentColor),
                const SizedBox(height: 40),
                
                _buildInputField(
                  controller: _identifierController,
                  hintText: "admin@gmail.com",
                  iconData: Icons.alternate_email_rounded,
                  themeColor: currentColor,
                ),
                
                _buildInputField(
                  controller: _passwordController,
                  hintText: "Success2026\$",
                  iconData: Icons.lock_open_rounded,
                  themeColor: currentColor,
                  isPasswordField: true,
                  obscureText: !_isPasswordVisible,
                  onSuffixIconTap: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                
                const SizedBox(height: 30),
                _buildSubmitButton(currentColor),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= 5. UI COMPONENTS =================
  Widget _buildHeaderImage(Color themeColor) {
    return Container(
      width: 150, height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: themeColor, width: 3),
        boxShadow: [
          BoxShadow(color: themeColor.withOpacity(0.2), blurRadius: 20, spreadRadius: 5)
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Image.network(
          getRoleImageUrl(),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(Icons.person, size: 80, color: themeColor),
        ),
      ),
    );
  }

  Widget _buildRoleSelector(Color themeColor) {
    final List<String> roleOptions = ['Girl', 'Boy', 'Parent', 'Warden', 'Biometric Admin'];
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: roleOptions.map((role) {
            final bool isSelected = (selectedRole == role);
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedRole = role;
                });
                widget.onRoleChange(role);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? themeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  role,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData iconData,
    required Color themeColor,
    bool isPasswordField = false,
    bool obscureText = false,
    VoidCallback? onSuffixIconTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: hintText,
          prefixIcon: Icon(iconData, color: themeColor),
          suffixIcon: isPasswordField 
            ? IconButton(
                icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                onPressed: onSuffixIconTap,
              ) 
            : null,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: themeColor, width: 2),
          ),
        ),
        validator: (value) => (value == null || value.isEmpty) ? "Cannot be empty" : null,
      ),
    );
  }

  Widget _buildSubmitButton(Color themeColor) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: themeColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
        ),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text("ACCESS ACCOUNT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}