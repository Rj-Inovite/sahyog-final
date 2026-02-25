import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:camera/camera.dart';

class AdminDashboard extends StatefulWidget {
  final Map<String, String> userData;
  const AdminDashboard({super.key, required this.userData});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String selectedFilter = "All";

  // Initial Mock Data
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
  ];

  // Logic for filtering by Period
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
        title: const Text("ADMIN DASHBOARD", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
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
          // Fetch available cameras before navigating
          final cameras = await availableCameras();
          if (!context.mounted) return;

          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BioScannerPage(cameras: cameras)),
          );

          if (result != null && result is Map<String, dynamic>) {
            setState(() => attendanceLogs.insert(0, result));
            
            // "Your data has been recorded" Message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.greenAccent,
                behavior: SnackBarBehavior.floating,
                content: Text("${result['name']}, your data has been recorded!", 
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            );
          }
        },
        child: Container(
          height: 110, width: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [accent, Colors.blueAccent]),
            boxShadow: [BoxShadow(color: accent.withAlpha(100), blurRadius: 20)],
          ),
          child: const Icon(Icons.qr_code_scanner, size: 50, color: Colors.white),
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
    if (logs.isEmpty) return const Center(child: Text("No records found", style: TextStyle(color: Colors.white38)));
    
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        bool isIn = logs[index]['type'] == "IN";
        return FadeInUp(
          duration: const Duration(milliseconds: 400),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isIn ? Colors.greenAccent.withAlpha(30) : Colors.redAccent.withAlpha(30),
                  shape: BoxShape.circle
                ),
                child: Icon(isIn ? Icons.login : Icons.logout, color: isIn ? Colors.greenAccent : Colors.redAccent),
              ),
              title: Text(logs[index]['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text("ID: ${logs[index]['id']} | ${logs[index]['date']} (${logs[index]['day']})", 
                style: const TextStyle(color: Colors.white54, fontSize: 11)),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(logs[index]['time'], style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                  Text(logs[index]['type'], style: TextStyle(color: isIn ? Colors.greenAccent : Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- BIO SCANNER PAGE ---

class BioScannerPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const BioScannerPage({super.key, required this.cameras});

  @override
  State<BioScannerPage> createState() => _BioScannerPageState();
}

class _BioScannerPageState extends State<BioScannerPage> {
  CameraController? _controller;
  String? mode;
  String currentInstruction = "";
  bool isCameraInitialized = false;

  final List<String> instructions = [
    "Blink Your Eyes",
    "Smile Widely",
    "Look Left",
    "Look Right",
    "Nod Your Head",
    "Tilt Head Left",
    "Open Your Mouth"
  ];

  @override
  void initState() {
    super.initState();
    // Randomize instruction immediately
    _generateNewInstruction();
  }

  void _generateNewInstruction() {
    setState(() {
      currentInstruction = instructions[Random().nextInt(instructions.length)];
    });
  }

  Future<void> _initCamera() async {
    final front = widget.cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => widget.cameras.first,
    );

    _controller = CameraController(front, ResolutionPreset.medium, enableAudio: false);

    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() => isCameraInitialized = true);
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _completeVerification() {
    DateTime now = DateTime.now();
    // Random period generator for demo purposes
    List<String> periods = ["Weekly", "Monthly", "Yearly"];
    
    Navigator.pop(context, {
      "name": "User ${Random().nextInt(1000)}",
      "id": "STD${Random().nextInt(800) + 100}",
      "type": mode,
      "time": DateFormat('hh:mm a').format(now),
      "date": DateFormat('dd MMM yyyy').format(now),
      "day": DateFormat('EEEE').format(now),
      "period": periods[Random().nextInt(3)], 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)),
      body: mode == null ? _buildModeSelection() : _buildScannerView(),
    );
  }

  Widget _buildModeSelection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(child: const Text("CHOOSE MODE", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2))),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _modeButton("IN", Colors.greenAccent),
              const SizedBox(width: 30),
              _modeButton("OUT", Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _modeButton(String label, Color color) {
    return ZoomIn(
      child: ElevatedButton(
        onPressed: () {
          setState(() => mode = label);
          _initCamera(); // Initialize camera only after mode is selected
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
    );
  }

  Widget _buildScannerView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("SCANNING: $mode", style: TextStyle(color: mode == "IN" ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 2)),
        const SizedBox(height: 20),
        
        // --- SQUARE SCANNER BOX ---
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 280, height: 280,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.cyanAccent, width: 2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: isCameraInitialized 
                    ? AspectRatio(aspectRatio: 1, child: CameraPreview(_controller!))
                    : const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
                ),
              ),
              
              // Animated Scanning Line
              Pulse(
                infinite: true,
                child: Container(
                  width: 260, height: 2,
                  decoration: BoxDecoration(
                    color: Colors.cyanAccent,
                    boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 40),
        const Text("Instruction:", style: TextStyle(color: Colors.white54, fontSize: 14)),
        const SizedBox(height: 10),
        
        // Random Instruction Text
        FadeInRight(
          key: ValueKey(currentInstruction),
          child: Text(currentInstruction, 
            style: const TextStyle(color: Colors.cyanAccent, fontSize: 26, fontWeight: FontWeight.bold)),
        ),
        
        const SizedBox(height: 60),
        
        ElevatedButton(
          onPressed: isCameraInitialized ? _completeVerification : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            shape: const StadiumBorder()
          ),
          child: const Text("CONFIRM ACTION", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}