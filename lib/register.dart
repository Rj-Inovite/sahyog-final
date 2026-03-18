// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for Clipboard functionality
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';

// --- YOUR PROJECT SPECIFIC IMPORTS ---
// Ensure these paths match your actual project structure
import 'package:my_app/data/models/network/api_service.dart'; 
import 'screens/utils/camera_utils.dart';
import 'screens/utils/image_utils.dart';

// =========================================================
// GLOBAL PERSISTENCE & MODELS
// =========================================================

/// Model to store local registration logs for the "Records" screen
class EnrollmentRecord {
  final String studentName;
  final String institute;
  final List<double> faceVector;
  final String? imagePath;
  final DateTime registeredAt;

  EnrollmentRecord({
    required this.studentName,
    required this.institute,
    required this.faceVector,
    this.imagePath,
    required this.registeredAt,
  });
}

// Global lists to maintain state across screens during the app session
List<EnrollmentRecord> globalHistoryLogs = [];
Set<int> verifiedStudentIds = {}; // IDs in this set will turn GREEN in the UI

// =========================================================
// MAIN REGISTRATION SCREEN
// =========================================================

class RegisterStudent extends StatefulWidget {
  const RegisterStudent({super.key});

  @override
  State<RegisterStudent> createState() => _RegisterStudentState();
}

class _RegisterStudentState extends State<RegisterStudent> {
  // Controllers
  CameraController? _cameraController;
  final TextEditingController _mainSearchController = TextEditingController();
  
  // State Management
  bool _isScannerOpen = false;
  dynamic _currentSelectedStudent; // Holds the Map/Object from your API
  int _registrationStep = 0;
  bool _isFinalizingCapture = false;
  
  List<double>? _generatedVectorData;
  String? _tempImagePath;

  // API Data Lists
  List<dynamic> _rawApiData = [];
  List<dynamic> _filteredDropdownList = [];
  bool _isFetchingFromApi = true;

  // Step-by-Step Instructions
  final List<String> _scanInstructions = [
    "Position Face Straight in Center",
    "Slowly Turn Your Head to the Left",
    "Slowly Turn Your Head to the Right",
    "Tilt Your Chin Upwards",
    "Tilt Your Chin Downwards",
    "Stay Completely Still for Final Scan"
  ];

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  /// Fetches real data from your integrated apiService
  Future<void> _fetchStudents() async {
    try {
      setState(() => _isFetchingFromApi = true);
      // Calling your project's getPendingEnrollments()
      final response = await apiService.getPendingEnrollments();
      
      if (response != null && response['success'] == true) {
        setState(() {
          _rawApiData = response['data'];
          _filteredDropdownList = _rawApiData;
        });
      }
    } catch (e) {
      _triggerNotification("Failed to load students: $e", Colors.red);
    } finally {
      setState(() => _isFetchingFromApi = false);
    }
  }

  /// Handles real-time search filtering for the dropdown
  void _onSearchChanged(String value) {
    setState(() {
      _filteredDropdownList = _rawApiData
          .where((s) => s['student_name']
              .toString()
              .toLowerCase()
              .contains(value.toLowerCase()))
          .toList();
    });
  }

  /// Initializes the front camera for scanning
  Future<void> _initScanHardware() async {
    if (_currentSelectedStudent == null) {
      _triggerNotification("Please select a student from the list first.", Colors.orange);
      return;
    }
    final cams = await availableCameras();
    // Index 1 is usually the front-facing camera
    _cameraController = CameraController(cams[1], ResolutionPreset.veryHigh, enableAudio: false);
    await _cameraController!.initialize();
    setState(() => _isScannerOpen = true);
  }

  /// ✅ CORE LOGIC: Manual click progresses the step immediately
  void _handleManualConfirmation() {
    if (_registrationStep < 5) {
      setState(() {
        _registrationStep++;
      });
      HapticFeedback.mediumImpact(); // Professional haptic feel
    } else {
      _finalizeFaceEnrollment();
    }
  }

  /// Captures the image, generates vector, and updates status to GREEN
  Future<void> _finalizeFaceEnrollment() async {
    setState(() => _isFinalizingCapture = true);
    try {
      final XFile capturedFile = await _cameraController!.takePicture();
      
      // Generating a precise 192-dimension mock vector
      // In production, this replaces with your TFLite output
      final List<double> vector = List.generate(192, (i) => (i * 0.73) / 1.1);

      // 1. Log into the global history for the Records screen
      globalHistoryLogs.add(EnrollmentRecord(
        studentName: _currentSelectedStudent['student_name'],
        institute: _currentSelectedStudent['educational_institute'] ?? "General",
        faceVector: vector,
        imagePath: capturedFile.path,
        registeredAt: DateTime.now(),
      ));

      // 2. IMPORTANT: Turn the student status to GREEN in the Dashboard
      verifiedStudentIds.add(_currentSelectedStudent['id']);

      setState(() {
        _generatedVectorData = vector;
        _tempImagePath = capturedFile.path;
        _isFinalizingCapture = false;
      });

      _showVectorSuccessDialog();
      
      // Send the generated vector back to your server via apiService
      apiService.submitEnrollment(_currentSelectedStudent['id'], vector);

    } catch (e) {
      setState(() => _isFinalizingCapture = false);
      _triggerNotification("Capture Error: $e", Colors.red);
    }
  }

  /// Displays the final result with the Copy Vector functionality
  void _showVectorSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FadeInUp(
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 70),
              const SizedBox(height: 15),
              Text(_currentSelectedStudent['student_name'], 
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const Text("BIOMETRIC DATA GENERATED", 
                style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.2)),
              const Divider(height: 30),
              if (_tempImagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(File(_tempImagePath!), height: 140, width: 140, fit: BoxFit.cover),
                ),
              const SizedBox(height: 20),
              const Text("VECTOR CODE (192-DIM):", 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.blueGrey)),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                child: Text(_generatedVectorData!.take(24).join(', ') + "...", 
                  style: const TextStyle(fontSize: 9, fontFamily: 'monospace'), textAlign: TextAlign.center),
              ),
              const SizedBox(height: 15),
              // ✅ ACTION: Vector Copying Feature
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _generatedVectorData.toString()));
                  _triggerNotification("Vector Code Copied to Clipboard", Colors.green);
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const Text("COPY VECTOR CODE"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[800], foregroundColor: Colors.white),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, 
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _isScannerOpen = false;
                    _registrationStep = 0;
                    _currentSelectedStudent = null;
                    _mainSearchController.clear();
                  });
                },
                child: const Text("FINISH & RETURN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _triggerNotification(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      appBar: AppBar(
        title: const Text("Student Face Enrollment", style: TextStyle(fontWeight: FontWeight.w800)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_edu, color: Colors.blueAccent),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const EnrollmentHistoryScreen())),
          )
        ],
      ),
      body: _isScannerOpen ? _buildScannerInterface() : _buildSelectionInterface(),
    );
  }

  // --- UI PART 1: SEARCH & DROPDOWN SELECTION ---
  Widget _buildSelectionInterface() {
    return Column(
      children: [
        // Search Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(color: Colors.white),
          child: TextField(
            controller: _mainSearchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: "Search student database...",
              prefixIcon: const Icon(Icons.person_search),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            ),
          ),
        ),
        
        // Integrated Dropdown
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<dynamic>(
                isExpanded: true,
                hint: const Text("Select Student from List"),
                value: _currentSelectedStudent,
                items: _filteredDropdownList.map((student) {
                  return DropdownMenuItem(
                    value: student,
                    child: Text(student['student_name'] ?? "Unknown Student"),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _currentSelectedStudent = val),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Visual Selection Card
        if (_currentSelectedStudent != null)
          FadeInDown(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  // ✅ ACTION: UI TURNS GREEN IF ALREADY ENROLLED
                  color: verifiedStudentIds.contains(_currentSelectedStudent['id']) ? Colors.green[50] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: verifiedStudentIds.contains(_currentSelectedStudent['id']) ? Colors.green : Colors.blueAccent,
                    width: 2
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(20),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: verifiedStudentIds.contains(_currentSelectedStudent['id']) ? Colors.green : Colors.blueAccent,
                    child: Icon(
                      verifiedStudentIds.contains(_currentSelectedStudent['id']) ? Icons.verified : Icons.face, 
                      color: Colors.white, size: 30
                    ),
                  ),
                  title: Text(_currentSelectedStudent['student_name'], 
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  subtitle: Text(
                    verifiedStudentIds.contains(_currentSelectedStudent['id']) 
                    ? "Face Scan Verified" 
                    : "Action Required: Biometric Enrollment",
                    style: TextStyle(color: verifiedStudentIds.contains(_currentSelectedStudent['id']) ? Colors.green[700] : Colors.blueGrey),
                  ),
                ),
              ),
            ),
          ),

        const Spacer(),
        
        // Action Button
        if (_currentSelectedStudent != null)
          Padding(
            padding: const EdgeInsets.all(30),
            child: FadeInUp(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 70),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 8,
                ),
                onPressed: _initScanHardware,
                child: const Text("INITIALIZE FACE SCAN", 
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              ),
            ),
          )
      ],
    );
  }

  // --- UI PART 2: THE ACTIVE SCANNER ---
  Widget _buildScannerInterface() {
    return Stack(
      children: [
        if (_cameraController != null) Positioned.fill(child: CameraPreview(_cameraController!)),
        
        // Face Mask Overlay
        Center(
          child: Container(
            width: 280, height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 4),
            ),
          ),
        ),

        // Bottom Controls Container
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(45)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (_registrationStep + 1) / 6,
                    minHeight: 10,
                    backgroundColor: Colors.grey[100],
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 25),
                Text("PROGRESS: STEP ${_registrationStep + 1} OF 6", 
                  style: const TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 12)),
                const SizedBox(height: 12),
                Text(_scanInstructions[_registrationStep], 
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black)),
                const SizedBox(height: 35),
                _isFinalizingCapture 
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, 
                      minimumSize: const Size(double.infinity, 65),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: _handleManualConfirmation, 
                    child: Text(_registrationStep == 5 ? "GENERATE BIOMETRICS" : "CONFIRM POSITION", 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
              ],
            ),
          ),
        ),

        // Close Overlay Button
        Positioned(
          top: 40, right: 20,
          child: CircleAvatar(
            backgroundColor: Colors.black45,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white), 
              onPressed: () => setState(() => _isScannerOpen = false)
            ),
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _mainSearchController.dispose();
    super.dispose();
  }
}

// =========================================================
// ENROLLMENT HISTORY & SEARCH LOGS
// =========================================================

class EnrollmentHistoryScreen extends StatefulWidget {
  const EnrollmentHistoryScreen({super.key});
  @override
  State<EnrollmentHistoryScreen> createState() => _EnrollmentHistoryScreenState();
}

class _EnrollmentHistoryScreenState extends State<EnrollmentHistoryScreen> {
  DateTime _filterDate = DateTime.now();
  String _activeFilterScope = "Day"; // Day, Month, Year
  String _logQuery = "";

  @override
  Widget build(BuildContext context) {
    // Applying Date and Name filters to the global history
    final filteredHistory = globalHistoryLogs.where((log) {
      bool nameMatches = log.studentName.toLowerCase().contains(_logQuery.toLowerCase());
      bool dateMatches = false;

      if (_activeFilterScope == "Day") {
        dateMatches = log.registeredAt.day == _filterDate.day && 
                      log.registeredAt.month == _filterDate.month && 
                      log.registeredAt.year == _filterDate.year;
      } else if (_activeFilterScope == "Month") {
        dateMatches = log.registeredAt.month == _filterDate.month && 
                      log.registeredAt.year == _filterDate.year;
      } else {
        dateMatches = log.registeredAt.year == _filterDate.year;
      }
      return nameMatches && dateMatches;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(title: const Text("Enrollment Records")),
      body: Column(
        children: [
          // Filter Header
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  onChanged: (v) => setState(() => _logQuery = v),
                  decoration: InputDecoration(
                    hintText: "Filter by student name...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    DropdownButton<String>(
                      value: _activeFilterScope,
                      items: ["Day", "Month", "Year"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() => _activeFilterScope = v!),
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(context: context, initialDate: _filterDate, firstDate: DateTime(2024), lastDate: DateTime(2030));
                        if (picked != null) setState(() => _filterDate = picked);
                      }, 
                      icon: const Icon(Icons.calendar_month, size: 18), 
                      label: Text(DateFormat('dd MMM yyyy').format(_filterDate))
                    )
                  ],
                ),
              ],
            ),
          ),
          
          Expanded(
            child: filteredHistory.isEmpty 
              ? const Center(child: Text("No enrollment records found for this period."))
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: filteredHistory.length,
                  itemBuilder: (context, i) {
                    final log = filteredHistory[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        leading: log.imagePath != null 
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(File(log.imagePath!), width: 50, height: 50, fit: BoxFit.cover))
                          : const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(log.studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${log.institute} • ${DateFormat('hh:mm a').format(log.registeredAt)}"),
                        trailing: const Icon(Icons.verified, color: Colors.green),
                      ),
                    );
                  },
                ),
          )
        ],
      ),
    );
  }
}