import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class AdminDashboard extends StatefulWidget {
  final Map<String, String> userData;
  const AdminDashboard({super.key, required this.userData});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String selectedFilter = "All";

  // Mock data representing database entries
  List<Map<String, dynamic>> attendanceLogs = [
    {
      "name": "Meena Iyer",
      "id": "STD990",
      "type": "IN",
      "time": "08:30 AM",
      "date": "23 Feb 2026",
      "day": "Monday",
      "period": "Weekly"
    },
    {
      "name": "Sheela Raj",
      "id": "STD442",
      "type": "OUT",
      "time": "04:15 PM",
      "date": "20 Feb 2026",
      "day": "Friday",
      "period": "Monthly"
    },
  ];

  List<Map<String, dynamic>> get filteredLogs {
    if (selectedFilter == "All") return attendanceLogs;
    return attendanceLogs.where((log) => log['period'] == selectedFilter).toList();
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: ["All", "Weekly", "Monthly", "Yearly"].map((filter) {
            return ListTile(
              title: Text(filter, style: const TextStyle(color: Colors.white)),
              onTap: () {
                setState(() => selectedFilter = filter);
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryDark = Color(0xFF0F172A);
    const accentCyan = Color(0xFF00E5FF);

    return Scaffold(
      backgroundColor: primaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("ADMIN DASHBOARD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [IconButton(onPressed: _showFilterOptions, icon: const Icon(Icons.tune, color: accentCyan))],
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildScannerTrigger(context, accentCyan),
          const SizedBox(height: 30),
          _buildLogListHeader(),
          Expanded(child: _buildLogList()),
        ],
      ),
    );
  }

  Widget _buildScannerTrigger(BuildContext context, Color accent) {
    return Pulse(
      infinite: true,
      child: GestureDetector(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BioScannerPage()),
          );

          if (result != null && result is Map<String, dynamic>) {
            setState(() => attendanceLogs.insert(0, result));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.greenAccent,
                content: Text("${result['name']}, your data has been recorded!", 
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            );
          }
        },
        child: Container(
          height: 120, width: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [accent, Colors.blueAccent]),
            boxShadow: [BoxShadow(color: accent.withAlpha(100), blurRadius: 20)],
          ),
          child: const Icon(Icons.camera_front, size: 50, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLogListHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("RECORDS ($selectedFilter)", style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          const Icon(Icons.history, color: Colors.white38),
        ],
      ),
    );
  }

  Widget _buildLogList() {
    var logs = filteredLogs;
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        bool isIn = logs[index]['type'] == "IN";
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: Icon(isIn ? Icons.login : Icons.logout, color: isIn ? Colors.greenAccent : Colors.redAccent),
            title: Text(logs[index]['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text("${logs[index]['id']} | ${logs[index]['date']}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
            trailing: Text(logs[index]['time'], style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
}

// --- BIO SCANNER PAGE ---

class BioScannerPage extends StatefulWidget {
  const BioScannerPage({super.key});
  @override
  State<BioScannerPage> createState() => _BioScannerPageState();
}

class _BioScannerPageState extends State<BioScannerPage> {
  String? mode;
  String? currentAction;
  final List<String> actionPool = ["Blink Your Eyes", "Smile Widely", "Look Left", "Look Right", "Nod Head"];

  @override
  void initState() {
    super.initState();
    currentAction = actionPool[Random().nextInt(actionPool.length)];
  }

  void _verifyAndReturn() {
    // 10% chance to simulate a recording glitch
    if (Random().nextInt(10) == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.redAccent, content: Text("Glitch in data recording please redo your action")),
      );
      Navigator.pop(context);
      return;
    }

    DateTime now = DateTime.now();
    Navigator.pop(context, {
      "name": "User ${Random().nextInt(500)}",
      "id": "STD${Random().nextInt(899) + 100}",
      "type": mode,
      "time": DateFormat('hh:mm a').format(now),
      "date": DateFormat('dd MMM yyyy').format(now),
      "day": DateFormat('EEEE').format(now),
      "period": "Weekly", 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: mode == null ? _buildModeSelect() : _buildScannerLayout(),
      ),
    );
  }

  Widget _buildModeSelect() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("SELECT MODE", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: () => setState(() => mode = "IN"), style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent), child: const Text("IN", style: TextStyle(color: Colors.black))),
            const SizedBox(width: 25),
            ElevatedButton(onPressed: () => setState(() => mode = "OUT"), style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), child: const Text("OUT", style: TextStyle(color: Colors.black))),
          ],
        )
      ],
    );
  }

  Widget _buildScannerLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("FRONT CAMERA SCAN", style: TextStyle(color: Colors.white38, letterSpacing: 2, fontSize: 10)),
        const SizedBox(height: 30),
        
        // --- FIXED SQUARE SCANNER ---
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 280, height: 280,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.cyanAccent, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.face, size: 120, color: Colors.white10),
            ),
            // The Scanning Line: Using Pulse + Container instead of SlideInDown(infinite)
            Pulse(
              infinite: true,
              duration: const Duration(seconds: 2),
              child: Container(
                width: 260, height: 2,
                decoration: BoxDecoration(
                  color: Colors.cyanAccent,
                  boxShadow: [BoxShadow(color: Colors.cyanAccent, blurRadius: 10)],
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 40),
        Text("Required Action:", style: const TextStyle(color: Colors.white54)),
        const SizedBox(height: 10),
        FadeIn(
          child: Text(currentAction!, style: const TextStyle(color: Colors.cyanAccent, fontSize: 26, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 60),
        ElevatedButton(
          onPressed: _verifyAndReturn,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
          child: const Text("VERIFY NOW", style: TextStyle(fontWeight: FontWeight.bold)),
        )
      ],
    );
  }
}