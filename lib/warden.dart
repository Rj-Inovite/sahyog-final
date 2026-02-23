import 'package:flutter/material.dart';

// --- THEME CONSTANTS ---
const Color sunsetOrange = Color(0xFFFF8C42);
const Color warmYellow = Color(0xFFF9D423);
const Color primaryAmber = Color(0xFFFFB300);
const Color backgroundWhite = Color(0xFFFAFAFA);
const Color textDark = Color(0xFF2D3436);

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WardenDashboard(userData: {'name': 'Chief Warden'}),
    ));

// --- MAIN DASHBOARD WITH PERSISTENT NAV ---
class WardenDashboard extends StatefulWidget {
  final Map<String, String> userData;
  const WardenDashboard({super.key, required this.userData});

  @override
  State<WardenDashboard> createState() => _WardenDashboardState();
}

class _WardenDashboardState extends State<WardenDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: sunsetOrange,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 30),
            onPressed: () {
              // Redirection to warden_profile.dart
              print("Navigating to warden_profile.dart");
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
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
                const Text("Management Modules", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _buildModuleGrid(context),
                const SizedBox(height: 30),
                const ShinyAuthButton(), // The Custom Animated Button
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
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(i, color: sunsetOrange, size: 30),
            Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// --- ANIMATED SHINY BUTTON ---
class ShinyAuthButton extends StatefulWidget {
  const ShinyAuthButton({super.key});

  @override
  State<ShinyAuthButton> createState() => _ShinyAuthButtonState();
}

class _ShinyAuthButtonState extends State<ShinyAuthButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: const [sunsetOrange, Colors.white, sunsetOrange],
              stops: [_controller.value - 0.1, _controller.value, _controller.value + 0.1],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [BoxShadow(color: sunsetOrange.withOpacity(0.3), blurRadius: 10)],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            onPressed: () => print("Navigating to warden_scan.dart"),
            child: const Text("ADMINISTRATOR AUTHENTICATION", 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          ),
        );
      },
    );
  }
}

// --- 2. ROOM INVENTORY (WITH RESIDENT NAMES) ---
class RoomInventoryPage extends StatelessWidget {
  const RoomInventoryPage({super.key});

  void _showRoomSheet(BuildContext context, int roomNum, bool occupied) {
    // Mock Data for Green Rooms
    final List<String> residents = occupied ? ["Aryan Verma", "Rahul Singh", "Deepak Jha"] : [];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Room #$roomNum Status", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            if (occupied) ...[
              const Text("Current Residents:", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...residents.map((name) => ListTile(
                leading: const Icon(Icons.person, color: sunsetOrange),
                title: Text(name),
                dense: true,
              )),
            ] else 
              const Text("This room is currently VACANT and ready for allotment.", style: TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: sunsetOrange),
                onPressed: () => Navigator.pop(ctx),
                child: const Text("CLOSE", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Room Inventory"), backgroundColor: sunsetOrange),
      body: GridView.builder(
        padding: const EdgeInsets.all(15),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 10, crossAxisSpacing: 10),
        itemCount: 40,
        itemBuilder: (ctx, i) {
          bool isOccupied = i % 3 != 0;
          return InkWell(
            onTap: () => _showRoomSheet(context, 101 + i, isOccupied),
            child: Container(
              decoration: BoxDecoration(
                color: isOccupied ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Text("${101 + i}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ),
          );
        },
      ),
    );
  }
}

// --- 3. STUDENT DIRECTORY ---
class StudentDirectoryPage extends StatelessWidget {
  const StudentDirectoryPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: 10,
      itemBuilder: (ctx, i) => Card(
        child: ListTile(
          leading: const CircleAvatar(backgroundColor: warmYellow, child: Icon(Icons.person, color: Colors.white)),
          title: Text("Student Name #$i"),
          subtitle: Text("ID: SAH-202$i | Room: ${101 + i}"),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}

// --- 4. INBOX & CHAT ---
class WardenInboxPage extends StatelessWidget {
  const WardenInboxPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (ctx, i) => ListTile(
        leading: const CircleAvatar(child: Icon(Icons.mail)),
        title: Text("Student Group ${i+1}"),
        subtitle: const Text("Permission request for late entry..."),
        onTap: () {},
      ),
    );
  }
}

// --- 5. SETTINGS / ADMIN SETUP ---
class AdminSetupPage extends StatelessWidget {
  const AdminSetupPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ListTile(leading: Icon(Icons.person), title: Text("Profile Settings")),
        const ListTile(leading: Icon(Icons.security), title: Text("Security & Privacy")),
        const ListTile(leading: Icon(Icons.help), title: Text("Support Center")),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text("Logout"),
          onTap: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

// --- 6. PLACEHOLDER FUNCTIONAL PAGES ---
class OccupancyStatsPage extends StatelessWidget {
  const OccupancyStatsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Occupancy Stats"), backgroundColor: sunsetOrange),
    body: const Center(child: Text("Total Beds: 500\nOccupied: 470\nAvailable: 30", textAlign: TextAlign.center, style: TextStyle(fontSize: 20))),
  );
}

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Attendance Log"), backgroundColor: sunsetOrange),
    body: const Center(child: Text("No records for today yet.")),
  );
}

class GateRecordsPage extends StatelessWidget {
  const GateRecordsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Gate Logs"), backgroundColor: sunsetOrange),
    body: const Center(child: Text("Recent Entry: Student SAH-09 (6:30 PM)")),
  );
}

class StaffManagementPage extends StatelessWidget {
  const StaffManagementPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Staff Roster"), backgroundColor: sunsetOrange),
    body: const Center(child: Text("On Duty: 12 Members")),
  );
}

class ComplaintManagementPage extends StatelessWidget {
  const ComplaintManagementPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Complaint Center"), backgroundColor: sunsetOrange),
    body: const Center(child: Text("3 Pending Complaints")),
  );
}