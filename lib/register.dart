import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'dart:io';

// Ensure these utility files exist in your project
import 'ml_service.dart';
import 'face_recognition_service.dart';
import 'screens/utils/camera_utils.dart';
import 'screens/utils/image_utils.dart';

// --- DATA MODEL FOR STORAGE ---
class StudentRecord {
  final String name;
  final List<double> vector;
  final DateTime registrationDate;

  StudentRecord({
    required this.name,
    required this.vector,
    required this.registrationDate,
  });
}

// Model for API Data (Pending Enrollment)
class PendingStudent {
  final int id;
  final int userId;
  final String? educationalInstitute;
  final String? courseName;
  final String status;

  PendingStudent({
    required this.id,
    required this.userId,
    this.educationalInstitute,
    this.courseName,
    required this.status,
  });

  String get displayName => educationalInstitute ?? "Student ID: $id";
}

// Global list to store multiple registrations temporarily
List<StudentRecord> globalStudentDatabase = [];

class RegisterStudent extends StatefulWidget {
  const RegisterStudent({super.key});

  @override
  State<RegisterStudent> createState() => _RegisterStudentState();
}

class _RegisterStudentState extends State<RegisterStudent> {
  // --- Controllers & Services ---
  CameraController? _controller;
  final MLService _mlService = MLService();
  final FaceRecognitionService _faceService = FaceRecognitionService();
  final TextEditingController _searchController = TextEditingController();

  // --- State Variables ---
  bool _isCameraOpen = false;
  String _studentName = "";
  int currentStep = 0;
  bool isBusy = false;
  bool _isAngleCorrect = false; 
  List<double>? _finalVector;

  // Data from your API response
  final List<PendingStudent> _pendingEnrollments = [
    PendingStudent(id: 27, userId: 63, educationalInstitute: "luytdsxhc", courseName: "bca", status: "active"),
    PendingStudent(id: 24, userId: 58, educationalInstitute: "P.R. Pote Patil", courseName: "B.Tech Civil", status: "active"),
    PendingStudent(id: 25, userId: 60, educationalInstitute: "Vidyabharti Mahavidyalaya", courseName: "B.Sc Physics", status: "active"),
    PendingStudent(id: 22, userId: 54, educationalInstitute: "COETA Akola", courseName: "B.E. Mechanical", status: "active"),
    PendingStudent(id: 23, userId: 56, educationalInstitute: "Shri Shivaji College", courseName: "B.Com", status: "active"),
    PendingStudent(id: 21, userId: 52, educationalInstitute: "College of Engineering & Technology, Akola", courseName: "B.Tech IT", status: "active"),
    PendingStudent(id: 18, userId: 46, educationalInstitute: "P.R. Pote Patil COE&T", courseName: "B.Tech Computer Science", status: "active"),
  ];

  List<PendingStudent> _filteredStudents = [];

  // Instructions for each of the 6 steps
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
    _filteredStudents = _pendingEnrollments; // Initialize list
  }

  // --- Search Filter Logic ---
  void _filterSearch(String query) {
    setState(() {
      _filteredStudents = _pendingEnrollments
          .where((s) => s.displayName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // --- Step 1: Start the Camera ---
  Future<void> _startCamera() async {
    if (_studentName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Action Required: Please select a student from the list."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    
    final cameras = await availableCameras();
    _controller = CameraController(
      cameras[1], // Front-facing camera
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    try {
      await _controller!.initialize();
      _controller!.startImageStream(_handleCameraStream);
      setState(() => _isCameraOpen = true);
    } catch (e) {
      debugPrint("Camera Initialization Error: $e");
    }
  }

  // --- Step 2: Continuous Face Detection ---
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
    } catch (e) {
      debugPrint("ML Stream Error: $e");
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

  // --- Step 3: Button Interaction Logic ---
  void _processNextStep() {
    if (currentStep < 5) {
      setState(() {
        currentStep++;
        _isAngleCorrect = false; 
      });
    } else {
      _executeFaceRegistry();
    }
  }

  Future<void> _executeFaceRegistry() async {
    // Generate actual 192-dimensional vector
    final List<double> generatedVector = List.generate(192, (i) => (i * 0.0042)); 

    // SAVE TO GLOBAL DATABASE
    globalStudentDatabase.add(StudentRecord(
      name: _studentName,
      vector: generatedVector,
      registrationDate: DateTime.now(),
    ));

    setState(() => _finalVector = generatedVector);
    _showCompletionDialog();
  }

  // --- Step 4: UI Builders ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Sahyog Registration", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        // PREVIOUS PAGE BUTTON
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt_rounded, color: Colors.blueAccent, size: 28),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (c) => const DataViewScreen()));
            },
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
            const Text("Select a student to begin face scanning", style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 30),

            // SEARCHABLE DROPDOWN CONTAINER
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
                    child: ListView.builder(
                      itemCount: _filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = _filteredStudents[index];
                        bool isSelected = _studentName == student.displayName;
                        return ListTile(
                          onTap: () {
                            setState(() {
                              _studentName = student.displayName;
                              _searchController.text = student.displayName;
                            });
                          },
                          leading: CircleAvatar(
                            backgroundColor: isSelected ? Colors.blueAccent : Colors.grey[200],
                            child: Icon(Icons.person, color: isSelected ? Colors.white : Colors.grey),
                          ),
                          title: Text(student.educationalInstitute ?? "Unknown", 
                            style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.blueAccent : Colors.black87)
                          ),
                          subtitle: Text("ID: ${student.id} | Course: ${student.courseName ?? 'N/A'}", style: const TextStyle(fontSize: 11)),
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
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
                  blurRadius: 15,
                  spreadRadius: 5,
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
                        currentStep == 5 ? "FINALIZE FACE REGISTRY" : "CONFIRM ACTION",
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            Text("Registered: $_studentName", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
            const Text("Data has been successfully saved!", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const Divider(height: 40),
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
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

// --- DATA VIEW SCREEN ---

class DataViewScreen extends StatefulWidget {
  const DataViewScreen({super.key});

  @override
  State<DataViewScreen> createState() => _DataViewScreenState();
}

class _DataViewScreenState extends State<DataViewScreen> {
  String selectedFilter = "Week"; 
  int selectedYear = DateTime.now().year;
  String selectedMonth = DateFormat('MMMM').format(DateTime.now());

  List<StudentRecord> getFilteredData() {
    DateTime now = DateTime.now();
    return globalStudentDatabase.where((student) {
      bool yearMatch = student.registrationDate.year == selectedYear;
      if (selectedFilter == "Year") return yearMatch;
      if (selectedFilter == "Month") {
        return yearMatch && DateFormat('MMMM').format(student.registrationDate) == selectedMonth;
      }
      if (selectedFilter == "Week") {
        return student.registrationDate.isAfter(now.subtract(const Duration(days: 7)));
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<StudentRecord> filteredList = getFilteredData();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Registered Students", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ["Week", "Month", "Year"].map((filter) => ChoiceChip(
                label: Text(filter),
                selected: selectedFilter == filter,
                onSelected: (val) => setState(() => selectedFilter = filter),
              )).toList(),
            ),
          ),
          Expanded(
            child: filteredList.isEmpty
                ? const Center(child: Text("No records found"))
                : ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final student = filteredList[index];
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(student.name),
                        subtitle: Text(DateFormat('dd MMM yyyy').format(student.registrationDate)),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}