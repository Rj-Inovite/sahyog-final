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
  // --- PREMIUM THEME COLORS ---
  final Color primaryPurple = const Color(0xFF6A1B9A); 
  final Color accentPurple = const Color(0xFF9C27B0);
  final Color lightLavender = const Color(0xFFF3E5F5);
  final Color bgWhite = Colors.white;
  final Color cardGrey = const Color(0xFFF8F9FA);

  // Controllers for editable fields
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  
  // ✅ API Data Holders with Default Fallbacks
  String _aadhar = "Pending Sync";
  String _institute = "Sahyog Associate";
  String _course = "General Stream";
  String _admissionDate = "N/A";
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
    
    // Initialize controllers with current local data from login
    _nameController = TextEditingController(text: widget.userData['first_name'] ?? "Student");
    _emailController = TextEditingController(text: widget.userData['email'] ?? "");
    _phoneController = TextEditingController(text: widget.userData['mobile'] ?? "");
    _addressController = TextEditingController(text: widget.userData['address'] ?? "");
    
    // Fallback date from login info
    if (widget.userData['created_at'] != null) {
      _admissionDate = widget.userData['created_at'].toString().split('T')[0];
    }

    _tabController = TabController(length: 4, vsync: this);

    // ✅ FETCH REAL-TIME DATA ON LOAD
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchWebProfileData();
    });
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
          _aadhar = data['aadhar_number'] ?? "Verified";
          _institute = data['educational_institute'] ?? _institute;
          _course = data['course_name'] ?? _course;
          _status = (data['status'] ?? "ACTIVE").toString().toUpperCase();
          _rollNo = data['user_id']?.toString() ?? "N/A";
          
          if (data['permanent_address'] != null) {
            _addressController.text = data['permanent_address'];
          }
          if (data['admission_date'] != null) {
            _admissionDate = data['admission_date'].toString().split('T')[0];
          }
        });
      }
    } catch (e) {
      // ⚠️ HANDLE 404 OR SYNC ERROR GRACEFULLY
      debugPrint("API Fetch Error: $e");
      _showSnackBar("Displaying session info. Web record pending.", Colors.orange);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- IMAGE PICKER LOGIC ---
  Future<void> _pickImage() async {
    if (!_isEditing) return; 
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _profileImage = File(image.path));
    }
  }

  // --- PASSWORD UPDATE LOGIC ---
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
      _showSnackBar("Failed to sync password. Verify current one.", Colors.red);
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
          // ✅ ADDED REFRESH INDICATOR
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

  // --- SUB-WIDGETS FOR CLARITY ---

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
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
              colors: [primaryPurple, accentPurple],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              _buildProfileAvatar(),
              const SizedBox(height: 12),
              FadeInUp(
                child: Text(_nameController.text.toUpperCase(), 
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
              Text(_emailController.text, 
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(_isEditing ? Icons.check_circle_rounded : Icons.edit_note_rounded, color: Colors.white, size: 28),
          onPressed: () {
            setState(() => _isEditing = !_isEditing);
            if (!_isEditing) _showSnackBar("Local profile view updated!", Colors.green);
          },
        )
      ],
    );
  }

  Widget _buildProfileAvatar() {
    return GestureDetector(
      onTap: _pickImage,
      child: ZoomIn(
        child: Stack(
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 52,
                backgroundColor: lightLavender,
                backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null 
                    ? Icon(Icons.person_rounded, size: 55, color: primaryPurple) 
                    : null,
              ),
            ),
            if (_isEditing)
              Positioned(
                bottom: 0,
                right: 4,
                child: BounceInDown(
                  child: const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 16,
                    child: Icon(Icons.camera_alt_rounded, size: 16, color: Color(0xFF6A1B9A)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBarSection() {
    return SliverToBoxAdapter(
      child: Container(
        color: accentPurple,
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
              insets: const EdgeInsets.symmetric(horizontal: 20),
            ),
            tabs: const [
              Tab(icon: Icon(Icons.badge_rounded), text: "Identity"),
              Tab(icon: Icon(Icons.door_front_door_rounded), text: "Room"),
              Tab(icon: Icon(Icons.account_balance_wallet_rounded), text: "Fees"),
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
          _buildRoomTab(),
          _buildFinanceTab(),
          _buildSecurityTab(),
        ],
      ),
    );
  }

  Widget _buildIdentityTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        FadeInUp(child: _buildTextField("Full Name", _nameController, Icons.person_outline)),
        FadeInUp(delay: const Duration(milliseconds: 100), child: _buildTextField("Email Address", _emailController, Icons.alternate_email_rounded)),
        FadeInUp(delay: const Duration(milliseconds: 200), child: _buildTextField("Mobile Number", _phoneController, Icons.phone_android_rounded)),
        FadeInUp(delay: const Duration(milliseconds: 300), child: _buildStaticInfoCard("Aadhar Status", _aadhar, Icons.fingerprint_rounded)),
        const SizedBox(height: 20),
        FadeInUp(delay: const Duration(milliseconds: 400), child: _buildTextField("Local Address", _addressController, Icons.home_outlined, isLong: true)),
      ],
    );
  }

  Widget _buildRoomTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        FadeInLeft(child: _buildInfoCard("Educational Institute", _institute, Icons.apartment_rounded, "Official Record")),
        const SizedBox(height: 12),
        FadeInLeft(delay: const Duration(milliseconds: 100), child: _buildInfoCard("Course Name", _course, Icons.school_rounded, "Academic Stream")),
        const SizedBox(height: 12),
        FadeInLeft(delay: const Duration(milliseconds: 200), child: _buildInfoCard("Admission Date", _admissionDate, Icons.calendar_today_rounded, "Enrollment Date")),
        const SizedBox(height: 12),
        FadeInLeft(delay: const Duration(milliseconds: 300), child: _buildInfoCard("Student Status", _status, Icons.verified_user_rounded, "Current Validity")),
      ],
    );
  }

  Widget _buildFinanceTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        FadeInDown(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [primaryPurple, accentPurple]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              children: [
                Text("Current Due Amount", style: TextStyle(color: Colors.white70, fontSize: 14)),
                SizedBox(height: 8),
                Text("₹ 8,450", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildTransactionTile("Monthly Rent - March", "₹ 7,500", "Pending", Colors.orange),
        _buildTransactionTile("Mess Charges - Feb", "₹ 2,400", "Paid", Colors.green),
        _buildTransactionTile("Registration Fee", "₹ 1,000", "Paid", Colors.green),
      ],
    );
  }

  Widget _buildSecurityTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildActionTile("Update Password", "Manage your account safety", Icons.lock_reset_rounded, primaryPurple, _showPasswordSheet),
        const SizedBox(height: 16),
        _buildActionTile("Logout", "Sign out from the application", Icons.logout_rounded, Colors.redAccent, () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          Navigator.popUntil(context, (route) => route.isFirst);
        }),
      ],
    );
  }

  // --- REUSABLE UI HELPERS ---

  Widget _buildTextField(String label, TextEditingController ctrl, IconData icon, {bool isLong = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl,
            enabled: _isEditing,
            maxLines: isLong ? 3 : 1,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: primaryPurple, size: 20),
              filled: true,
              fillColor: _isEditing ? lightLavender.withOpacity(0.3) : cardGrey,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardGrey, borderRadius: BorderRadius.circular(15), border: Border.all(color: lightLavender)),
      child: Row(
        children: [
          Icon(icon, color: primaryPurple, size: 22),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String val, IconData icon, String sub) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: cardGrey, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: lightLavender, child: Icon(icon, color: primaryPurple)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(val, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                Text(sub, style: TextStyle(fontSize: 11, color: primaryPurple.withOpacity(0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(String title, String amount, String status, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardGrey, borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildActionTile(String title, String sub, IconData icon, Color color, VoidCallback tap) {
    return ListTile(
      onTap: tap,
      tileColor: cardGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black45, 
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
            const Text("Change Password", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
              child: const Text("UPDATE PASSWORD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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