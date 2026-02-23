import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class GirlProfile extends StatefulWidget {
  final Map<String, String> userData;
  const GirlProfile({super.key, required this.userData});

  @override
  State<GirlProfile> createState() => _GirlProfileState();
}

class _GirlProfileState extends State<GirlProfile> with SingleTickerProviderStateMixin {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  // Premium Girl Theme Palette
  final Color primaryPurple = const Color.fromARGB(255, 238, 71, 163); 
  final Color accentRose = const Color(0xFFFF80AB);   
  final Color bgLavender = const Color(0xFFF9F8FF);   
  final Color textDark = const Color.fromRGBO(231, 106, 154, 1);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Compresses image for better performance
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permission denied or Error accessing device storage")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLavender,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildAnimatedHeader(),
              const SizedBox(height: 70),
              _buildLifeStats(), // New Premium Section
              _buildPersonalDetails(),
              _buildHostelDetails(),
              _buildSafetySupport(),
              const SizedBox(height: 30),
              _buildLogoutButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ✨ Animated Header with Profile Sync
  Widget _buildAnimatedHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 280,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryPurple, accentRose],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(60),
              bottomRight: Radius.circular(60),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildTopNav(),
                const SizedBox(height: 10),
                Hero(
                  tag: 'profileName',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(widget.userData['name'] ?? "Student", 
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const Text("✨ Living my best life at Sahyog ✨", 
                  style: TextStyle(color: Color.fromARGB(179, 230, 208, 208), fontSize: 12)),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: -60,
          left: 0,
          right: 0,
          child: Center(
            child: _buildProfileAvatar(),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileAvatar() {
    return GestureDetector(
      onTap: () => _showImageSourceActionSheet(),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [BoxShadow(color: primaryPurple.withOpacity(0.4), blurRadius: 20)],
            ),
            child: CircleAvatar(
              radius: 70,
              backgroundColor: Colors.purple.shade50,
              backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
              child: _imageFile == null 
                ? Icon(Icons.add_a_photo_outlined, size: 40, color: primaryPurple) 
                : null,
            ),
          ),
          Positioned(
            bottom: 5,
            right: 5,
            child: CircleAvatar(
              backgroundColor: primaryPurple,
              radius: 18,
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  // 💎 New Life-Stats Section (Horizontal Scroll)
  Widget _buildLifeStats() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _statItem("Attendance", "94%", Icons.calendar_today, Colors.green),
          _statItem("Coins", "1,200", Icons.stars_rounded, Colors.orange),
          _statItem("Mess Rating", "4.8", Icons.restaurant, Colors.pink),
          _statItem("Rank", "#12", Icons.emoji_events, Colors.purple),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color col) {
    return Container(
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: col.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: col, size: 20),
          const SizedBox(height: 5),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: textDark)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  // 🌸 Personal Info (Enhanced)
  Widget _buildPersonalDetails() {
    return _buildSectionCard(
      title: "Personal Information",
      children: [
        _detailRow(Icons.face, "Full Name", widget.userData['name'] ?? "N/A"),
        _detailRow(Icons.fingerprint, "Roll Number", "CS-2026-441"),
        _detailRow(Icons.menu_book, "Year", "3rd Year (Sem 6)"),
        _detailRow(Icons.local_hospital, "Health Group", "O+ Positive"),
        _detailRow(Icons.emergency, "Parent Contact", "+91 8877665544"),
      ],
    );
  }

  // 🏥 Safety & Wellbeing (Animated SOS)
  Widget _buildSafetySupport() {
    return _buildSectionCard(
      title: "Safety & Wellbeing",
      children: [
        Row(
          children: [
            Expanded(child: _actionButton(Icons.call, "Warden", primaryPurple, () {})),
            const SizedBox(width: 10),
            Expanded(child: _actionButton(Icons.notifications_active, "SOS", Colors.redAccent, () {})),
          ],
        ),
        const SizedBox(height: 15),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.health_and_safety, color: Colors.teal),
          title: Text("Mental Health Support", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          subtitle: Text("24/7 Counseling Available", style: TextStyle(fontSize: 11)),
          trailing: Icon(Icons.arrow_forward_ios, size: 12),
        )
      ],
    );
  }

  // --- Reusable UI Components ---

  Widget _buildTopNav() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
          const Text("MY PROFILE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          IconButton(icon: const Icon(Icons.settings, color: Colors.white), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryPurple)),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: primaryPurple.withOpacity(0.5)),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textDark)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHostelDetails() {
    return _buildSectionCard(
      title: "Hostel Life",
      children: [
        _detailRow(Icons.meeting_room, "Current Room", widget.userData['room'] ?? "101"),
        _detailRow(Icons.apartment, "Wing", "B-Block, Lavender Wing"),
        const SizedBox(height: 10),
        const Text("Monthly Attendance", style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: 0.94,
            minHeight: 8,
            backgroundColor: Colors.purple.shade50,
            color: accentRose,
          ),
        ),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return TextButton.icon(
      onPressed: () => Navigator.pop(context),
      icon: const Icon(Icons.exit_to_app, color: Colors.grey),
      label: const Text("CLOSE SESSION", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
    );
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Profile Photo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _pickBtn(Icons.image, "Gallery", ImageSource.gallery),
                _pickBtn(Icons.camera_alt, "Camera", ImageSource.camera),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pickBtn(IconData icon, String label, ImageSource src) {
    return Column(
      children: [
        IconButton(
          onPressed: () {
            Navigator.pop(context);
            _pickImage(src);
          },
          icon: Icon(icon, size: 40, color: primaryPurple),
        ),
        Text(label),
      ],
    );
  }
}