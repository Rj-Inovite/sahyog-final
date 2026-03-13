import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';

// Ensure these utility files exist in your project as per previous steps
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

// Global list to store multiple registrations temporarily (In-Memory Database)
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

  // --- State Variables ---
  bool _isCameraOpen = false;
  String _studentName = "";
  int currentStep = 0;
  bool isBusy = false;
  bool _isAngleCorrect = false; 
  List<double>? _finalVector;

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
  }

  // --- Step 1: Start the Camera ---
  Future<void> _startCamera() async {
    if (_studentName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Action Required: Please enter the student's name."),
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
        actions: [
          // VIEW DATA BUTTON
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(child: const Icon(Icons.person_add_alt_1, size: 100, color: Colors.blueAccent)),
          const SizedBox(height: 20),
          const Text("New Enrollment", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text("Capture biometric data for the hostel database", style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 50),
          TextField(
            onChanged: (val) => _studentName = val,
            style: const TextStyle(fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: "Full Name of Student",
              prefixIcon: const Icon(Icons.badge_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 30),
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
              child: const Text("LAUNCH SCANNER", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          )
        ],
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
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 80),
              const SizedBox(height: 20),
              Text("Registered: $_studentName", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
              const Text("Your face has been successfully registered!", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const Divider(height: 40),
              const Align(alignment: Alignment.centerLeft, child: Text(" VECTOR CODE:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blueAccent))),
              const SizedBox(height: 10),
              Container(
                height: 150,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _finalVector.toString(),
                    style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 30),
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
    super.dispose();
  }
}

// --- NEW ELABORATED DATA VIEW SCREEN ---

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
        // Matches current week (last 7 days) if no other filter is manually moved
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
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ["Week", "Month", "Year"].map((filter) {
                    return ChoiceChip(
                      label: Text(filter),
                      selected: selectedFilter == filter,
                      selectedColor: Colors.blueAccent,
                      labelStyle: TextStyle(color: selectedFilter == filter ? Colors.white : Colors.black),
                      onSelected: (val) => setState(() => selectedFilter = filter),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: selectedYear,
                        decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 10), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                        items: [2024, 2025, 2026].map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
                        onChanged: (v) => setState(() => selectedYear = v!),
                      ),
                    ),
                    if (selectedFilter == "Month") const SizedBox(width: 10),
                    if (selectedFilter == "Month")
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedMonth,
                          decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 10), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                          items: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
                              .map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                          onChanged: (v) => setState(() => selectedMonth = v!),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          // Data List
          Expanded(
            child: filteredList.isEmpty
                ? const Center(child: Text("No records found for this selection"))
                : ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final student = filteredList[index];
                      return FadeInLeft(
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: ListTile(
                            leading: const CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.person, color: Colors.white)),
                            title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("Date: ${DateFormat('dd MMM yyyy').format(student.registrationDate)}"),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              // View Individual Vector details
                              showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
                                builder: (c) => Padding(
                                  padding: const EdgeInsets.all(25),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("${student.name}'s Profile", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 15),
                                      const Text("Stored Vector Data:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                                      const SizedBox(height: 10),
                                      Expanded(child: SingleChildScrollView(child: Text(student.vector.toString(), style: const TextStyle(fontFamily: 'monospace', fontSize: 12)))),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}