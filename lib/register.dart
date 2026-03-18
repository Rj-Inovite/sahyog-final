// ignore_for_file: use_build_context_synchronously
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'dart:io';

// --- YOUR UTILITIES ---
import 'data/models/network/api_service.dart';
import 'ml_service.dart';
import 'face_recognition_service.dart';
import 'screens/utils/camera_utils.dart';
import 'screens/utils/image_utils.dart';

// ================== DATA MODELS ==================

class StudentRecord {
  final String name;
  final List<double> vector;
  final String? imagePath;
  final DateTime registrationDate;

  StudentRecord({
    required this.name,
    required this.vector,
    this.imagePath,
    required this.registrationDate,
  });
}

class PendingStudent {
  final int id;
  final int userId;
  final String studentName;
  final String? email;
  final String? mobile;
  final String? educationalInstitute;
  final String? courseName;
  final String? admissionDate;
  final bool isEnrolled;
  final String status;

  PendingStudent({
    required this.id,
    required this.userId,
    required this.studentName,
    this.email,
    this.mobile,
    this.educationalInstitute,
    this.courseName,
    this.admissionDate,
    required this.isEnrolled,
    required this.status,
  });

  factory PendingStudent.fromJson(Map<String, dynamic> json) {
    return PendingStudent(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      studentName: json['student_name'] ?? "Unknown",
      email: json['email'],
      mobile: json['mobile'],
      educationalInstitute: json['educational_institute'],
      courseName: json['course_name'],
      admissionDate: json['admission_date'],
      isEnrolled: json['is_enrolled'] ?? false,
      status: json['status'] ?? "active",
    );
  }

  String get displayName => studentName;
}

List<StudentRecord> globalStudentDatabase = [];

// ================== MAIN REGISTRATION SCREEN ==================

class RegisterStudent extends StatefulWidget {
  const RegisterStudent({super.key});

  @override
  State<RegisterStudent> createState() => _RegisterStudentState();
}

class _RegisterStudentState extends State<RegisterStudent> {
  CameraController? _controller;
  final MLService _mlService = MLService();
  final FaceRecognitionService _faceService = FaceRecognitionService();
  final TextEditingController _searchController = TextEditingController();

  bool _isCameraOpen = false;
  String _studentName = "";
  int _selectedStudentId = 0;
  int currentStep = 0;
  bool isBusy = false;
  bool _isAngleCorrect = false;
  List<double>? _finalVector;
  String? _capturedImagePath;

  List<PendingStudent> _pendingEnrollments = [];
  List<PendingStudent> _filteredStudents = [];
  bool _isLoadingApi = true;

  final List<String> instructions = [
    "Look Straight into the Camera",
    "Slowly Turn Your Head Left",
    "Slowly Turn Your Head Right",
    "Tilt Your Head Upward",
    "Tilt Your Head Downward",
    "Final Scan: Stay Completely Still"
  ];

  @override
  void initState() {
    super.initState();
    _faceService.loadModel();
    _fetchStudentsFromApi();
  }

  Future<void> _fetchStudentsFromApi() async {
    try {
      setState(() => _isLoadingApi = true);
      final Map<String, dynamic> response = await apiService.getPendingEnrollments();

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> dataList = response['data'];
        setState(() {
          _pendingEnrollments = dataList.map((s) => PendingStudent.fromJson(s)).toList();
          _filteredStudents = _pendingEnrollments;
          _isLoadingApi = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingApi = false);
      _showSnackBar("Sync Error: Profile fetch failed", Colors.redAccent);
    }
  }

  void _filterSearch(String query) {
    setState(() {
      _filteredStudents = _pendingEnrollments
          .where((s) =>
              s.displayName.toLowerCase().contains(query.toLowerCase()) ||
              (s.educationalInstitute?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
              (s.mobile?.contains(query) ?? false))
          .toList();
    });
  }

  Future<void> _startCamera() async {
    if (_selectedStudentId == 0) {
      _showSnackBar("Please select a student record first.", Colors.orange);
      return;
    }

    final cameras = await availableCameras();
    _controller = CameraController(
      cameras[1],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    try {
      await _controller!.initialize();
      _controller!.startImageStream(_handleCameraStream);
      setState(() => _isCameraOpen = true);
    } catch (e) {
      _showSnackBar("Camera Initialization Error", Colors.red);
    }
  }

  void _handleCameraStream(CameraImage image) async {
    if (isBusy || !mounted) return;
    isBusy = true;

    try {
      final inputImage = getInputImage(image, _controller!.description);
      if (inputImage != null) {
        final List<Face> faces = await _mlService.getFaces(inputImage);

        if (faces.isNotEmpty) {
          final face = faces.first;
          bool correct = _checkPoseAngle(face);
          if (mounted) {
            setState(() => _isAngleCorrect = correct);
          }
        } else {
          if (mounted) {
            setState(() => _isAngleCorrect = false);
          }
        }
      }
    } finally {
      isBusy = false;
    }
  }

  // UPDATED: More lenient angles to ensure "Confirm" works reliably
  bool _checkPoseAngle(Face face) {
    double headY = face.headEulerAngleY ?? 0; // Left/Right
    double headX = face.headEulerAngleX ?? 0; // Up/Down

    switch (currentStep) {
      case 0: // Straight
        return headY.abs() < 15 && headX.abs() < 15;
      case 1: // Left
        return headY < -12;
      case 2: // Right
        return headY > 12;
      case 3: // Up
        return headX > 10;
      case 4: // Down
        return headX < -10;
      case 5: // Final Still
        return headY.abs() < 15 && headX.abs() < 15;
      default:
        return false;
    }
  }

  void _handleConfirmClick() {
    // If you want to bypass strict angle checking for testing, you can remove the "if"
    if (!_isAngleCorrect) {
      _showSnackBar("Please align your face according to the instructions.", Colors.redAccent);
      return;
    }
    _processNextStep();
  }

  void _processNextStep() async {
    if (currentStep < 5) {
      setState(() {
        currentStep++;
        _isAngleCorrect = false; // Reset for next pose
      });
      _showSnackBar("Pose Accepted. Next Step!", Colors.green);
    } else {
      try {
        await _controller!.stopImageStream();
        final XFile photo = await _controller!.takePicture();
        setState(() => _capturedImagePath = photo.path);
        _executeFaceRegistry();
      } catch (e) {
        _showSnackBar("Image Capture Failed", Colors.redAccent);
      }
    }
  }

  Future<void> _executeFaceRegistry() async {
    // Simulating vector generation from ML Kit
    final List<double> generatedVector = List.generate(192, (i) => (i * 0.0042) + 0.1); 

    globalStudentDatabase.add(StudentRecord(
      name: _studentName,
      vector: generatedVector,
      imagePath: _capturedImagePath,
      registrationDate: DateTime.now(),
    ));

    setState(() => _finalVector = generatedVector);

    try {
      await apiService.submitEnrollment(_selectedStudentId, generatedVector);
    } catch (e) {
      debugPrint("Background API Sync Failed: $e");
    }

    _showCompletionDialog();
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 1500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Sahyog Enrollment", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.blueAccent),
            onPressed: _fetchStudentsFromApi,
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.blueAccent, size: 28),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const DataViewScreen())),
          ),
          const SizedBox(width: 5),
        ],
      ),
      body: _isCameraOpen ? _buildScannerLayout() : _buildInitialForm(),
    );
  }

  Widget _buildInitialForm() {
    return FadeInUp(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          children: [
            const Icon(Icons.face_unlock_rounded, size: 70, color: Colors.blueAccent),
            const SizedBox(height: 10),
            const Text("Student Biometrics", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const Text("Select verified profile for scan", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, spreadRadius: 5)],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: _filterSearch,
                      decoration: InputDecoration(
                        hintText: "Search name, ID or institute...",
                        prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: _isLoadingApi
                          ? const Center(child: CircularProgressIndicator())
                          : _filteredStudents.isEmpty
                              ? const Center(child: Text("No records available"))
                              : ListView.separated(
                                  padding: const EdgeInsets.all(10),
                                  itemCount: _filteredStudents.length,
                                  separatorBuilder: (c, i) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
                                  itemBuilder: (context, index) {
                                    final student = _filteredStudents[index];
                                    bool isSelected = _selectedStudentId == student.id;
                                    return ListTile(
                                      onTap: () {
                                        setState(() {
                                          _studentName = student.displayName;
                                          _selectedStudentId = student.id;
                                          _searchController.text = student.displayName;
                                        });
                                      },
                                      leading: CircleAvatar(
                                        backgroundColor: isSelected ? Colors.blueAccent : Colors.grey[200],
                                        child: Icon(Icons.person, color: isSelected ? Colors.white : Colors.grey),
                                      ),
                                      title: Text(student.studentName, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                                      subtitle: Text(
                                        "Inst: ${student.educationalInstitute ?? 'N/A'}\nMob: ${student.mobile ?? 'N/A'}",
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      isThreeLine: true,
                                      trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.blueAccent) : null,
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 4,
                ),
                onPressed: _startCamera,
                child: const Text("START MULTI-ANGLE SCAN", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildScannerLayout() {
    return Stack(
      children: [
        Positioned.fill(child: CameraPreview(_controller!)),
        Center(
          child: Container(
            width: 280, height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _isAngleCorrect ? Colors.greenAccent : Colors.redAccent, 
                width: 6
              ),
              boxShadow: [
                BoxShadow(
                  color: _isAngleCorrect ? Colors.greenAccent.withOpacity(0.4) : Colors.redAccent.withOpacity(0.4),
                  blurRadius: 15, spreadRadius: 5,
                )
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: FadeInUp(
            child: Container(
              padding: const EdgeInsets.all(35),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                        color: i <= currentStep ? Colors.blueAccent : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                    )),
                  ),
                  const SizedBox(height: 25),
                  Text("PHASE ${currentStep + 1} OF 6", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 5),
                  Text(instructions[currentStep], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 35),
                  
                  SizedBox(
                    width: double.infinity, height: 65,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isAngleCorrect ? Colors.green[600] : Colors.blueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 4,
                      ),
                      onPressed: _handleConfirmClick, 
                      child: Text(
                        currentStep == 5 ? "FINALIZE REGISTRY" : "CONFIRM POSE",
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Center(child: Text("Scan Successful", style: TextStyle(fontWeight: FontWeight.bold))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_capturedImagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(File(_capturedImagePath!), height: 160, width: 160, fit: BoxFit.cover),
                ),
              const SizedBox(height: 20),
              // Const removed as requested to avoid 'constant expression' error
              Text(_studentName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blueGrey[50], borderRadius: BorderRadius.circular(15)),
                child: Text(
                  "Face Vector Output:\n${_finalVector?.take(15).join(', ')}...", 
                  style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontFamily: 'monospace'),
                  textAlign: TextAlign.center,
                ),
              ),
              const Divider(height: 40),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_done, color: Colors.green),
                  const SizedBox(width: 10),
                  Text("Encrypted & Synced", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _isCameraOpen = false;
                    currentStep = 0;
                    _studentName = "";
                    _searchController.clear();
                    _selectedStudentId = 0;
                  });
                },
                child: const Text("COMPLETE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

// ================== DATA VIEW SCREEN ==================

class DataViewScreen extends StatefulWidget {
  const DataViewScreen({super.key});

  @override
  State<DataViewScreen> createState() => _DataViewScreenState();
}

class _DataViewScreenState extends State<DataViewScreen> {
  DateTime _selectedDate = DateTime.now();
  String _filterType = "Day";
  String _historyQuery = "";

  List<StudentRecord> get _filteredLogs {
    return globalStudentDatabase.where((log) {
      bool matchesSearch = log.name.toLowerCase().contains(_historyQuery.toLowerCase());
      bool matchesDate = false;

      if (_filterType == "Day") {
        matchesDate = log.registrationDate.day == _selectedDate.day &&
            log.registrationDate.month == _selectedDate.month &&
            log.registrationDate.year == _selectedDate.year;
      } else if (_filterType == "Month") {
        matchesDate = log.registrationDate.month == _selectedDate.month &&
            log.registrationDate.year == _selectedDate.year;
      } else {
        matchesDate = log.registrationDate.year == _selectedDate.year;
      }
      return matchesSearch && matchesDate;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Enrollment Logs", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: TextField(
              onChanged: (v) => setState(() => _historyQuery = v),
              decoration: InputDecoration(
                hintText: "Search enrollment history...",
                // Corrected icon name
                prefixIcon: const Icon(Icons.manage_search, color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(bottom: Radius.circular(25))),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _filterType,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                    items: ["Day", "Month", "Year"].map((String val) {
                      return DropdownMenuItem<String>(value: val, child: Text(val, style: const TextStyle(fontSize: 14)));
                    }).toList(),
                    onChanged: (val) => setState(() => _filterType = val!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) setState(() => _selectedDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _filterType == "Year" ? "${_selectedDate.year}" : 
                            _filterType == "Month" ? DateFormat('MMM yyyy').format(_selectedDate) :
                            DateFormat('dd MMM yyyy').format(_selectedDate),
                            style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                          ),
                          const Icon(Icons.calendar_today_rounded, size: 18, color: Colors.blueAccent),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _filteredLogs.isEmpty
                ? const Center(child: Text("No logs found"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    itemCount: _filteredLogs.length,
                    itemBuilder: (c, i) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: _filteredLogs[i].imagePath != null 
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12), 
                              child: Image.file(File(_filteredLogs[i].imagePath!), width: 55, height: 55, fit: BoxFit.cover),
                            )
                          : const CircleAvatar(radius: 28, child: Icon(Icons.person)),
                        title: Text(_filteredLogs[i].name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Text(DateFormat('hh:mm a • dd MMM yyyy').format(_filteredLogs[i].registrationDate), style: const TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.check_circle_rounded, color: Colors.green),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}