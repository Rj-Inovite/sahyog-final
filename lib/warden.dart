// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:my_app/data/models/warden_list_response.dart';
import 'dart:ui';

// --- YOUR EXISTING IMPORTS ---
import 'register.dart'; 
import 'warden-response.dart'; 
import 'data/models/network/api_service.dart'; 
import 'package:my_app/data/models/network/student_list_response.dart'; 


// --- THEME CONSTANTS ---
const Color sunsetOrange = Color(0xFFFF8C42);
const Color warmYellow = Color.fromRGBO(189, 95, 7, 1);
const Color backgroundWhite = Color(0xFFFAFAFA);
const Color textDark = Color(0xFF2D3436);

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WardenDashboard(userData: {'name': 'Chief Warden'}),
    ));

// --- MAIN DASHBOARD ---
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
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WardenProfilePage())),
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

// --- 1. CONSOLE HOME ---
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
        _metricBox(context, "Staff", "Live", Icons.badge, Colors.green, const StaffManagementPage()),
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

// --- 2. STUDENT DIRECTORY (LIVE API) ---
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
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

// --- 3. LIVE STAFF MANAGEMENT ---
class StaffManagementPage extends StatefulWidget {
  const StaffManagementPage({super.key});

  @override
  State<StaffManagementPage> createState() => _StaffManagementPageState();
}

class _StaffManagementPageState extends State<StaffManagementPage> {
  List<Warden> _wardens = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWardens();
  }

  Future<void> _fetchWardens() async {
    try {
      final response = await apiService.getWardenList();
      if (response != null && response.success) {
        setState(() { _wardens = response.data; _isLoading = false; });
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Staff Management"), backgroundColor: sunsetOrange),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: _wardens.length,
            itemBuilder: (ctx, i) {
              final w = _wardens[i];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text("${w.firstName} ${w.lastName}"),
                  subtitle: Text(w.email),
                  trailing: Text(w.status, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              );
            },
          ),
    );
  }
}

// --- 4. COMPLAINT MANAGEMENT ---
class ComplaintManagementPage extends StatelessWidget {
  const ComplaintManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> complaints = [
      {"id": "#882", "title": "AC Not Working", "status": "Pending", "room": "204"},
      {"id": "#881", "title": "WiFi Connectivity", "status": "In Progress", "room": "105"},
      {"id": "#879", "title": "Water Leakage", "status": "Resolved", "room": "412"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Complaints"), backgroundColor: sunsetOrange),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: complaints.length,
        itemBuilder: (ctx, i) {
          final c = complaints[i];
          return Card(
            child: ListTile(
              leading: Icon(Icons.report_problem, color: c['status'] == 'Resolved' ? Colors.green : Colors.orange),
              title: Text(c['title']!),
              subtitle: Text("Room ${c['room']} | ID: ${c['id']}"),
              trailing: Chip(label: Text(c['status']!, style: const TextStyle(fontSize: 10))),
            ),
          );
        },
      ),
    );
  }
}

// --- 5. ROOM INVENTORY ---
class RoomInventoryPage extends StatelessWidget {
  const RoomInventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Room Inventory"), backgroundColor: sunsetOrange),
      body: GridView.builder(
        padding: const EdgeInsets.all(15),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, mainAxisSpacing: 10, crossAxisSpacing: 10),
        itemCount: 40,
        itemBuilder: (ctx, i) {
          bool isOccupied = i % 3 != 0;
          return Container(
            decoration: BoxDecoration(
              color: isOccupied ? Colors.green.withOpacity(0.8) : Colors.red.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text("${101 + i}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          );
        },
      ),
    );
  }
}

// --- 6. ATTENDANCE MODULE ---
class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Night Attendance"), backgroundColor: sunsetOrange),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: warmYellow.withOpacity(0.1),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(children: [Text("Present"), Text("142", style: TextStyle(fontWeight: FontWeight.bold))]),
                Column(children: [Text("Absent"), Text("12", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red))]),
                Column(children: [Text("On Leave"), Text("05", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))]),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: 10,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (ctx, i) => ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text("Student $i"),
                subtitle: const Text("Last Entry: 09:30 PM"),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- 7. GATE RECORDS ---
class GateRecordsPage extends StatelessWidget {
  const GateRecordsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gate Security Logs"), backgroundColor: sunsetOrange),
      body: ListView.builder(
        itemCount: 15,
        itemBuilder: (ctx, i) => ListTile(
          leading: Icon(i % 2 == 0 ? Icons.login : Icons.logout, color: i % 2 == 0 ? Colors.green : Colors.red),
          title: Text("Student Name $i"),
          subtitle: Text(i % 2 == 0 ? "Entry Time: 06:15 PM" : "Exit Time: 08:00 AM"),
          trailing: const Text("Mar 17", style: TextStyle(color: Colors.grey)),
        ),
      ),
    );
  }
}

// --- 8. OCCUPANCY STATS ---
class OccupancyStatsPage extends StatelessWidget {
  const OccupancyStatsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Occupancy Analytics"), backgroundColor: sunsetOrange),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Total Capacity: 200 Beds", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            LinearProgressIndicator(value: 0.94, minHeight: 20, color: sunsetOrange, backgroundColor: Colors.grey[300]),
            const SizedBox(height: 10),
            const Text("94% Occupied"),
            const SizedBox(height: 40),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(label: "Floor 1", value: "100%"),
                _StatItem(label: "Floor 2", value: "92%"),
                _StatItem(label: "Floor 3", value: "88%"),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  const _StatItem({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(children: [Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]);
}

// --- SHINY REGISTRY BUTTON ---
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

// --- ADDITIONAL PAGES ---
class WardenInboxPage extends StatelessWidget {
  const WardenInboxPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text("Warden Chat Inbox"));
}

class WardenProfilePage extends StatelessWidget {
  const WardenProfilePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Warden Profile")), body: const Center(child: Text("Profile Info")));
}

class AdminSetupPage extends StatelessWidget {
  const AdminSetupPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(children: [const ListTile(leading: Icon(Icons.settings), title: Text("General Settings")), const Divider(), ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text("Logout"), onTap: () => Navigator.pop(context))]);
}