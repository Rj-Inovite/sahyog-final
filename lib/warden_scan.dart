import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';

// Global variable to hold available cameras
List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint("Camera Error: $e");
  }
  runApp(const WardenScanApp());
}

class WardenScanApp extends StatelessWidget {
  const WardenScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Warden Scan Pro',
      theme: ThemeData(
        primaryColor: Colors.yellow[700],
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.brown),
      ),
      home: const MainNavigationWrapper(),
    );
  }
}

// Handles the logic of moving between screens with animations
class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  final PageController _pageController = PageController();

  void _navigateTo(int pageIndex) {
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(), // Disable swiping to force button flow
      children: [
        AttendanceReportPage(onNext: () => _navigateTo(1)),
        PinEntryPage(onSuccess: () => _navigateTo(2), onBack: () => _navigateTo(0)),
        DashboardPage(onStartScan: (isInward) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => FaceScannerPage(isInward: isInward)),
          );
        }),
      ],
    );
  }
}

// --- SCREEN 1: WARDEN REPORT ---
class AttendanceReportPage extends StatelessWidget {
  final VoidCallback onNext;
  const AttendanceReportPage({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Warden Insights", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.yellow[700],
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSummaryCard(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Align(alignment: Alignment.centerLeft, child: Text("Recent Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              children: [
                _activityTile("John Doe", "IN - 08:30 AM", Colors.green),
                _activityTile("Sarah Smith", "OUT - 04:15 PM", Colors.red),
                _activityTile("Mike Ross", "IN - 09:00 AM", Colors.green),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onNext,
              child: const Text("Switch to Scanning Mode", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.yellow[100],
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.yellow[700]!, width: 2),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(children: [Text("Present", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)), Text("142", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))]),
          Column(children: [Text("Absent", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), Text("12", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))]),
        ],
      ),
    );
  }

  Widget _activityTile(String name, String status, Color color) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.person_pin, color: color),
        title: Text(name),
        subtitle: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

// --- SCREEN 2: ANIMATED PIN ENTRY ---
class PinEntryPage extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onBack;
  const PinEntryPage({super.key, required this.onSuccess, required this.onBack});

  @override
  State<PinEntryPage> createState() => _PinEntryPageState();
}

class _PinEntryPageState extends State<PinEntryPage> {
  String input = "";
  final String secret = "1234";

  void _handleKey(String val) {
    if (input.length < 4) {
      setState(() => input += val);
      if (input.length == 4) {
        if (input == secret) {
          widget.onSuccess();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid PIN! Try 1234")));
          setState(() => input = "");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(alignment: Alignment.topLeft, child: IconButton(onPressed: widget.onBack, icon: const Icon(Icons.arrow_back))),
            const Spacer(),
            const Text("Warden Verification", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text("Enter PIN to unlock scanner", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) => Container(
                margin: const EdgeInsets.all(10),
                width: 20, height: 20,
                decoration: BoxDecoration(shape: BoxShape.circle, color: i < input.length ? Colors.brown : Colors.grey[300]),
              )),
            ),
            const Spacer(),
            _buildNumpad(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: 1.5,
      children: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "C", "0", "⌫"].map((key) {
        return TextButton(
          onPressed: () {
            if (key == "C") setState(() => input = "");
            else if (key == "⌫") setState(() => input = input.isNotEmpty ? input.substring(0, input.length - 1) : "");
            else _handleKey(key);
          },
          child: Text(key, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
        );
      }).toList(),
    );
  }
}

// --- SCREEN 3: DASHBOARD (MOVEMENT SELECTOR) ---
class DashboardPage extends StatefulWidget {
  final Function(bool isInward) onStartScan;
  const DashboardPage({super.key, required this.onStartScan});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool isInward = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.face_retouching_natural, size: 100, color: Colors.brown),
            const SizedBox(height: 20),
            const Text("Scanner Dashboard", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _modeButton("INWARD", true),
                const SizedBox(width: 20),
                _modeButton("OUTWARD", false),
              ],
            ),
            const SizedBox(height: 60),
            GestureDetector(
              onTap: () => widget.onStartScan(isInward),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.brown,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: const Text("FACE SCAN", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeButton(String label, bool value) {
    bool active = isInward == value;
    return GestureDetector(
      onTap: () => setState(() => isInward = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
        decoration: BoxDecoration(
          color: active ? Colors.yellow[700] : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.brown, width: 2),
        ),
        child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: active ? Colors.white : Colors.brown)),
      ),
    );
  }
}

// --- SCREEN 4: REAL CAMERA SCANNER ---
class FaceScannerPage extends StatefulWidget {
  final bool isInward;
  const FaceScannerPage({super.key, required this.isInward});

  @override
  State<FaceScannerPage> createState() => _FaceScannerPageState();
}

class _FaceScannerPageState extends State<FaceScannerPage> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  late AnimationController _animController;
  bool isProcessing = false;
  String? resultText;

  @override
  void initState() {
    super.initState();
    _setupCamera();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  Future<void> _setupCamera() async {
    if (cameras.isEmpty) return;
    final frontCam = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front);
    _controller = CameraController(frontCam, ResolutionPreset.medium);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  void _simulateScan() {
    setState(() => isProcessing = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          isProcessing = false;
          resultText = "IDENTITY VERIFIED\nUser: Admin Warden\n${DateFormat('EEE, MMM d, yyyy').format(DateTime.now())}\nTime: ${DateFormat('hh:mm:ss a').format(DateTime.now())}";
        });
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          // Scan Overlay
          Center(
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          // Animated Scanning Line
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Positioned(
                top: (MediaQuery.of(context).size.height / 2 - 125) + (_animController.value * 250),
                left: MediaQuery.of(context).size.width / 2 - 125,
                child: Container(width: 250, height: 3, color: Colors.greenAccent, decoration: const BoxDecoration(boxShadow: [BoxShadow(color: Colors.green, blurRadius: 10)])),
              );
            },
          ),
          // Back Button
          Positioned(top: 40, left: 20, child: CircleAvatar(backgroundColor: Colors.white, child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.black)))),
          
          // Action & Results
          Positioned(
            bottom: 50, left: 20, right: 20,
            child: resultText == null ? 
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
              onPressed: isProcessing ? null : _simulateScan,
              child: Text(isProcessing ? "SCANNING..." : "START SCAN"),
            ) : _buildResultCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.isInward ? Colors.green : Colors.red, width: 4),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle, color: widget.isInward ? Colors.green : Colors.red, size: 50),
          const SizedBox(height: 10),
          Text(resultText!, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("DONE", style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}