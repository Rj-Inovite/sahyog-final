// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';

// ✅ USING YOUR CENTRAL API SERVICE
import '../data/models/network/api_service.dart'; 
import '../data/models/network/password_update_model.dart';

class StudentProfile extends StatefulWidget {
  final Map<String, dynamic> userData; 
  const StudentProfile({super.key, required this.userData});

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> with TickerProviderStateMixin {
  // --- PREMIUM THEME: White Background with Purple/Lavender ---
  final Color primaryPurple = const Color(0xFF6A1B9A); 
  final Color lightLavender = const Color(0xFFF3E5F5);
  final Color bgWhite = Colors.white;
  final Color cardGrey = const Color(0xFFF8F9FA);

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  
  bool _isEditing = false;
  bool _isLoading = false;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // ✅ Mapping from API keys
    _nameController = TextEditingController(text: widget.userData['name'] ?? "Student");
    _emailController = TextEditingController(text: widget.userData['email'] ?? "");
    _phoneController = TextEditingController(text: widget.userData['mobile'] ?? "");
    _addressController = TextEditingController(text: widget.userData['address'] ?? "Akola, Maharashtra");
    
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // --- PASSWORD SYNC: Fixed the Argument Error here ---
  Future<void> _handlePasswordUpdate(String oldP, String newP, String confirmP) async {
    if (newP.isEmpty || oldP.isEmpty) {
      _showSnackBar("Please enter passwords", Colors.orange);
      return;
    }
    if (newP != confirmP) {
      _showSnackBar("Passwords do not match", Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    try {
      // ✅ FIX: Using PasswordUpdateRequest model
      final request = PasswordUpdateRequest(
        userId: widget.userData['id'].toString(), 
        oldPassword: oldP,
        password: newP,
        passwordConfirmation: confirmP,
      );

      // ✅ FIX: Removed the first 'token' argument. 
      // The apiService.client handles headers automatically via Interceptor.
      final response = await apiService.client.updatePassword(request);
      
      if (response.success) {
        if (mounted) Navigator.pop(context);
        _showSnackBar("Password updated successfully!", Colors.green);
      }
    } catch (e) {
      debugPrint("Update Error: $e");
      _showSnackBar("Failed to sync password. Verify current password.", Colors.red);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgWhite,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                elevation: 0,
                backgroundColor: primaryPurple,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(_isEditing ? "Editing Profile" : "My Profile", 
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [primaryPurple, const Color(0xFF9C27B0)],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        ZoomIn(
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person_rounded, size: 50, color: primaryPurple),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(_nameController.text, 
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(_isEditing ? Icons.save_rounded : Icons.edit_rounded, color: Colors.white),
                    onPressed: () {
                      setState(() => _isEditing = !_isEditing);
                      if (!_isEditing) _showSnackBar("Profile Updated Locally", primaryPurple);
                    },
                  )
                ],
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: primaryPurple,
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgWhite,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: primaryPurple,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: primaryPurple,
                      indicatorPadding: const EdgeInsets.symmetric(horizontal: 20),
                      tabs: const [
                        Tab(icon: Icon(Icons.badge_outlined), text: "Identity"),
                        Tab(icon: Icon(Icons.hotel_outlined), text: "Room"),
                        Tab(icon: Icon(Icons.account_balance_wallet_outlined), text: "Fees"),
                        Tab(icon: Icon(Icons.security_outlined), text: "Security"),
                      ],
                    ),
                  ),
                ),
              ),
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildInfoTab(),
                    _buildRoomTab(),
                    _buildFinanceTab(),
                    _buildSecurityTab(),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading) 
            Container(color: Colors.black45, child: const Center(child: CircularProgressIndicator(color: Colors.white))),
        ],
      ),
    );
  }

  // --- UI TABS ---

  Widget _buildInfoTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildEditField("Full Name", _nameController, Icons.person_outline),
        _buildEditField("Email Address", _emailController, Icons.alternate_email_rounded),
        _buildEditField("Mobile Number", _phoneController, Icons.phone_iphone_rounded),
        _buildEditField("Residential Address", _addressController, Icons.home_work_outlined, isLong: true),
      ],
    );
  }

  Widget _buildRoomTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildStaticTile("Hostel Branch", "Sahyog Boys/Girls Wing", Icons.apartment_rounded),
        _buildStaticTile("Room Number", widget.userData['room_no'] ?? "Allocating...", Icons.bed_rounded),
        _buildStaticTile("Admission Date", widget.userData['admission_date'] ?? "01-Jan-2026", Icons.event_available_rounded),
        _buildStaticTile("Status", "VERIFIED STUDENT", Icons.verified_user_rounded),
      ],
    );
  }

  Widget _buildFinanceTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Financial dashboard is being synced...", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSecurityTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        FadeInUp(
          child: ListTile(
            tileColor: cardGrey,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            leading: CircleAvatar(backgroundColor: lightLavender, child: Icon(Icons.key_rounded, color: primaryPurple)),
            title: const Text("Change Password", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text("Update your login credentials"),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: _showPasswordSheet,
          ),
        ),
        const SizedBox(height: 16),
        FadeInUp(
          delay: const Duration(milliseconds: 100),
          child: ListTile(
            tileColor: cardGrey,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            leading: const CircleAvatar(backgroundColor: Color(0xFFFFEBEE), child: Icon(Icons.logout_rounded, color: Colors.red)),
            title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // Clear token and session
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEditField(String label, TextEditingController ctrl, IconData icon, {bool isLong = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl,
            enabled: _isEditing,
            maxLines: isLong ? 3 : 1,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: primaryPurple, size: 20),
              filled: true,
              fillColor: _isEditing ? lightLavender.withOpacity(0.3) : cardGrey,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticTile(String title, String val, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardGrey,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryPurple),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(val, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  void _showPasswordSheet() {
    final oldC = TextEditingController();
    final newC = TextEditingController();
    final confC = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgWhite,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 30, right: 30, top: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            const Text("Update Password", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 25),
            _buildSheetField(oldC, "Current Password", Icons.lock_outline_rounded),
            const SizedBox(height: 15),
            _buildSheetField(newC, "New Password", Icons.lock_reset_rounded),
            const SizedBox(height: 15),
            _buildSheetField(confC, "Confirm New Password", Icons.check_circle_outline_rounded),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPurple,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              onPressed: () => _handlePasswordUpdate(oldC.text, newC.text, confC.text),
              child: const Text("SAVE NEW PASSWORD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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