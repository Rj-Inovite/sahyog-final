// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';

// ✅ USING YOUR CENTRAL API SERVICE & MODELS
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
  final Color primaryPurple = const Color.fromRGBO(206, 12, 125, 1); 
  final Color accentPurple = const Color.fromRGBO(214, 46, 124, 0.952);
  final Color deepPurple = const Color.fromRGBO(223, 36, 129, 1);
  final Color lightLavender = const Color(0xFFF3E5F5);
  final Color bgWhite = Colors.white;
  final Color cardGrey = const Color(0xFFF8F9FA);
  final Color softGrey = const Color(0xFFEEEEEE); 

  // Controllers for editable fields
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController; // ✅ ADDED: For API mobile field
  
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
    
    // ✅ SYNC LOGIC: Handle naming and mobile from initial userData
    String email = widget.userData['email'] ?? "student@gmail.com";
    String firstName = widget.userData['first_name'] ?? "";
    String lastName = widget.userData['last_name'] ?? "";
    String initialName = "$firstName $lastName".trim();

    // Fallback if name is empty
    if (initialName.isEmpty) {
      initialName = email.split('@')[0].toUpperCase();
    }

    _nameController = TextEditingController(text: initialName);
    _emailController = TextEditingController(text: email);
    _addressController = TextEditingController(text: widget.userData['address'] ?? "Address not set");
    _phoneController = TextEditingController(text: widget.userData['mobile']?.toString() ?? "");
    
    _tabController = TabController(length: 2, vsync: this);

    _loadSavedImage();
    _fetchWebProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // --- API LOGIC: FETCH FROM WEB DASHBOARD ---
  Future<void> _fetchWebProfileData() async {
    setState(() => _isLoading = true);
    try {
      final int studentId = int.parse(widget.userData['id'].toString());
      final response = await apiService.getStudentProfileView(studentId);

      if (response != null && response['status'] == 'success') {
        final data = response['data'];
        setState(() {
          _status = (data['status'] ?? "ACTIVE").toString().toUpperCase();
          _rollNo = data['user_id']?.toString() ?? "N/A";
          _addressController.text = data['address'] ?? _addressController.text;
          _phoneController.text = data['mobile']?.toString() ?? _phoneController.text;
          
          if (data['first_name'] != null) {
            _nameController.text = "${data['first_name']} ${data['last_name'] ?? ""}".trim();
          }
        });
      }
    } catch (e) {
      debugPrint("API Fetch Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- ✅ NEW API LOGIC: UPDATE PROFILE (PUT /user/update) ---
  Future<void> _updateProfileOnServer() async {
    setState(() => _isLoading = true);
    try {
      // Split name into first and last as required by Laravel
      List<String> nameParts = _nameController.text.trim().split(' ');
      String fName = nameParts.isNotEmpty ? nameParts[0] : "";
      String lName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : "";

      final Map<String, dynamic> body = {
        "first_name": fName,
        "last_name": lName,
        "mobile": _phoneController.text,
        "address": _addressController.text,
      };

      final response = await apiService.client.updateProfile(body);

      if (response['status'] == 'success') {
        setState(() => _isEditing = false);
        _showSnackBar(response['message'] ?? "Profile Updated!", Colors.green);
      }
    } catch (e) {
      debugPrint("Update Error: $e");
      _showSnackBar("Update failed. Check your connection.", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- PASSWORD UPDATE LOGIC ---
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
      _showSnackBar("Failed to update password.", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- IMAGE HELPERS ---
  Future<void> _loadSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? imagePath = prefs.getString('saved_profile_path');
    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() => _profileImage = File(imagePath));
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_profile_path', image.path); 
      setState(() => _profileImage = File(image.path));
      _showSnackBar("Profile image updated!", Colors.deepPurple);
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
      backgroundColor: primaryPurple,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [primaryPurple, accentPurple, deepPurple]),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              _buildProfileAvatar(),
              const SizedBox(height: 15),
              FadeInDown(
                child: Text(_nameController.text, 
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              ),
              Text(_emailController.text, style: TextStyle(color: Colors.white.withOpacity(0.8))),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(_isEditing ? Icons.check_circle_rounded : Icons.edit_note_rounded, color: Colors.white, size: 30),
          onPressed: () {
            if (_isEditing) {
              _updateProfileOnServer(); // ✅ CALLS API ON SAVE
            } else {
              setState(() => _isEditing = true);
            }
          },
        )
      ],
    );
  }

  Widget _buildProfileAvatar() {
    return ZoomIn(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white24,
            child: CircleAvatar(
              radius: 56,
              backgroundColor: lightLavender,
              backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
              child: _profileImage == null ? Icon(Icons.person_rounded, size: 60, color: primaryPurple) : null,
            ),
          ),
          Positioned(
            bottom: 5, right: 5, 
            child: GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(backgroundColor: Colors.white, radius: 18, child: Icon(Icons.camera_alt, size: 18, color: primaryPurple))
            )
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
          decoration: BoxDecoration(color: bgWhite, borderRadius: const BorderRadius.vertical(top: Radius.circular(35))),
          child: TabBar(
            controller: _tabController,
            labelColor: primaryPurple,
            indicatorColor: primaryPurple,
            tabs: const [Tab(text: "Identity"), Tab(text: "Security")],
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
        FadeInLeft(child: _buildTextField("Full Name", _nameController, Icons.person_outline, isReadOnly: !_isEditing)),
        FadeInLeft(delay: const Duration(milliseconds: 100), child: _buildTextField("Phone Number", _phoneController, Icons.phone_android_rounded, isReadOnly: !_isEditing)),
        FadeInLeft(delay: const Duration(milliseconds: 200), child: _buildTextField("Official Email", _emailController, Icons.alternate_email_rounded, isReadOnly: true)),
        FadeInLeft(delay: const Duration(milliseconds: 300), child: _buildTextField("Home Address", _addressController, Icons.home_outlined, isReadOnly: !_isEditing, isLong: true)),
        
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBadge("Status", _status, Colors.green),
            _buildBadge("ID", _rollNo, Colors.blueGrey),
          ],
        )
      ],
    );
  }

  Widget _buildSecurityTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildActionTile("Change Password", "Update security", Icons.lock_outline, primaryPurple, _showPasswordSheet),
        const SizedBox(height: 16),
        _buildActionTile("Logout", "Sign out from device", Icons.logout, Colors.redAccent, () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          Navigator.popUntil(context, (route) => route.isFirst);
        }),
      ],
    );
  }

  // --- REUSABLE WIDGETS ---

  Widget _buildBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text("$label: $value", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, IconData icon, {bool isReadOnly = false, bool isLong = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryPurple)),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl,
            readOnly: isReadOnly,
            maxLines: isLong ? 3 : 1,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: isReadOnly ? Colors.grey : primaryPurple),
              filled: true,
              fillColor: isReadOnly ? cardGrey : lightLavender.withOpacity(0.2),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(sub),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(color: Colors.black45, child: const Center(child: CircularProgressIndicator(color: Colors.white)));
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
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        decoration: BoxDecoration(color: bgWhite, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Update Password", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildSheetField(oldC, "Old Password"),
            const SizedBox(height: 10),
            _buildSheetField(newC, "New Password"),
            const SizedBox(height: 10),
            _buildSheetField(confC, "Confirm Password"),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryPurple, minimumSize: const Size(double.infinity, 50)),
              onPressed: () => _handlePasswordUpdate(oldC.text, newC.text, confC.text),
              child: const Text("UPDATE", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      obscureText: true,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: cardGrey,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }
}