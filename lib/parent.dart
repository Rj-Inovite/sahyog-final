// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:my_app/data/models/child_profile_response.dart';
import 'package:my_app/data/models/network/api_service.dart';

class ParentPortal extends StatefulWidget {
  final Map<String, String> userData;
  const ParentPortal({super.key, required this.userData});

  @override
  State<ParentPortal> createState() => _ParentPortalState();
}

class _ParentPortalState extends State<ParentPortal> {
  // Theme Colors
  final Color primaryGreen = const Color(0xFF2E7D32);
  final Color bgGreen = const Color(0xFFF1F8E9);
  final Color accentOrange = const Color(0xFFF57C00);

  ChildData? childData;
  bool isLoading = true;
  String currentView = "Dashboard"; 
  int _selectedIndex = 0; // For the Bottom Footer

  // Leave Request State
  Map<String, dynamic>? pendingLeaveRequest = {
    "id": 101,
    "reason": "Diwali Festival Leave",
    "from": "2026-10-28",
    "to": "2026-11-01",
    "status": "Pending"
  };

  @override
  void initState() {
    super.initState();
    _fetchChildInfo();
  }

  Future<void> _fetchChildInfo() async {
    setState(() => isLoading = true);
    final response = await apiService.getChildProfile();
    if (response != null && response.success) {
      setState(() {
        childData = response.data;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleLeaveDecision(bool isApproved) async {
    if (pendingLeaveRequest == null) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    await Future.delayed(const Duration(seconds: 1)); 
    Navigator.pop(context); 
    setState(() => pendingLeaveRequest = null);
    _showSnackBar("Leave ${isApproved ? 'Approved' : 'Rejected'} successfully.", isApproved ? Colors.green : Colors.red);
  }

  void _showSnackBar(String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: bgColor, behavior: SnackBarBehavior.floating),
    );
  }

  void _showProfileBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.70,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            CircleAvatar(radius: 50, backgroundColor: bgGreen, child: Icon(Icons.person, size: 50, color: primaryGreen)),
            const SizedBox(height: 15),
            Text(widget.userData['name'] ?? 'Parent Name', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(height: 40),
            _profileDetailRow("Student Name", childData?.fullName ?? "Loading..."),
            _profileDetailRow("Student ID", childData?.studentId ?? "N/A"),
            _profileDetailRow("Mobile", widget.userData['mobile'] ?? "N/A"),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[50], foregroundColor: Colors.red, minimumSize: const Size(double.infinity, 50)),
              child: const Text("LOGOUT"),
            )
          ],
        ),
      ),
    );
  }

  Widget _profileDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.grey)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: currentView != "Dashboard" 
          ? IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => setState(() => currentView = "Dashboard"))
          : null,
        title: Text(currentView == "Dashboard" ? "Parental Monitoring" : currentView, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchChildInfo),
          GestureDetector(
            onTap: _showProfileBottomSheet,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: CircleAvatar(radius: 16, backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white, size: 18)),
            ),
          )
        ],
      ),
      body: isLoading 
        ? Center(child: CircularProgressIndicator(color: primaryGreen))
        : AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _getSelectedBody(),
          ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _getSelectedBody() {
    if (_selectedIndex == 1) return _buildAttendanceContent();
    if (_selectedIndex == 2) return _buildSettingsContent();
    
    // Switch between Dashboard and Sub-views (Grid items)
    switch (currentView) {
      case "Leave logs": return _buildLeaveLogContent();
      case "Mess Menu": return _buildMessMenuContent();
      case "Fees Status": return _buildFeeStatusContent();
      case "Security": return _buildSecurityContent();
      default: return _buildDashboard();
    }
  }

  // ================= DASHBOARD =================
  Widget _buildDashboard() {
    return SingleChildScrollView(
      key: const ValueKey("Dashboard"),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          
          // RESTORED CHILD PROFILE DISPLAY
          _buildSectionHeader("My Children"),
          _buildChildSelector(),
          const SizedBox(height: 25),

          // RESTORED LEAVE APPROVAL NOTIFICATION
          if (pendingLeaveRequest != null) ...[
            _buildSectionHeader("Pending Leave Request"),
            _buildLeaveApprovalCard(),
            const SizedBox(height: 25),
          ],
          
          _buildSectionHeader("Real-time Overview"),
          _buildChildQuickOverview(),
          const SizedBox(height: 25),
          
          _buildSectionHeader("Academic Details"),
          _buildInfoCard(),
          const SizedBox(height: 25),
          
          _buildSectionHeader("Management Hub"),
          _buildActionGrid(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Welcome, ${widget.userData['name'] ?? 'Parent'}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const Text("Sahyog Secure Sync: Monitoring Active", style: TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  Widget _buildChildSelector() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primaryGreen, width: 2)),
          child: CircleAvatar(
            radius: 35,
            backgroundColor: bgGreen,
            child: Icon(Icons.face_retouching_natural, color: primaryGreen, size: 35),
          ),
        ),
        const SizedBox(height: 8),
        Text(childData?.fullName ?? "Child Name", style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildLeaveApprovalCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentOrange.withOpacity(0.5), width: 1.5),
        boxShadow: [BoxShadow(color: accentOrange.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(Icons.pending_actions, color: accentOrange), const SizedBox(width: 10), Text("Leave Approval Needed", style: TextStyle(fontWeight: FontWeight.bold, color: accentOrange))]),
          const SizedBox(height: 12),
          Text("${childData?.fullName} applied for ${pendingLeaveRequest!['reason']}", style: const TextStyle(fontWeight: FontWeight.w500)),
          Text("Dates: ${pendingLeaveRequest!['from']} to ${pendingLeaveRequest!['to']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => _handleLeaveDecision(false), child: const Text("REJECT"), style: OutlinedButton.styleFrom(foregroundColor: Colors.red))),
              const SizedBox(width: 10),
              Expanded(child: ElevatedButton(onPressed: () => _handleLeaveDecision(true), child: const Text("APPROVE"), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildChildQuickOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryGreen, Colors.green.shade900]), borderRadius: BorderRadius.circular(20)),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _miniStat("Hostel ID", "#${childData?.hostelInfo?.hostelId ?? '101'}", Colors.white),
            const VerticalDivider(color: Colors.white24, thickness: 1),
            _miniStat("Status", "IN-CAMPUS", Colors.white),
            const VerticalDivider(color: Colors.white24, thickness: 1),
            _miniStat("Attendance", "94%", Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) => Column(children: [Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)), Text(label, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)))]);

  Widget _buildActionGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4,
      children: [
        _actionCard(Icons.history, "Leave logs", Colors.indigo),
        _actionCard(Icons.restaurant_menu, "Mess Menu", Colors.orange),
        _actionCard(Icons.receipt_long, "Fees Status", Colors.redAccent),
        _actionCard(Icons.shield_outlined, "Security", Colors.blueGrey),
      ],
    );
  }

  Widget _actionCard(IconData icon, String title, Color color) {
    return GestureDetector(
      onTap: () => setState(() => currentView = title),
      child: Container(
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: color.withOpacity(0.2))),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: color, size: 30), const SizedBox(height: 8), Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color))]),
      ),
    );
  }

  // ================= CONTENT VIEWS =================

  Widget _buildAttendanceContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Monthly Record - March 2026", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 15),
        _attendanceItem("19 Mar", "Present", "08:15 AM"),
        _attendanceItem("18 Mar", "Present", "08:10 AM"),
        _attendanceItem("17 Mar", "Absent", "-"),
        _attendanceItem("16 Mar", "Present", "08:05 AM"),
      ],
    );
  }

  Widget _attendanceItem(String date, String status, String time) {
    return Card(
      child: ListTile(
        title: Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Check-in: $time"),
        trailing: Text(status, style: TextStyle(color: status == "Present" ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSettingsContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(leading: const Icon(Icons.notifications), title: const Text("Push Notifications"), trailing: Switch(value: true, onChanged: (v){})),
        const Divider(),
        ListTile(leading: const Icon(Icons.lock), title: const Text("Change Password"), onTap: (){}),
        const Divider(),
        ListTile(leading: const Icon(Icons.help), title: const Text("Help & Support"), onTap: (){}),
        const Divider(),
        ListTile(leading: const Icon(Icons.info), title: const Text("App Version"), subtitle: const Text("v2.4.0")),
      ],
    );
  }

  Widget _buildMessMenuContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _menuTile("Breakfast", "Poha, Tea, Banana", "08:00 AM"),
        _menuTile("Lunch", "Roti, Dal, Rice, Salad", "01:30 PM"),
        _menuTile("Dinner", "Paneer, Chapati, Gulab Jamun", "08:30 PM"),
      ],
    );
  }

  Widget _menuTile(String meal, String menu, String time) {
    return Card(child: ListTile(title: Text(meal, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(menu), trailing: Text(time, style: TextStyle(color: primaryGreen))));
  }

  Widget _buildFeeStatusContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _feeRow("Annual Fee", "₹80,000", Colors.black),
          _feeRow("Paid", "₹60,000", Colors.green),
          _feeRow("Remaining", "₹20,000", Colors.red),
          const Spacer(),
          ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, minimumSize: const Size(double.infinity, 50)), child: const Text("PAY NOW", style: TextStyle(color: Colors.white)))
        ],
      ),
    );
  }

  Widget _feeRow(String label, String value, Color color) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label), Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color))]));
  }

  Widget _buildLeaveLogContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _leaveLogItem("Sick Leave", "10 Mar", "Approved"),
        _leaveLogItem("Home Visit", "01 Feb", "Completed"),
      ],
    );
  }

  Widget _leaveLogItem(String reason, String date, String status) {
    return Card(child: ListTile(title: Text(reason), subtitle: Text(date), trailing: Text(status, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))));
  }

  Widget _buildSecurityContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(leading: Icon(Icons.face), title: Text("Biometric Enrollment"), subtitle: Text("Status: Verified")),
        ListTile(leading: Icon(Icons.location_on), title: Text("Geo-Fencing"), subtitle: Text("Status: Inside Campus")),
        ListTile(leading: Icon(Icons.call), title: Text("Emergency Contact"), subtitle: Text("Warden: +91 9988776655")),
      ],
    );
  }

  // --- REUSABLE UI ---

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          _infoRow(Icons.school, "Institute", childData?.academicDetails?.institute ?? "Sahyog Institute"),
          const Divider(),
          _infoRow(Icons.book, "Course", childData?.academicDetails?.course ?? "General"),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [Icon(icon, size: 20, color: primaryGreen), const SizedBox(width: 15), Text(label, style: const TextStyle(color: Colors.grey)), const Spacer(), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]));
  }

  Widget _buildSectionHeader(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryGreen)));
  }

  // RESTORED FOOTER: Home, Attendance, Settings
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: primaryGreen,
      unselectedItemColor: Colors.grey,
      onTap: (index) => setState(() {
        _selectedIndex = index;
        currentView = "Dashboard"; // Reset view when switching tabs
      }),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Attendance"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      ],
    );
  }
}