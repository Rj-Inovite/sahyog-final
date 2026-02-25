import 'package:flutter/material.dart';

// --- THEME CONSTANTS ---
const Color sunsetOrange = Color(0xFFFF8C42);
const Color warmYellow = Color(0xFFF9D423);
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        backgroundColor: sunsetOrange,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 30, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WardenProfilePage()),
              );
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
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
            //    const ShinyAuthButton(),
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
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
/*
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
            boxShadow: [BoxShadow(color: sunsetOrange.withValues(alpha: 0.3), blurRadius: 10)],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminAuthPage())),
            child: const Text("ADMINISTRATOR AUTHENTICATION",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          ),
        );
      },
    );
  }
}

// --- ADMINISTRATOR AUTHENTICATION PAGE ---
class AdminAuthPage extends StatelessWidget {
  const AdminAuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Secure Portal"), backgroundColor: Colors.black87),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_person, size: 80, color: sunsetOrange),
            const SizedBox(height: 20),
            const Text("Security Verification Required", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Please verify your biometrics or enter your high-level PIN to access root settings.", textAlign: TextAlign.center),
            const SizedBox(height: 40),
            TextField(decoration: InputDecoration(hintText: "Enter Admin PIN", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: sunsetOrange),
                onPressed: () {},
                child: const Text("VERIFY & PROCEED", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
*/
// --- ROOM INVENTORY ---
class RoomInventoryPage extends StatelessWidget {
  const RoomInventoryPage({super.key});

  void _showRoomSheet(BuildContext context, int roomNum, bool occupied) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(25, 20, 25, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Room #$roomNum", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: occupied ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(occupied ? "OCCUPIED" : "VACANT",
                      style: TextStyle(color: occupied ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                )
              ],
            ),
            const Divider(height: 30),
            const Text("Room Features:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            _infoTile(Icons.bed, "3 Individual Beds"),
            _infoTile(Icons.desk, "3 Study Tables"),
            _infoTile(Icons.door_sliding, "3 Wardrobes"),
            if (occupied) ...[
              const SizedBox(height: 20),
              const Text("Residents:", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              _resTile("Aryan Verma", "SAH-101"),
              _resTile("Rahul Singh", "SAH-102"),
              _resTile("Deepak Jha", "SAH-103"),
            ] else ...[
              const SizedBox(height: 20),
              const Text("Status:", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              const Text("Available for new allotments. All furniture inspected."),
            ],
            const SizedBox(height: 30),
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

  Widget _infoTile(IconData icon, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(children: [Icon(icon, size: 20, color: Colors.grey), const SizedBox(width: 10), Text(label)]),
      );

  Widget _resTile(String name, String id) => ListTile(
        leading: const CircleAvatar(radius: 15, child: Icon(Icons.person, size: 15)),
        title: Text(name),
        subtitle: Text(id),
        dense: true,
      );

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

// --- ATTENDANCE ---
class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daily Attendance"), backgroundColor: sunsetOrange),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: 15,
        itemBuilder: (ctx, i) => Card(
          child: ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: Text("Student Name ${i + 1}"),
            subtitle: Text("Verified at 08:${i + 10} AM"),
            trailing: const Text("Present", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}

// --- STAFF MANAGEMENT ---
class StaffManagementPage extends StatelessWidget {
  const StaffManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Staff Roster"), backgroundColor: sunsetOrange),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: const [
          StaffCard(name: "Suresh Kumar", role: "Main Security", status: "On Duty"),
          StaffCard(name: "Mahesh Singh", role: "Janitor", status: "On Duty"),
          StaffCard(name: "Sunita Rani", role: "Mess In-charge", status: "Off Duty"),
          StaffCard(name: "Rahul Dev", role: "Electrician", status: "On Duty"),
        ],
      ),
    );
  }
}

class StaffCard extends StatelessWidget {
  final String name, role, status;
  const StaffCard({super.key, required this.name, required this.role, required this.status});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(role),
        trailing: Text(status, style: TextStyle(color: status == "On Duty" ? Colors.green : Colors.red)),
      ),
    );
  }
}

// --- OCCUPANCY, GATE, COMPLAINTS ---
class OccupancyStatsPage extends StatelessWidget {
  const OccupancyStatsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text("Occupancy Analytics"), backgroundColor: sunsetOrange),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _occTile("Wing A", "120/125 Beds", 0.96, Colors.green),
              _occTile("Wing B", "110/125 Beds", 0.88, Colors.blue),
              _occTile("Wing C", "118/125 Beds", 0.94, Colors.orange),
              _occTile("Wing D", "124/125 Beds", 0.99, Colors.red),
            ],
          ),
        ),
      );

  Widget _occTile(String w, String d, double p, Color c) => Card(
        child: ListTile(
          title: Text(w, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: LinearProgressIndicator(value: p, color: c, backgroundColor: Colors.grey[200]),
          trailing: Text(d),
        ),
      );
}

class GateRecordsPage extends StatelessWidget {
  const GateRecordsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text("Gate Security Logs"), backgroundColor: sunsetOrange),
        body: ListView.builder(
          itemCount: 20,
          itemBuilder: (ctx, i) => ListTile(
            leading: Icon(i % 2 == 0 ? Icons.logout : Icons.login, color: i % 2 == 0 ? Colors.red : Colors.green),
            title: Text("Student SAH-${101 + i}"),
            subtitle: Text("Time: 0${(i % 12) + 1}:00 PM | Purpose: Outing"),
            trailing: const Text("Verified"),
          ),
        ),
      );
}

class ComplaintManagementPage extends StatelessWidget {
  const ComplaintManagementPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text("Student Complaints"), backgroundColor: sunsetOrange),
        body: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            _compCard("Water Leakage", "Room 302", "Urgent", Colors.red),
            _compCard("WiFi Down", "Wing B", "Medium", Colors.orange),
            _compCard("Fan Repair", "Room 105", "Low", Colors.blue),
          ],
        ),
      );

  Widget _compCard(String t, String r, String p, Color c) => Card(
        child: ListTile(
          title: Text(t),
          subtitle: Text(r),
          trailing: Chip(label: Text(p), backgroundColor: c.withValues(alpha: 0.2)),
        ),
      );
}

// --- 6. UPDATED INBOX (WITH WHATSAPP FEATURES & GROUP CREATION) ---
class WardenInboxPage extends StatefulWidget {
  const WardenInboxPage({super.key});

  @override
  State<WardenInboxPage> createState() => _WardenInboxPageState();
}

class _WardenInboxPageState extends State<WardenInboxPage> {
  final List<Map<String, dynamic>> chats = [
    {"name": "Sneha Patel", "gender": "girl", "msg": "Sir, need leave for 2 days.", "isGroup": false},
    {"name": "Rahul Sharma", "gender": "boy", "msg": "I have lost my room key.", "isGroup": false},
  ];

  void _editName(int index) {
    TextEditingController nameCtrl = TextEditingController(text: chats[index]['name']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Name"),
        content: TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: "Enter Name")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() => chats[index]['name'] = nameCtrl.text);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  void _createNewGroup() {
    List<String> students = ["Aryan", "Rahul", "Sneha", "Priya", "Deepak"];
    List<String> selected = [];
    TextEditingController groupNameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Create New Group"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: groupNameCtrl, decoration: const InputDecoration(hintText: "Group Name")),
              const SizedBox(height: 10),
              const Text("Select Members:", style: TextStyle(fontWeight: FontWeight.bold)),
              ...students.map((s) => CheckboxListTile(
                    title: Text(s),
                    value: selected.contains(s),
                    onChanged: (val) {
                      setDialogState(() {
                        val! ? selected.add(s) : selected.remove(s);
                      });
                    },
                  )),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                if (groupNameCtrl.text.isNotEmpty && selected.isNotEmpty) {
                  setState(() {
                    chats.insert(0, {
                      "name": groupNameCtrl.text,
                      "gender": "group",
                      "msg": "Group created by Warden",
                      "isGroup": true
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Create"),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: sunsetOrange,
        onPressed: _createNewGroup,
        child: const Icon(Icons.group_add, color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (ctx, i) => ListTile(
          leading: CircleAvatar(
            backgroundColor: chats[i]['gender'] == 'girl'
                ? Colors.pink[100]
                : chats[i]['gender'] == 'boy'
                    ? Colors.blue[100]
                    : Colors.orange[100],
            child: Icon(
              chats[i]['isGroup'] ? Icons.groups : Icons.person,
              color: chats[i]['gender'] == 'girl'
                  ? Colors.pink
                  : chats[i]['gender'] == 'boy'
                      ? Colors.blue
                      : Colors.orange,
            ),
          ),
          title: Text(chats[i]['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(chats[i]['msg']!, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("12:00 PM", style: TextStyle(fontSize: 10, color: Colors.grey)),
              IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _editName(i)),
            ],
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatDetailPage(
                      name: chats[i]['name']!,
                      gender: chats[i]['gender']!,
                      isGroup: chats[i]['isGroup'],
                    )),
          ),
        ),
      ),
    );
  }
}

// --- 7. UPDATED CHAT DETAIL (WHATSAPP UI: Status Ticks & Alignment) ---
class ChatDetailPage extends StatefulWidget {
  final String name, gender;
  final bool isGroup;
  const ChatDetailPage({super.key, required this.name, required this.gender, this.isGroup = false});
  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final List<Map<String, dynamic>> _msgs = [
    {"text": "Hello Warden, how are you?", "isWarden": false, "status": "read", "time": "10:00 AM"},
  ];
  final _ctrl = TextEditingController();

  void _sendMessage() {
    if (_ctrl.text.trim().isNotEmpty) {
      setState(() {
        _msgs.add({
          "text": _ctrl.text,
          "isWarden": true,
          "status": "sent", // Options: sent, delivered, read
          "time": "${DateTime.now().hour}:${DateTime.now().minute}"
        });
        _ctrl.clear();
      });

      // Simulate delivery after 1 second
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _msgs.last['status'] = "delivered");
      });
      // Simulate read after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _msgs.last['status'] = "read");
      });
    }
  }

  Widget _getStatusIcon(String status) {
    if (status == "sent") return const Icon(Icons.check, size: 14, color: Colors.grey);
    if (status == "delivered") return const Icon(Icons.done_all, size: 14, color: Colors.grey);
    if (status == "read") return const Icon(Icons.done_all, size: 14, color: Colors.blue);
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    Color themeColor = widget.gender == 'girl' ? Colors.pink : (widget.gender == 'boy' ? Colors.blue : Colors.orange);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              child: Icon(widget.isGroup ? Icons.groups : Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.name, style: const TextStyle(fontSize: 16, color: Colors.white)),
                  Text(widget.isGroup ? "tap for group info" : "online", style: const TextStyle(fontSize: 11, color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage("https://user-images.githubusercontent.com/15075759/28719144-86dc0f70-73b1-11e7-911d-60d70fcded21.png"),
            fit: BoxFit.cover,
            opacity: 0.05,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: _msgs.length,
                itemBuilder: (ctx, i) {
                  bool isWarden = _msgs[i]['isWarden'];
                  return Align(
                    alignment: isWarden ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                      decoration: BoxDecoration(
                        color: isWarden ? const Color(0xFFE7FFDB) : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(12),
                          topRight: const Radius.circular(12),
                          bottomLeft: isWarden ? const Radius.circular(12) : Radius.zero,
                          bottomRight: isWarden ? Radius.zero : const Radius.circular(12),
                        ),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))],
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12, right: 10),
                            child: Text(_msgs[i]['text'], style: const TextStyle(fontSize: 15, color: textDark)),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Row(
                              children: [
                                Text(_msgs[i]['time'], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                const SizedBox(width: 4),
                                if (isWarden) _getStatusIcon(_msgs[i]['status']),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      color: Colors.transparent,
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  const Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: const InputDecoration(
                        hintText: "Message",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                  ),
                  const Icon(Icons.attach_file, color: Colors.grey),
                  const SizedBox(width: 10),
                  const Icon(Icons.camera_alt, color: Colors.grey),
                  const SizedBox(width: 15),
                ],
              ),
            ),
          ),
          const SizedBox(width: 5),
          CircleAvatar(
            backgroundColor: sunsetOrange,
            radius: 25,
            child: IconButton(icon: const Icon(Icons.send, color: Colors.white), onPressed: _sendMessage),
          ),
        ],
      ),
    );
  }
}

// --- REMAINING PAGES ---
class WardenProfilePage extends StatelessWidget {
  const WardenProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Warden Profile"), backgroundColor: sunsetOrange),
      body: const Center(
        child: Column(
          children: [
            SizedBox(height: 40),
            CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            SizedBox(height: 20),
            Text("Chief Warden", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("sahyog.warden@example.com"),
          ],
        ),
      ),
    );
  }
}

class StudentDirectoryPage extends StatelessWidget {
  const StudentDirectoryPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: 10,
      itemBuilder: (ctx, i) => const Card(
        child: ListTile(
          leading: CircleAvatar(backgroundColor: warmYellow, child: Icon(Icons.person, color: Colors.white)),
          title: Text("Student Name"),
          subtitle: Text("ID: SAH-2026 | Room: 105"),
        ),
      ),
    );
  }
}

class AdminSetupPage extends StatelessWidget {
  const AdminSetupPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const ListTile(leading: Icon(Icons.person), title: Text("Profile Settings")),
        const ListTile(leading: Icon(Icons.security), title: Text("Security & Privacy")),
        ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () => Navigator.pop(context)),
      ],
    );
  }
}