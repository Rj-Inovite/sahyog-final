// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';

// --- CORE API & MODEL INTEGRATIONS ---
import 'register.dart'; 
import 'warden-response.dart'; 
import 'warden_profile.dart'; 
import 'data/models/network/api_service.dart'; 
import 'package:my_app/data/models/network/student_list_response.dart'; 
import 'package:my_app/data/models/warden_list_response.dart';

// --- DESIGN SYSTEM (Indigo Professional Palette) ---
const Color primaryIndigo = Color(0xFF3F51B5); // Indigo
const Color darkIndigo = Color(0xFF303F9F);    // Deep Indigo
const Color backgroundWhite = Color(0xFFFFFFFF); // Pure White Background
const Color textDark = Color(0xFF2D3436);
const Color successGreen = Color(0xFF00B894);
const Color cardShadow = Color(0x0F000000); // Subtle indigo-tinted shadow

class WardenDashboard extends StatefulWidget {
  final Map<String, String> userData;
  const WardenDashboard({super.key, required this.userData});

  @override
  State<WardenDashboard> createState() => _WardenDashboardState();
}

class _WardenDashboardState extends State<WardenDashboard> {
  int _currentIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ConsoleHome(userData: widget.userData),
      const StudentDirectoryPage(), 
      const WardenInboxPage(), 
      const AdminSetupPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      appBar: AppBar(
        title: const Text("Sahyog Manager",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white, letterSpacing: 1.2)),
        backgroundColor: primaryIndigo,
        centerTitle: false,
        elevation: 0,
        leading: _currentIndex != 0 ? IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => setState(() => _currentIndex = 0),
        ) : null,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              child: IconButton(
                icon: const Icon(Icons.person_outline_rounded, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => WardenProfilePage(userData: widget.userData)
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [BoxShadow(color: cardShadow, blurRadius: 20, offset: Offset(0, -5))],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primaryIndigo,
          unselectedItemColor: Colors.blueGrey.withOpacity(0.4),
          currentIndex: _currentIndex,
          backgroundColor: Colors.white,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          elevation: 0,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), activeIcon: Icon(Icons.grid_view_sharp), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), activeIcon: Icon(Icons.groups_rounded), label: "Students"),
            BottomNavigationBarItem(icon: Icon(Icons.alternate_email_rounded), activeIcon: Icon(Icons.mail_rounded), label: "Inbox"),
          ],
        ),
      ),
    );
  }
}

class ConsoleHome extends StatefulWidget {
  final Map<String, String> userData;
  const ConsoleHome({super.key, required this.userData});

  @override
  State<ConsoleHome> createState() => _ConsoleHomeState();
}

class _ConsoleHomeState extends State<ConsoleHome> {
  bool _isProfileLoading = true;
  String? _wardenName;
  String? _hostelName;

  @override
  void initState() {
    super.initState();
    _fetchWardenProfileData();
  }

  Future<void> _fetchWardenProfileData() async {
    try {
      final response = await apiService.getWardenList();
      if (response != null && response.success == true) {
        setState(() {
          _wardenName = response.loggedInWarden; 
          _hostelName = response.hostelName;
          _isProfileLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Hero Header Sync Error: $e");
      setState(() => _isProfileLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchWardenProfileData,
      color: primaryIndigo,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Column(
          children: [
            _buildHeroHeader(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Live Statistics", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textDark)),
                  const SizedBox(height: 15),
                  _buildQuickStats(context),
                  const SizedBox(height: 25),
                  const ShinyRegistryButton(), 
                  const SizedBox(height: 30),
                  const Text("Management Modules", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textDark)),
                  const SizedBox(height: 15),
                  _buildModuleGrid(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    String displayName = _wardenName ?? widget.userData['name'] ?? 'Warden';
    String subtitle = _hostelName ?? "Sahyog Management";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 45, horizontal: 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryIndigo, darkIndigo],
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Welcome Back,", style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 5),
          Text(displayName, 
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sync, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text("Background Sync: Active (10s)", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Row(
      children: [
        _statItem(context, "Occupancy", "94%", Icons.bed_rounded, primaryIndigo, const OccupancyStatsPage()),
        const SizedBox(width: 12),
        _statItem(context, "Tickets", "03", Icons.assignment_late_rounded, Colors.redAccent, const ComplaintManagementPage()),
        const SizedBox(width: 12),
        _statItem(context, "Active Staff", "08", Icons.badge_rounded, Colors.teal, const StaffManagementPage()),
      ],
    );
  }

  Widget _statItem(BuildContext context, String label, String val, IconData icon, Color color, Widget target) {
    return Expanded(
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => target)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: const [BoxShadow(color: cardShadow, blurRadius: 10, offset: Offset(0, 4))],
            border: Border.all(color: Colors.grey.shade50),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 12),
              Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textDark)),
              Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
            ],
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
      mainAxisSpacing: 18,
      crossAxisSpacing: 18,
      childAspectRatio: 1.25,
      children: [
        _moduleCard(context, "Room Allotment", Icons.grid_view_rounded, const RoomInventoryPage(), "Manage Allotments"),
        _moduleCard(context, "Std attendance", Icons.fact_check_rounded, const AttendancePage(), "Daily Attendance"),
        _moduleCard(context, "Staff", Icons.supervised_user_circle_rounded, const StaffManagementPage(), "Warden Directory"),
        _moduleCard(context, "Security Logs", Icons.security_rounded, const GateRecordsPage(), "Entry/Exit Log"),
      ],
    );
  }

  Widget _moduleCard(BuildContext context, String title, IconData icon, Widget target, String subtitle) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => target)),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: primaryIndigo.withOpacity(0.05)),
          boxShadow: const [BoxShadow(color: cardShadow, blurRadius: 5, offset: Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: primaryIndigo, size: 32),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: textDark)),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class StudentDirectoryPage extends StatefulWidget {
  const StudentDirectoryPage({super.key});

  @override
  State<StudentDirectoryPage> createState() => _StudentDirectoryPageState();
}

class _StudentDirectoryPageState extends State<StudentDirectoryPage> {
  List<Student> _students = [];
  bool _isLoading = true;
  Timer? _syncTimer; 

  @override
  void initState() {
    super.initState();
    _fetchStudents();
    _syncTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) _fetchStudents(isSilent: true);
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel(); 
    super.dispose();
  }

  Future<void> _fetchStudents({bool isSilent = false}) async {
    if (!isSilent) setState(() => _isLoading = true);
    try {
      final response = await apiService.getStudentList();
      if (response != null && response.success) {
        if (mounted) {
          setState(() {
            _students = response.students;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Sahyog Student Sync Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: primaryIndigo))
        : RefreshIndicator(
            onRefresh: _fetchStudents,
            color: primaryIndigo,
            child: _students.isEmpty 
              ? const Center(child: Text("No Students Found", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _students.length,
                  itemBuilder: (ctx, i) => _buildStudentCard(_students[i]),
                ),
          ),
    );
  }

  Widget _buildStudentCard(Student student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: cardShadow, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Container(
          width: 55, height: 55,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [primaryIndigo.withOpacity(0.1), primaryIndigo.withOpacity(0.05)]),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(student.firstName.isNotEmpty ? student.firstName[0].toUpperCase() : "?", 
                style: const TextStyle(color: primaryIndigo, fontWeight: FontWeight.w900, fontSize: 20)),
          ),
        ),
        title: Text("${student.firstName} ${student.lastName ?? ''}", 
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: textDark)),
        subtitle: Text("Code: ${student.studentCode}", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: student.status.toLowerCase() == 'active' ? successGreen.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(student.status.toUpperCase(), 
              style: TextStyle(color: student.status.toLowerCase() == 'active' ? successGreen : Colors.grey, fontSize: 10, fontWeight: FontWeight.w900)),
        ),
      ),
    );
  }
}

class StaffManagementPage extends StatefulWidget {
  const StaffManagementPage({super.key});
  @override
  State<StaffManagementPage> createState() => _StaffManagementPageState();
}

class _StaffManagementPageState extends State<StaffManagementPage> {
  List<Warden> _wardens = [];
  String? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWardens();
  }

  Future<void> _fetchWardens() async {
    try {
      final response = await apiService.getWardenList();
      if (response != null && (response.success ?? false)) {
        if (mounted) {
          setState(() { 
            _wardens = response.data ?? []; 
            _currentUser = response.loggedInWarden;
            _isLoading = false; 
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Staff Fetch Error (Sahyog API): $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      appBar: AppBar(
        title: const Text("Staff Directory", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), 
        backgroundColor: primaryIndigo,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: primaryIndigo)) 
        : RefreshIndicator(
            onRefresh: _fetchWardens,
            color: primaryIndigo,
            child: _wardens.isEmpty
              ? const Center(child: Text("No Staff Members Found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _wardens.length,
                  itemBuilder: (ctx, i) => _buildWardenTile(_wardens[i]),
                ),
          ),
    );
  }

  Widget _buildWardenTile(Warden warden) {
    bool isMe = warden.wardenName == _currentUser;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isMe ? primaryIndigo.withOpacity(0.3) : Colors.transparent, width: 1.5),
        boxShadow: const [BoxShadow(color: cardShadow, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isMe ? primaryIndigo : primaryIndigo.withOpacity(0.1), 
          child: Icon(Icons.verified_user_rounded, color: isMe ? Colors.white : primaryIndigo, size: 20)
        ),
        title: Row(
          children: [
            Text(warden.wardenName ?? "Unknown Warden", style: const TextStyle(fontWeight: FontWeight.w900)),
            if (isMe) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: primaryIndigo.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                child: const Text("YOU", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: primaryIndigo)),
              )
            ]
          ],
        ),
        subtitle: Text("${warden.email ?? ''} | ${warden.mobile ?? ''}", style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}

class ComplaintManagementPage extends StatelessWidget {
  const ComplaintManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      appBar: AppBar(
        title: const Text("Maintenance Tickets"), 
        backgroundColor: primaryIndigo,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 4,
        itemBuilder: (ctx, i) => Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: const [BoxShadow(color: cardShadow, blurRadius: 5, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(i == 0 ? "Critical: Water Leak" : "Routine Checkup", 
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  Icon(Icons.circle, color: i == 0 ? Colors.red : Colors.orange, size: 12),
                ],
              ),
              const SizedBox(height: 8),
              Text("Room: ${101+i} | Request #882$i", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const Divider(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryIndigo, 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0
                      ),
                      onPressed: () {},
                      child: const Text("Assign Technician", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(onPressed: (){}, icon: const Icon(Icons.chat_bubble_outline_rounded, color: primaryIndigo)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class RoomInventoryPage extends StatelessWidget {
  const RoomInventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      appBar: AppBar(
        title: const Text("Hostel Bed Layout"), 
        backgroundColor: primaryIndigo,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1,
        ),
        itemCount: 20,
        itemBuilder: (ctx, i) {
          bool isOccupied = i % 3 != 0;
          return Container(
            decoration: BoxDecoration(
              color: isOccupied ? primaryIndigo.withOpacity(0.05) : successGreen.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: isOccupied ? primaryIndigo.withOpacity(0.2) : successGreen.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${101 + i}", style: TextStyle(fontWeight: FontWeight.w900, color: isOccupied ? primaryIndigo : successGreen)),
                const SizedBox(height: 4),
                Icon(isOccupied ? Icons.person_rounded : Icons.check_circle_outline_rounded, size: 14, color: isOccupied ? primaryIndigo : successGreen),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      appBar: AppBar(
        title: const Text("Daily Attendance"), 
        backgroundColor: primaryIndigo,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: primaryIndigo.withOpacity(0.05),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Batch", style: TextStyle(color: Colors.grey, fontSize: 12)), Text("March 19, 2026", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text("Status", style: TextStyle(color: Colors.grey, fontSize: 12)), Text("78% Present", style: TextStyle(color: primaryIndigo, fontWeight: FontWeight.bold, fontSize: 16))]),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: 10,
              itemBuilder: (ctx, i) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [BoxShadow(color: cardShadow, blurRadius: 4, offset: Offset(0, 2))],
                ),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.blueGrey.shade50, child: Icon(Icons.person_rounded, color: primaryIndigo.withOpacity(0.3))),
                  title: Text("Student #$i", style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Switch(value: true, activeColor: successGreen, onChanged: (v){}),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity, height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryIndigo, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                onPressed: () {},
                child: const Text("SUBMIT ATTENDANCE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class GateRecordsPage extends StatelessWidget {
  const GateRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      appBar: AppBar(
        title: const Text("Campus Access Log"), 
        backgroundColor: primaryIndigo,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 15,
        itemBuilder: (ctx, i) {
          bool isEntry = i % 2 == 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100)),
            child: Row(
              children: [
                Icon(isEntry ? Icons.login_rounded : Icons.logout_rounded, color: isEntry ? successGreen : primaryIndigo),
                const SizedBox(width: 15),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Student #102$i", style: const TextStyle(fontWeight: FontWeight.bold)), Text(isEntry ? "Hostel Entry" : "Gate Exit", style: const TextStyle(color: Colors.grey, fontSize: 12))])),
                const Text("08:45 PM", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class OccupancyStatsPage extends StatelessWidget {
  const OccupancyStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      appBar: AppBar(
        title: const Text("Hostel Utilization"), 
        backgroundColor: primaryIndigo,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Text("Overall Occupancy", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 40),
            Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox(width: 220, height: 220, child: CircularProgressIndicator(value: 0.94, strokeWidth: 15, color: primaryIndigo, backgroundColor: Color(0xFFEEEEEE))),
                const Column(mainAxisSize: MainAxisSize.min, children: [Text("94%", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900)), Text("Occupied", style: TextStyle(color: Colors.grey))]),
              ],
            ),
            const SizedBox(height: 50),
            _buildStatRow("Total Bed Capacity", "250"),
            _buildStatRow("Current Residents", "235"),
            _buildStatRow("Available Units", "15"),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: const TextStyle(fontWeight: FontWeight.bold)), Text(value, style: const TextStyle(fontWeight: FontWeight.w900, color: primaryIndigo, fontSize: 18))],
      ),
    );
  }
}

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
          width: double.infinity, height: 65,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: const [primaryIndigo, Colors.white, primaryIndigo],
              stops: [_controller.value - 0.2, _controller.value, _controller.value + 0.2],
            ),
            boxShadow: [BoxShadow(color: primaryIndigo.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterStudent())),
            icon: const Icon(Icons.person_add_rounded, color: Color.fromRGBO(249, 252, 253, 1), size: 28),
            label: const Text("NEW STUDENT  ATTENDANCE REGISTRATION", style: TextStyle(color: Color.fromRGBO(248, 254, 255, 1), fontWeight: FontWeight.w900, letterSpacing: 1.0)),
          ),
        );
      },
    );
  }
}

class WardenInboxPage extends StatelessWidget {
  const WardenInboxPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text("Communication Hub", style: TextStyle(fontWeight: FontWeight.bold, color: textDark)));
}

class AdminSetupPage extends StatelessWidget {
  const AdminSetupPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [const ListTile(leading: Icon(Icons.sync_lock_rounded, color: primaryIndigo), title: Text("Force System Sync")), const Divider(), ListTile(leading: const Icon(Icons.logout_rounded, color: Colors.red), title: const Text("Logout"), onTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false))]);
}