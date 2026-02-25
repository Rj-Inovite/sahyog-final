import 'package:flutter/material.dart';

// --- THEME CONSTANTS ---
const Color primaryYellow = Color(0xFFF9D423);
const Color deepAmber = Color(0xFFFFB300);
const Color bgWhite = Color(0xFFFAFAFA);
const Color cardWhite = Colors.white;

class WardenProfilePage extends StatefulWidget {
  const WardenProfilePage({super.key});

  @override
  State<WardenProfilePage> createState() => _WardenProfilePageState();
}

class _WardenProfilePageState extends State<WardenProfilePage> {
  bool isAvailable = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgWhite,
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: primaryYellow,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildDutyStatusCard(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Warden Statistics"),
                  _buildStatsGrid(),
                  const SizedBox(height: 25),
                  _buildSectionTitle("Personal Information"),
                  _buildInfoCard(),
                  const SizedBox(height: 25),
                  _buildSectionTitle("Account Actions"),
                  _buildActionList(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 1. PROFILE HEADER WITH IMAGE PICKER ---
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: primaryYellow,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)
                  ],
                ),
                child: const CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 80, color: deepAmber),
                  // Use backgroundImage: FileImage(_image) once you pick an image
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => debugPrint("Trigger Image Picker"),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text("Chief Warden Ruchi", 
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
          const Text("Emp ID: SAH-WRD-2026", 
            style: TextStyle(fontSize: 14, color: Colors.black54, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  // --- 2. DUTY STATUS TOGGLE ---
  Widget _buildDutyStatusCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.circle, color: isAvailable ? Colors.green : Colors.grey, size: 16),
        title: const Text("Duty Status", style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(isAvailable ? "Available for Students" : "Currently Off-Duty"),
        trailing: Switch(
          value: isAvailable,
          activeColor: deepAmber,
          onChanged: (val) => setState(() => isAvailable = val),
        ),
      ),
    );
  }

  // --- 3. WARDEN STATS GRID ---
  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.5,
      children: [
        _statItem("Students", "240", Icons.people, Colors.blue),
        _statItem("Complaints", "08", Icons.warning_amber_rounded, Colors.red),
        _statItem("Leave Req", "12", Icons.assignment_late, Colors.orange),
        _statItem("Attendance", "98%", Icons.fact_check, Colors.green),
      ],
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  // --- 4. PERSONAL INFO ---
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _infoRow(Icons.email_outlined, "Email", "ruchi.warden@sahyog.edu"),
          const Divider(height: 30),
          _infoRow(Icons.phone_outlined, "Contact", "+91 98765-43210"),
          const Divider(height: 30),
          _infoRow(Icons.apartment_outlined, "Assigned Wing", "Girls Wing - Block Alpha"),
          const Divider(height: 30),
          _infoRow(Icons.calendar_today_outlined, "Shift Time", "09:00 AM - 08:00 PM"),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: deepAmber, size: 22),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        )
      ],
    );
  }

  // --- 5. ACTION LIST ---
  Widget _buildActionList() {
    return Column(
      children: [
        _actionTile(Icons.history, "Duty History", () {}),
        _actionTile(Icons.lock_outline, "Change Password", () {}),
        _actionTile(Icons.notifications_none, "Notification Settings", () {}),
        _actionTile(Icons.help_outline, "Emergency Contacts", () {}),
        const SizedBox(height: 10),
        _actionTile(Icons.logout, "Logout", () {}, isLogout: true),
      ],
    );
  }

  Widget _actionTile(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isLogout ? Colors.red.withValues(alpha: 0.1) : primaryYellow.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isLogout ? Colors.red : deepAmber, size: 20),
      ),
      title: Text(title, style: TextStyle(
        fontWeight: FontWeight.w500, 
        color: isLogout ? Colors.red : Colors.black87
      )),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }
}