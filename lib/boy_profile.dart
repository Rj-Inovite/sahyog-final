import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Add this package
import 'dart:io'; // For File image

class BoyProfile extends StatefulWidget {
  final Map<String, String> userData;
  const BoyProfile({super.key, required this.userData});

  @override
  State<BoyProfile> createState() => _BoyProfileState();
}

class _BoyProfileState extends State<BoyProfile> with TickerProviderStateMixin {
  File? _imageFile; // To store the actual image
  final ImagePicker _picker = ImagePicker();

  // Color Palette
  final Color navyBlue = const Color(0xFF0A1F44);
  final Color primaryBlue = const Color(0xFF1A237E);
  final Color surfaceGrey = const Color(0xFFF8FAFC);
  final Color orangeAccent = const Color(0xFFFFAB40);

  // Function to pick image from Gallery/Camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Compress for better performance
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showPickerMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Photo Gallery'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get name from userData passed during login
    final String displayName = widget.userData['name'] ?? "Student";
    final String displayEmail = widget.userData['email'] ?? "not-provided@college.com";
    final String displayRoom = widget.userData['room'] ?? "N/A";

    return Scaffold(
      backgroundColor: surfaceGrey,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 1. ANIMATED HEADER SECTION ---
            Stack(
              children: [
                Hero(
                  tag: 'profile_bg',
                  child: Container(
                    height: 320,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [navyBlue, primaryBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Text("OFFICIAL PROFILE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                            const SizedBox(width: 40), // Spacer
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Profile Image with Animation
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 70,
                                backgroundColor: Colors.white,
                                // This logic shows the actual file if picked, otherwise default icon
                                backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                                child: _imageFile == null 
                                  ? Icon(Icons.person, size: 80, color: navyBlue) 
                                  : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _showPickerMenu,
                                child: CircleAvatar(
                                  backgroundColor: orangeAccent,
                                  radius: 22,
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      // Syncing Name from Login
                      Text(
                        displayName.toUpperCase(), 
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2)
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          "ROOM: $displayRoom  •  BLOCK-B", 
                          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 2. INFORMATION CARDS ---
                  _buildSectionLabel("Identity Details"),
                  _buildInfoCard([
                    _buildInfoRow(Icons.alternate_email, "Email Address", displayEmail),
                    _buildInfoRow(Icons.badge, "Enrollment ID", "BT/2024/045"),
                    _buildInfoRow(Icons.phone_iphone, "Contact", "+91 98765-XXXXX"),
                  ]),

                  const SizedBox(height: 25),

                  _buildSectionLabel("Hostel Registry"),
                  _buildInfoCard([
                    _buildInfoRow(Icons.apartment, "Wing", "Sahyog Boys Wing"),
                    _buildInfoRow(Icons.person_pin_circle, "Warden", "Mr. Vikram Singh"),
                    
                    // Progress Indicator for Attendance
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Attendance History", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                              Text("92%", style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: 0.92, 
                              backgroundColor: Colors.grey[200], 
                              color: primaryBlue, 
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),

                  const SizedBox(height: 40),
                  
                  // --- 3. TERMINATE SESSION BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Colors.red, width: 1.5)
                        ),
                      ),
                      icon: const Icon(Icons.power_settings_new),
                      label: const Text("TERMINATE SESSION", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper: Section Label
  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 10),
      child: Text(text.toUpperCase(), style: TextStyle(color: navyBlue.withOpacity(0.6), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
    );
  }

  // Helper: Info Card Container
  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(children: children),
    );
  }

  // Helper: Info Row item
  Widget _buildInfoRow(IconData icon, String title, String value) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: surfaceGrey, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: primaryBlue, size: 20),
      ),
      title: Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
      subtitle: Text(value, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }
}