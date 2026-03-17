// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:my_app/data/models/warden_list_response.dart';
import 'dart:ui';

// --- YOUR EXISTING IMPORTS ---
import 'register.dart'; 
import 'warden-response.dart'; 
import 'data/models/network/api_service.dart'; 
import 'package:my_app/data/models/network/student_list_response.dart'; 
// Import the Warden Response model


// --- THEME CONSTANTS ---
const Color sunsetOrange = Color(0xFFFF8C42);
const Color warmYellow = Color.fromRGBO(189, 95, 7, 1);
const Color backgroundWhite = Color(0xFFFAFAFA);
const Color textDark = Color(0xFF2D3436);

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WardenDashboard(userData: {'name': 'Chief Warden'}),
    ));

// --- MAIN DASHBOARD (UNCHANGED) ---
class WardenDashboard extends StatefulWidget {
  final Map<String, String> userData;
  const WardenDashboard({super.key, required this.userData});

  @override
  State<WardenDashboard> createState() => _WardenDashboardState();
}

class _WardenDashboardState extends State<WardenDashboard> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
    const ConsoleHome(),
    const StudentDirectoryPage(), 
    const WardenInboxPage(), 
    const AdminSetupPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      appBar: AppBar(
        title: const Text("Sahyog Warden Console",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        backgroundColor: sunsetOrange,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 30, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const WardenProfilePage()));
            },
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: sunsetOrange,
          unselectedItemColor: Colors.grey,
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: "Console"),
            BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: "Students"),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: "Inbox"),
            BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: "Settings"),
          ],
        ),
      ),
    );
  }
}

// --- 1. CONSOLE HOME (UNCHANGED) ---
class ConsoleHome extends StatelessWidget {
  const ConsoleHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeroSection(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Live Statistics", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _buildMetricsRow(context),
                const SizedBox(height: 25),
                const ShinyRegistryButton(),
                const SizedBox(height: 25),
                const Text("Management Modules", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _buildModuleGrid(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [sunsetOrange, warmYellow]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Campus Alpha", style: TextStyle(color: Colors.white70, fontSize: 16)),
          Text("Session 2026-27", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMetricsRow(BuildContext context) {
    return Row(
      children: [
        _metricBox(context, "Occupancy", "94%", Icons.bed, Colors.blue, const OccupancyStatsPage()),
        _metricBox(context, "Complaints", "03", Icons.warning, Colors.red, const ComplaintManagementPage()),
        // Clicking this will now lead to the Live Staff Management Page
        _metricBox(context, "Staff", "12/12", Icons.badge, Colors.green, const StaffManagementPage()),
      ],
    );
  }

  Widget _metricBox(BuildContext context, String t, String v, IconData i, Color c, Widget target) {
    return Expanded(
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => target)),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Icon(i, color: c),
                Text(v, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(t, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModuleGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: [
        _moduleTile(context, "Room Allotment", Icons.hotel, const RoomInventoryPage()),
        _moduleTile(context, "Attendance", Icons.fact_check, const AttendancePage()),
        _moduleTile(context, "Staff Management", Icons.engineering, const StaffManagementPage()),
        _moduleTile(context, "Gate Records", Icons.security, const GateRecordsPage()),
      ],
    );
  }

  Widget _moduleTile(BuildContext context, String t, IconData i, Widget target) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => target)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(i, color: sunsetOrange, size: 30),
            const SizedBox(height: 5),
            Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// --- 2. STUDENT DIRECTORY (PRESERVED) ---
class StudentDirectoryPage extends StatefulWidget {
  const StudentDirectoryPage({super.key});

  @override
  State<StudentDirectoryPage> createState() => _StudentDirectoryPageState();
}

class _StudentDirectoryPageState extends State<StudentDirectoryPage> {
  List<Student> _students = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final response = await apiService.getStudentList();
      if (response != null && response.success) {
        setState(() { _students = response.students; _isLoading = false; });
      } else {
        setState(() { _errorMessage = "Unable to fetch student list."; _isLoading = false; });
      }
    } catch (e) {
      setState(() { _errorMessage = "Connection error."; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: sunsetOrange));
    if (_errorMessage != null) return Center(child: Text(_errorMessage!));
    return RefreshIndicator(
      onRefresh: _fetchStudents,
      child: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: _students.length,
        itemBuilder: (ctx, i) => _buildStudentCard(_students[i]),
      ),
    );
  }

  Widget _buildStudentCard(Student student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: sunsetOrange.withOpacity(0.2), child: Text(student.firstName[0])),
        title: Text("${student.firstName} ${student.lastName ?? ''}"),
        subtitle: Text("ID: ${student.studentCode}"),
      ),
    );
  }
}

// --- NEW: STAFF MANAGEMENT (LIVE INTEGRATED) ---
class StaffManagementPage extends StatefulWidget {
  const StaffManagementPage({super.key});

  @override
  State<StaffManagementPage> createState() => _StaffManagementPageState();
}

class _StaffManagementPageState extends State<StaffManagementPage> {
  List<Warden> _wardens = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchWardens();
  }

  Future<void> _fetchWardens() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final response = await apiService.getWardenList();
      if (response != null && response.success) {
        setState(() {
          _wardens = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Unable to fetch staff records.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "API Error: Please check connection.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      appBar: AppBar(
        title: const Text("Staff Directory"),
        backgroundColor: sunsetOrange,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: sunsetOrange))
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : RefreshIndicator(
                  onRefresh: _fetchWardens,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: _wardens.length,
                    itemBuilder: (ctx, i) => _buildWardenCard(_wardens[i]),
                  ),
                ),
    );
  }

  Widget _buildWardenCard(Warden warden) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: warmYellow.withOpacity(0.1),
          child: Text(warden.firstName[0], style: const TextStyle(color: warmYellow)),
        ),
        title: Text("${warden.firstName} ${warden.lastName}", 
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Mob: ${warden.mobile}"),
            Text(warden.email, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: warden.status == 'active' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(warden.status.toUpperCase(), 
            style: TextStyle(color: warden.status == 'active' ? Colors.green : Colors.red, fontSize: 10)),
        ),
      ),
    );
  }
}

// --- REMAINING UI (PRESERVED) ---
class ShinyRegistryButton extends StatefulWidget {
  const ShinyRegistryButton({super.key});
  @override
  State<ShinyRegistryButton> createState() => _ShinyRegistryButtonState();
}

class _ShinyRegistryButtonState extends State<ShinyRegistryButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: double.infinity, height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: const [warmYellow, Colors.white, warmYellow],
              stops: [_controller.value - 0.2, _controller.value, _controller.value + 0.2],
            ),
          ),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterStudent())),
            icon: const Icon(Icons.app_registration_rounded, color: textDark),
            label: const Text("NEW STUDENT REGISTRY", style: TextStyle(color: textDark, fontWeight: FontWeight.w900)),
          ),
        );
      },
    );
  }
}

// OTHER CLASSES (UNCHANGED)
class RoomInventoryPage extends StatelessWidget {
  const RoomInventoryPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Room Inventory"), backgroundColor: sunsetOrange));
}
class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Attendance"), backgroundColor: sunsetOrange));
}
class GateRecordsPage extends StatelessWidget {
  const GateRecordsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Gate Security"), backgroundColor: sunsetOrange));
}
class ComplaintManagementPage extends StatelessWidget {
  const ComplaintManagementPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Complaints"), backgroundColor: sunsetOrange));
}
class OccupancyStatsPage extends StatelessWidget {
  const OccupancyStatsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Occupancy Stats"), backgroundColor: sunsetOrange));
}
class WardenProfilePage extends StatelessWidget {
  const WardenProfilePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Profile"), backgroundColor: sunsetOrange));
}
class AdminSetupPage extends StatelessWidget {
  const AdminSetupPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(children: [const ListTile(leading: Icon(Icons.settings), title: Text("General Settings")), const Divider(), ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text("Logout"), onTap: () => Navigator.pop(context))]);
}