import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'dart:io';

// --- YOUR UTILITIES ---
// Note: Ensure your path to api_service.dart is correct based on your folder structure
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
  final String? educationalInstitute;
  final String? courseName;
  final String status;

  PendingStudent({
    required this.id,
    required this.userId,
    required this.studentName,
    this.educationalInstitute,
    this.courseName,
    required this.status,
  });

  factory PendingStudent.fromJson(Map<String, dynamic> json) {
    return PendingStudent(
      id: json['id'],
      userId: json['user_id'] ?? 0,
      studentName: json['student_name'] ?? "Unknown Student",
      educationalInstitute: json['educational_institute'],
      courseName: json['course_name'],
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

  // --- Logic: Updated to use ApiService ---
  Future<void> _fetchStudentsFromApi() async {
    try {
      setState(() => _isLoadingApi = true);
      
      // Using the centralized service instead of raw http calls
      final List<dynamic> dataList = await apiService.getPendingEnrollments();
      
      setState(() {
        _pendingEnrollments = dataList.map((s) => PendingStudent.fromJson(s)).toList();
        _filteredStudents = _pendingEnrollments;
        _isLoadingApi = false;
      });
    } catch (e) {
      setState(() => _isLoadingApi = false);
      _showSnackBar("Could not load pending enrollments", Colors.red);
      debugPrint("API Fetch Error: $e");
    }
  }

  void _filterSearch(String query) {
    setState(() {
      _filteredStudents = _pendingEnrollments
          .where((s) => s.displayName.toLowerCase().contains(query.toLowerCase()) || 
                        (s.educationalInstitute?.toLowerCase().contains(query.toLowerCase()) ?? false))
          .toList();
    });
  }

  Future<void> _startCamera() async {
    if (_studentName.trim().isEmpty) {
      _showSnackBar("Select a student from the list first.", Colors.redAccent);
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
      debugPrint("Camera Init Error: $e");
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
          if (mounted && _isAngleCorrect != correct) {
            setState(() => _isAngleCorrect = correct);
          }
        } else {
          if (mounted && _isAngleCorrect) {
            setState(() => _isAngleCorrect = false);
          }
        }
      }
    } finally {
      isBusy = false;
    }
  }

  bool _checkPoseAngle(Face face) {
    double headY = face.headEulerAngleY ?? 0;
    double headX = face.headEulerAngleX ?? 0;

    switch (currentStep) {
      case 0: return headY.abs() < 10 && headX.abs() < 10;
      case 1: return headY < -16;
      case 2: return headY > 16;
      case 3: return headX > 12;
      case 4: return headX < -10;
      case 5: return headY.abs() < 12 && headX.abs() < 12;
      default: return false;
    }
  }

  void _processNextStep() async {
    if (currentStep < 5) {
      setState(() {
        currentStep++;
        _isAngleCorrect = false; 
      });
    } else {
      try {
        await _controller!.stopImageStream();
        final XFile photo = await _controller!.takePicture();
        setState(() => _capturedImagePath = photo.path);
        
        _executeFaceRegistry();
      } catch (e) {
        _showSnackBar("Capture failed: $e", Colors.redAccent);
      }
    }
  }

  Future<void> _executeFaceRegistry() async {
    // Note: In production, replace this dummy vector with real output from _faceService
    final List<double> generatedVector = List.generate(192, (i) => (i * 0.0042)); 

    globalStudentDatabase.add(StudentRecord(
      name: _studentName,
      vector: generatedVector,
      imagePath: _capturedImagePath,
      registrationDate: DateTime.now(),
    ));

    setState(() => _finalVector = generatedVector);

    try {
      // Syncing with Web Panel
      await apiService.submitEnrollment(_selectedStudentId, generatedVector);
    } catch (e) {
      debugPrint("API Background Sync Failed: $e");
    }

    _showCompletionDialog();
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Sahyog Registration", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt_rounded, color: Colors.blueAccent, size: 28),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const DataViewScreen())),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _isCameraOpen ? _buildScannerLayout() : _buildInitialForm(),
    );
  }

  Widget _buildInitialForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          children: [
            FadeInDown(child: const Icon(Icons.face_retouching_natural_rounded, size: 80, color: Colors.blueAccent)),
            const SizedBox(height: 15),
            const Text("Biometric Enrollment", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const Text("Search and select a student to begin", style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 30),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, spreadRadius: 2)],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: _filterSearch,
                    decoration: InputDecoration(
                      hintText: "Search student or institute...",
                      prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  const Divider(height: 1),
                  SizedBox(
                    height: 250,
                    child: _isLoadingApi 
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredStudents.isEmpty 
                        ? const Center(child: Text("No pending enrollments found"))
                        : ListView.builder(
                            itemCount: _filteredStudents.length,
                            itemBuilder: (context, index) {
                              final student = _filteredStudents[index];
                              bool isSelected = _studentName == student.displayName;
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
                                title: Text(student.studentName, 
                                  style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.blueAccent : Colors.black87)
                                ),
                                subtitle: Text("${student.educationalInstitute ?? 'N/A'}\nID: ${student.id} | Course: ${student.courseName ?? 'N/A'}", style: const TextStyle(fontSize: 11)),
                                isThreeLine: true,
                                trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.blueAccent) : null,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 65,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 5,
                ),
                onPressed: _startCamera,
                child: const Text("START FACE SCANNER", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
                      ),
                      onPressed: _processNextStep, 
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
        title: const Center(child: Text("Registration Complete")),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_capturedImagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(File(_capturedImagePath!), height: 160, width: 160, fit: BoxFit.cover),
                ),
              const SizedBox(height: 20),
              Text("Student: $_studentName", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const Divider(height: 30),
              
              const Text("192-Dim Face Vector:", style: TextStyle(fontSize: 12, color: Colors.grey)),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(10),
                height: 80,
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                child: SingleChildScrollView(
                  child: Text(_finalVector.toString(), style: const TextStyle(fontSize: 10, fontFamily: 'monospace')),
                ),
              ),
              
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _finalVector.toString()));
                  _showSnackBar("Vector copied!", Colors.green);
                },
                icon: const Icon(Icons.copy, size: 18),
                label: const Text("Copy Vector Data"),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _isCameraOpen = false;
                    currentStep = 0;
                    _studentName = "";
                    _searchController.clear();
                  });
                },
                child: const Text("DONE & RETURN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Registered Students", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: globalStudentDatabase.isEmpty
          ? const Center(child: Text("No records found"))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: globalStudentDatabase.length,
              itemBuilder: (context, index) {
                final student = globalStudentDatabase[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: student.imagePath != null
                        ? CircleAvatar(backgroundImage: FileImage(File(student.imagePath!)))
                        : const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat('dd MMM yyyy').format(student.registrationDate)),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
                        builder: (c) => Padding(
                          padding: const EdgeInsets.all(25),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(student.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              Text("Vector: ${student.vector.toString()}", maxLines: 5, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 20),
                              ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}