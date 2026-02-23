import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class MarkPage extends StatefulWidget {
  final Color roleColor;
  final String userName;

  const MarkPage({super.key, required this.roleColor, this.userName = "Student User"});

  @override
  State<MarkPage> createState() => _MarkPageState();
}

class _MarkPageState extends State<MarkPage> with TickerProviderStateMixin {
  // Camera variables
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  // Scanning Logic
  bool _isScanning = true;
  double _scanProgress = 0.0;
  String _statusMessage = "Align face in frame";
  bool _isSuccess = false;
  String _entryType = "IN"; // Toggle between IN and OUT

  // Logging and Filtering
  static List<Map<String, dynamic>> _permanentLog = []; // Static to persist during app session
  String _selectedFilter = "All";
  
  late AnimationController _lineController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
        setState(() {
          _scanProgress = _lineController.value;
          _updateScanningLogic();
        });
      });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _lineController.forward();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      // Select the front camera
      CameraDescription frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(frontCamera, ResolutionPreset.medium, enableAudio: false);
      await _controller!.initialize();
      if (mounted) setState(() => _isCameraInitialized = true);
    }
  }

  void _updateScanningLogic() {
    if (_scanProgress > 0.4 && _scanProgress < 0.7) {
      _statusMessage = "Identifying Biometrics...";
    } else if (_scanProgress >= 1.0 && !_isSuccess) {
      _completeProcess();
    }
  }

  void _completeProcess() {
    setState(() {
      _isScanning = false;
      _isSuccess = true;
      _statusMessage = "Access Granted: $_entryType";
      
      final now = DateTime.now();
      _permanentLog.insert(0, {
        'name': widget.userName,
        'time': DateFormat('hh:mm a').format(now),
        'date': now, // Keep as DateTime for filtering
        'day': DateFormat('EEEE').format(now),
        'type': _entryType,
      });
    });
  }

  List<Map<String, dynamic>> get _filteredLogs {
    final now = DateTime.now();
    return _permanentLog.where((log) {
      DateTime logDate = log['date'];
      if (_selectedFilter == "Today") return logDate.day == now.day && logDate.month == now.month;
      if (_selectedFilter == "Week") return now.difference(logDate).inDays <= 7;
      if (_selectedFilter == "Month") return logDate.month == now.month && logDate.year == now.year;
      return true;
    }).toList();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _lineController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text("BIOMETRIC SCAN", style: TextStyle(letterSpacing: 2, fontSize: 16)),
        backgroundColor: widget.roleColor,
        actions: [
          _buildFilterDropdown(),
        ],
      ),
      body: Row(
        children: [
          // MAIN PANEL
          Expanded(
            flex: 4,
            child: Column(
              children: [
                _buildTypeToggle(),
                const SizedBox(height: 10),
                _buildScannerFrame(),
                _buildInfoCard(),
              ],
            ),
          ),
          // LOG PANEL
          _buildSideLog(),
        ],
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: ["IN", "OUT"].map((type) {
            bool isSelected = _entryType == type;
            return GestureDetector(
              onTap: () => setState(() => _entryType = type),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? (type == "IN" ? Colors.green : Colors.red) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(type, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildScannerFrame() {
    return Expanded(
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Camera Feed
            Container(
              width: 300,
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: widget.roleColor, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: _isCameraInitialized 
                    ? CameraPreview(_controller!)
                    : const Center(child: CircularProgressIndicator()),
              ),
            ),
            // Scanning Line
            if (_isScanning)
              Positioned(
                top: 400 * _scanProgress,
                child: Container(
                  width: 300,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.cyanAccent,
                    boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)],
                  ),
                ),
              ),
            // Success Message Overlay
            if (_isSuccess)
              Container(
                width: 300,
                height: 400,
                color: Colors.black54,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified, color: Colors.greenAccent, size: 80),
                    const SizedBox(height: 10),
                    Text(widget.userName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(DateFormat('hh:mm a | EEEE').format(DateTime.now()), 
                         style: const TextStyle(color: Colors.greenAccent, fontSize: 14)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _pulseController,
            child: Icon(Icons.circle, color: _isSuccess ? Colors.green : Colors.orange, size: 12),
          ),
          const SizedBox(width: 10),
          Text(_statusMessage, style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSideLog() {
    return Container(
      width: 160,
      decoration: const BoxDecoration(
        color: Color(0xFF161B33),
        border: Border(left: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(15),
            child: Text("RECENT ACTIVITY", style: TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredLogs.length,
              itemBuilder: (context, index) {
                final log = _filteredLogs[index];
                Color typeColor = log['type'] == "IN" ? Colors.greenAccent : Colors.redAccent;
                return Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: typeColor.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(log['type'], style: TextStyle(color: typeColor, fontWeight: FontWeight.bold, fontSize: 10)),
                      Text(log['name'], style: const TextStyle(color: Colors.white, fontSize: 11)),
                      Text("${log['time']}", style: const TextStyle(color: Colors.white54, fontSize: 9)),
                      Text("${log['day']}", style: const TextStyle(color: Colors.white38, fontSize: 8)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: DropdownButton<String>(
        value: _selectedFilter,
        dropdownColor: const Color(0xFF161B33),
        underline: const SizedBox(),
        icon: const Icon(Icons.filter_list, color: Colors.white),
        items: ["All", "Today", "Week", "Month"].map((String val) {
          return DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(color: Colors.white, fontSize: 12)));
        }).toList(),
        onChanged: (val) => setState(() => _selectedFilter = val!),
      ),
    );
  }
}