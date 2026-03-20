import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

// --- THEME CONSTANTS (Matching Sahyog Dashboard) ---
const Color primaryYellow = Color.from(alpha: 1, red: 0.188, green: 0.294, blue: 0.78);
const Color deepAmber = Color.fromRGBO(63, 78, 214, 1);
const Color bgWhite = Color(0xFFFAFAFA);
const Color cardWhite = Colors.white;
const Color sunsetOrange = Color.fromRGBO(81, 83, 223, 1);

class WardenProfilePage extends StatefulWidget {
  final Map<String, String>? userData; // Added to accept login credentials

  const WardenProfilePage({super.key, this.userData});

  @override
  State<WardenProfilePage> createState() => _WardenProfilePageState();
}

class _WardenProfilePageState extends State<WardenProfilePage> with SingleTickerProviderStateMixin {
  // --- STATE VARIABLES ---
  File? _image;
  final ImagePicker _picker = ImagePicker();
  Timer? _refreshTimer;
  bool _isEditing = false;
  
  // Dynamic Data (Extracted from Passed userData)
  late String _userEmail; 
  late String _displayName;
  
  // Controllers for Editing
  late TextEditingController _nameController;
  late TextEditingController _wingController;
  late TextEditingController _shiftController;

  @override
  void initState() {
    super.initState();
    
    // Logic: Extract data from the passed Map or use defaults if null
    _userEmail = widget.userData?['email'] ?? "warden@sahyog.com";
    
    // If name exists in Map, use it. Otherwise, extract from email prefix.
    String rawName = widget.userData?['name'] ?? _userEmail.split('@')[0];
    _displayName = rawName.toUpperCase();
    
    _nameController = TextEditingController(text: _displayName);
    _wingController = TextEditingController(text: "Girls Wing - Block Alpha");
    _shiftController = TextEditingController(text: "09:00 AM - 08:00 PM");

    // --- HIGH FREQUENCY RELOAD: Every 10 Seconds ---
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _syncProfileData();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _nameController.dispose();
    _wingController.dispose();
    _shiftController.dispose();
    super.dispose();
  }

  void _syncProfileData() {
    debugPrint("Sahyog Profile: Background Syncing Data for $_userEmail...");
    // Future API call to refresh warden details can be placed here
  }

  // --- IMAGE PICKER LOGIC ---
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgWhite,
      // --- APPBAR ---
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("My Profile", 
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: 1.1)),
        backgroundColor: primaryYellow,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check_circle : Icons.edit_note_rounded, 
                  color: _isEditing ? Colors.green : Colors.black87, size: 28),
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  _displayName = _nameController.text;
                  // Here you would typically call an API to save the new name
                }
                _isEditing = !_isEditing;
              });
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildAnimatedHeader(),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Personal Information"),
                  _buildInfoCard(),
                  const SizedBox(height: 40),
                  _buildLogoutButton(),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text("System Refreshes Every 10s", 
                      style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 1. ANIMATED PROFILE HEADER ---
  Widget _buildAnimatedHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: primaryYellow,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10))],
      ),
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 6),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15)],
                ),
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.white,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null 
                      ? const Icon(Icons.person_rounded, size: 90, color: deepAmber) 
                      : null,
                ),
              ),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                  child: const Icon(Icons.add_a_photo_rounded, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(_displayName, 
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black87)),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
            child: const Text("OFFICIAL WARDEN", 
              style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ),
        ],
      ),
    );
  }

  // --- 2. PERSONAL INFO CARD ---
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          _infoRow(Icons.person_outline, "Full Name", _nameController, isEditable: _isEditing),
          const Divider(height: 40),
          _infoRow(Icons.alternate_email_rounded, "Email Address", TextEditingController(text: _userEmail), isEditable: false),
          const Divider(height: 40),
          _infoRow(Icons.apartment_rounded, "Assigned Wing", _wingController, isEditable: _isEditing),
          const Divider(height: 40),
          _infoRow(Icons.access_time_filled_rounded, "Shift Timing", _shiftController, isEditable: _isEditing),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, TextEditingController controller, {required bool isEditable}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: primaryYellow.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: deepAmber, size: 24),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              isEditable 
                ? TextField(
                    controller: controller,
                    autofocus: true,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    decoration: const InputDecoration(isDense: true, border: UnderlineInputBorder()),
                  )
                : Text(controller.text, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.black87)),
            ],
          ),
        )
      ],
    );
  }

  // --- 3. LOGOUT BUTTON ---
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () {
          // Clears navigation stack and returns to login
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.red, width: 1)),
        ),
        icon: const Icon(Icons.logout_rounded),
        label: const Text("LOGOUT FROM SAHYOG", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.1)),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 15),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87)),
    );
  }
}