import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';

// ✅ FIX: Using correct relative imports based on your folder structure
import '../data/models/network/rest_api_client.dart'; 
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
  final Color lightLavender = const Color(0xFFE1BEE7);
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
    // ✅ Mapping from your provided API Response JSON
    _nameController = TextEditingController(text: widget.userData['first_name'] ?? "Student");
    _emailController = TextEditingController(text: widget.userData['email'] ?? "");
    _phoneController = TextEditingController(text: widget.userData['mobile'] ?? "");
    _addressController = TextEditingController(text: widget.userData['address'] ?? "Update on Web Dashboard");
    
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

  // --- PASSWORD SYNC: App to Web Dashboard ---
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
      // ✅ FIX: Use the full API URL that worked in your login logs
      final dio = Dio(BaseOptions(
        baseUrl: "https://devsahyog.myakola.com/api/",
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      )); 
      
      final client = RestAPIClient(dio); 
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      // ✅ Map user_id from the JSON response: {"id": 65, ...}
      final request = PasswordUpdateRequest(
        userId: widget.userData['id'].toString(), 
        oldPassword: oldP,
        password: newP,
        passwordConfirmation: confirmP,
      );

      final response = await client.updatePassword("Bearer $token", request);
      
      if (response.success) {
        if (mounted) Navigator.pop(context);
        _showSnackBar("Password Updated! Use this for Web login too.", Colors.green);
      }
    } catch (e) {
      // Handles 422 errors: validation failures like "wrong old password"
      _showSnackBar("Sync Failed: Check current password or requirements", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
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
                expandedHeight: 240,
                pinned: true,
                backgroundColor: primaryPurple,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        colors: [primaryPurple, const Color(0xFF8E24AA)],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        FadeIn(
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, size: 55, color: primaryPurple),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(_nameController.text, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        Text(widget.userData['user_id'] ?? "STU-ID", style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(_isEditing ? Icons.check_circle : Icons.edit, color: Colors.white),
                    onPressed: () => setState(() => _isEditing = !_isEditing),
                  )
                ],
              ),
              // TabBar and TabBarView implementation...
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: primaryPurple,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: primaryPurple,
                    tabs: const [
                      Tab(text: "Identity"),
                      Tab(text: "Room"),
                      Tab(text: "Finance"),
                      Tab(text: "Security"),
                    ],
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
            Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  // --- UI Builder Methods ---

  Widget _buildInfoTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildEditField("Full Name", _nameController, Icons.person_outline),
        _buildEditField("Email", _emailController, Icons.mail_outline),
        _buildEditField("Mobile", _phoneController, Icons.phone_android),
        _buildEditField("Address", _addressController, Icons.location_on_outlined, isLong: true),
      ],
    );
  }

  Widget _buildRoomTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildStaticTile("Hostel ID", widget.userData['hostel_id']?.toString() ?? "N/A", Icons.domain),
        _buildStaticTile("Admission Date", widget.userData['admission_date'] ?? "Not Set", Icons.calendar_today),
        _buildStaticTile("Registration Status", widget.userData['status'] ?? "Active", Icons.verified),
      ],
    );
  }

  Widget _buildFinanceTab() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text("Financial records and dues are synced directly from the Sahyog Web Dashboard.", 
          textAlign: TextAlign.center, 
          style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  Widget _buildSecurityTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          ListTile(
            tileColor: cardGrey,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: Icon(Icons.lock_outline, color: primaryPurple),
            title: const Text("Update Password"),
            subtitle: const Text("Sync credentials with App & Web"),
            trailing: const Icon(Icons.sync),
            onTap: _showPasswordSheet,
          ),
          const SizedBox(height: 20),
          ListTile(
            tileColor: cardGrey,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Log Out", style: TextStyle(color: Colors.red)),
            onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController ctrl, IconData icon, {bool isLong = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: ctrl,
        enabled: _isEditing,
        maxLines: isLong ? 3 : 1,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryPurple),
          filled: true,
          fillColor: _isEditing ? Colors.purple.withOpacity(0.05) : cardGrey,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildStaticTile(String title, String val, IconData icon) {
    return Card(
      elevation: 0,
      color: cardGrey,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: primaryPurple),
        title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 25, right: 25, top: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Security Sync", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: oldC, obscureText: true, decoration: const InputDecoration(hintText: "Old Password", border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(controller: newC, obscureText: true, decoration: const InputDecoration(hintText: "New Password", border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(controller: confC, obscureText: true, decoration: const InputDecoration(hintText: "Confirm New Password", border: OutlineInputBorder())),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryPurple, minimumSize: const Size(double.infinity, 55)),
              onPressed: () => _handlePasswordUpdate(oldC.text, newC.text, confC.text),
              child: const Text("UPDATE ON SERVER", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}