// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';

// ✅ RESTORED: USING YOUR CENTRAL API SERVICE & MODELS
import '../data/models/network/api_service.dart'; 
import '../data/models/network/password_update_model.dart';

class StudentProfile extends StatefulWidget {
  final Map<String, dynamic> userData; 
  const StudentProfile({super.key, required this.userData});

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> with TickerProviderStateMixin {
  // --- PREMIUM SAHYOG THEME COLORS ---
  final Color primaryPurple = const Color(0xFF6A1B9A); 
  final Color accentPurple = const Color(0xFF9C27B0);
  final Color deepPurple = const Color(0xFF4A148C);
  final Color lightLavender = const Color(0xFFF3E5F5);
  final Color bgWhite = Colors.white;
  final Color cardGrey = const Color(0xFFF8F9FA);
  final Color softGrey = const Color(0xFFEEEEEE); // ✅ DEFINED: Error Fixed

  // Controllers for editable fields
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  
  // ✅ API Data Holders
  String _status = "ACTIVE";
  String _rollNo = "N/A";

  bool _isEditing = false;
  bool _isLoading = false;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    
    // ✅ LOGIC: USE GMAIL PREFIX AS NAME IF FIRST_NAME IS NULL
    String email = widget.userData['email'] ?? "student@gmail.com";
    String gmailPrefix = email.split('@')[0].toUpperCase();
    String initialName = widget.userData['first_name'] ?? gmailPrefix;

    _nameController = TextEditingController(text: initialName);
    _emailController = TextEditingController(text: email);
    _addressController = TextEditingController(text: widget.userData['address'] ?? "Address not set");
    
    // 2 Tabs: Identity and Security
    _tabController = TabController(length: 2, vsync: this);

    // Initializations
    _loadSavedImage();
    _fetchWebProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // --- PERSISTENCE: LOAD IMAGE FROM LOCAL STORAGE ---
  Future<void> _loadSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? imagePath = prefs.getString('saved_profile_path');
    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }
  }

  // --- API LOGIC: FETCH FROM WEB DASHBOARD ---
  Future<void> _fetchWebProfileData() async {
    setState(() => _isLoading = true);
    try {
      final int studentId = int.parse(widget.userData['id'].toString());
      
      // Hit the endpoint: GET student/view/{id}
      final response = await apiService.getStudentProfileView(studentId);

      if (response != null && response['success'] == true) {
        final data = response['data'];
        setState(() {
          _status = (data['status'] ?? "ACTIVE").toString().toUpperCase();
          _rollNo = data['user_id']?.toString() ?? "N/A";
          
          if (data['permanent_address'] != null) {
            _addressController.text = data['permanent_address'];
          }
        });
      }
    } catch (e) {
      debugPrint("API Fetch Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- IMAGE PICKER & PERMANENT SAVING ---
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_profile_path', image.path); 
      setState(() => _profileImage = File(image.path));
      _showSnackBar("Profile image updated!", Colors.deepPurple);
    }
  }

  // --- RESTORED: PASSWORD UPDATE LOGIC ---
  Future<void> _handlePasswordUpdate(String oldP, String newP, String confirmP) async {
    if (newP.isEmpty || oldP.isEmpty) {
      _showSnackBar("Please fill all password fields", Colors.orange);
      return;
    }
    if (newP != confirmP) {
      _showSnackBar("New passwords do not match", Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final request = PasswordUpdateRequest(
        userId: widget.userData['id'].toString(), 
        oldPassword: oldP,
        password: newP,
        passwordConfirmation: confirmP,
      );

      final response = await apiService.client.updatePassword(request);
      
      if (response.success) {
        if (mounted) Navigator.pop(context);
        _showSnackBar("Password updated successfully!", Colors.green);
      }
    } catch (e) {
      _showSnackBar("Failed to update password. Check current one.", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)), 
        backgroundColor: color, 
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgWhite,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _fetchWebProfileData,
            color: primaryPurple,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                _buildSliverAppBar(),
                _buildTabBarSection(),
                _buildTabContent(),
              ],
            ),
          ),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      stretch: true,
      backgroundColor: primaryPurple,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryPurple, accentPurple, deepPurple],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              _buildProfileAvatar(),
              const SizedBox(height: 15),
              FadeInDown(
                child: Text(_nameController.text, 
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              ),
              Text(_emailController.text, 
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(_isEditing ? Icons.check_circle_rounded : Icons.edit_note_rounded, color: Colors.white, size: 30),
          onPressed: () {
            setState(() => _isEditing = !_isEditing);
            if (!_isEditing) _showSnackBar("Profile View Updated!", Colors.green);
          },
        )
      ],
    );
  }

  Widget _buildProfileAvatar() {
    return ZoomIn(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 56,
                backgroundColor: lightLavender,
                backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null 
                    ? Icon(Icons.person_rounded, size: 60, color: primaryPurple) 
                    : null,
              ),
            ),
          ),
          Positioned(
            bottom: 5,
            right: 5,
            child: GestureDetector(
              onTap: _pickImage,
              child: BounceInDown(
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 18,
                  child: Icon(Icons.add_a_photo_rounded, size: 18, color: primaryPurple),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarSection() {
    return SliverToBoxAdapter(
      child: Container(
        color: deepPurple,
        child: Container(
          decoration: BoxDecoration(
            color: bgWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: primaryPurple,
            unselectedLabelColor: Colors.grey[400],
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 4, color: primaryPurple),
              insets: const EdgeInsets.symmetric(horizontal: 40),
            ),
            tabs: const [
              Tab(icon: Icon(Icons.badge_rounded), text: "Identity"),
              Tab(icon: Icon(Icons.verified_user_rounded), text: "Security"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return SliverFillRemaining(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildIdentityTab(),
          _buildSecurityTab(),
        ],
      ),
    );
  }

  Widget _buildIdentityTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        FadeInLeft(child: _buildTextField("Student Name", _nameController, Icons.person_outline, isReadOnly: !_isEditing)),
        FadeInLeft(delay: const Duration(milliseconds: 100), child: _buildTextField("Official Email", _emailController, Icons.alternate_email_rounded, isReadOnly: true)),
        FadeInLeft(delay: const Duration(milliseconds: 200), child: _buildTextField("Current Address", _addressController, Icons.home_outlined, isReadOnly: !_isEditing, isLong: true)),
        const SizedBox(height: 20),
        FadeInUp(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: softGrey, borderRadius: BorderRadius.circular(15)),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: primaryPurple, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text("Email is managed by admin and cannot be changed.", style: TextStyle(fontSize: 11, color: Colors.grey)),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildSecurityTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        FadeInRight(
          child: _buildActionTile(
            "Change Password", 
            "Update your portal security", 
            Icons.lock_reset_rounded, 
            primaryPurple, 
            _showPasswordSheet
          ),
        ),
        const SizedBox(height: 16),
        FadeInRight(
          delay: const Duration(milliseconds: 100),
          child: _buildActionTile(
            "Logout Session", 
            "Sign out from this device", 
            Icons.logout_rounded, 
            Colors.redAccent, 
            () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.popUntil(context, (route) => route.isFirst);
            }
          ),
        ),
      ],
    );
  }

  // --- REUSABLE UI HELPERS ---

  Widget _buildTextField(String label, TextEditingController ctrl, IconData icon, {bool isReadOnly = false, bool isLong = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryPurple.withOpacity(0.7))),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl,
            readOnly: isReadOnly,
            maxLines: isLong ? 3 : 1,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: isReadOnly ? Colors.grey : primaryPurple, size: 20),
              filled: true,
              fillColor: isReadOnly ? cardGrey : lightLavender.withOpacity(0.3),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(String title, String sub, IconData icon, Color color, VoidCallback tap) {
    return ListTile(
      onTap: tap,
      tileColor: cardGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54, 
      child: const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }

  void _showPasswordSheet() {
    final oldC = TextEditingController();
    final newC = TextEditingController();
    final confC = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 30, right: 30, top: 20),
        decoration: BoxDecoration(color: bgWhite, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            const Text("Update Security", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 25),
            _buildSheetField(oldC, "Current Password", Icons.lock_outline_rounded),
            const SizedBox(height: 15),
            _buildSheetField(newC, "New Password", Icons.lock_reset_rounded),
            const SizedBox(height: 15),
            _buildSheetField(confC, "Confirm Password", Icons.check_circle_outline_rounded),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPurple,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () => _handlePasswordUpdate(oldC.text, newC.text, confC.text),
              child: const Text("SAVE CHANGES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetField(TextEditingController ctrl, String hint, IconData icon) {
    return TextField(
      controller: ctrl,
      obscureText: true,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: primaryPurple),
        filled: true,
        fillColor: cardGrey,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}