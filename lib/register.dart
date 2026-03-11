// register.dart
// Full, self-contained registration module.
// Add to pubspec.yaml: camera, google_mlkit_face_detection, path_provider, animate_do, intl

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';

/// --------------------
/// Data model & storage
/// --------------------
class RegisteredUser {
  final String id;
  final String name;
  final String studentId;
  final String imagePath;
  final DateTime dateTime;
  final List<List<double>> embeddings;

  RegisteredUser({
    required this.id,
    required this.name,
    required this.studentId,
    required this.imagePath,
    required this.dateTime,
    required this.embeddings,
  });
}

/// In-memory list for the session
final List<RegisteredUser> registeredRecords = [];

/// --------------------
/// RegisterStudent form
/// --------------------
class RegisterStudent extends StatefulWidget {
  const RegisterStudent({super.key});

  @override
  State<RegisterStudent> createState() => _RegisterStudentState();
}

class _RegisterStudentState extends State<RegisterStudent> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _idCtrl = TextEditingController();
  final TextEditingController _roomCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _idCtrl.dispose();
    _roomCtrl.dispose();
    super.dispose();
  }

  void _startFaceRegistration() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameCtrl.text.trim();
    final sid = _idCtrl.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterFaceScreen(
          studentName: name,
          studentId: sid,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color themeYellow = Color(0xFFF9D423);
    const Color accentOrange = Color(0xFFFF8C42);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Register Student"),
        backgroundColor: accentOrange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _idCtrl,
                decoration: const InputDecoration(labelText: "Student ID"),
                validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _roomCtrl,
                decoration: const InputDecoration(labelText: "Room Number (optional)"),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeYellow,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: _startFaceRegistration,
                  child: const Text("Start Face Registration"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// --------------------
/// Face registration screen
/// --------------------
class RegisterFaceScreen extends StatefulWidget {
  final String studentName;
  final String studentId;

  const RegisterFaceScreen({
    super.key,
    required this.studentName,
    required this.studentId,
  });

  @override
  State<RegisterFaceScreen> createState() => _RegisterFaceScreenState();
}

class _RegisterFaceScreenState extends State<RegisterFaceScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;

  bool _isBusy = false;
  bool _isFaceAligned = false;
  String _statusMessage = "Align your face within the frame";
  int _currentStep = 0;

  final List<String> _instructions = [
    "Look straight at the camera",
    "Turn slightly left",
    "Turn slightly right",
    "Tilt your head slightly up",
    "Tilt your head slightly down",
    "Final high-quality capture"
  ];

  final List<XFile> _capturedImages = [];
  final List<List<double>> _capturedEmbeddings = []; // placeholder for TFLite vectors

  // Theme
  final Color _themeYellow = const Color(0xFFF9D423);
  final Color _accentOrange = const Color(0xFFFF8C42);
  final Color _softBlack = const Color(0xFF333333);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeDetector();
    _initializeCamera();
  }

  Future<void> _initializeDetector() async {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableLandmarks: true,
        enableContours: false,
        performanceMode: FaceDetectorMode.fast,
        enableClassification: true,
      ),
    );
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(front, ResolutionPreset.high, enableAudio: false);
      await _cameraController!.initialize();
      await _cameraController!.startImageStream(_processCameraImage);

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }

  // Helper to collect bytes from planes
  Uint8List _concatenatePlanes(CameraImage image) {
    final bytes = <int>[];
    for (final plane in image.planes) {
      bytes.addAll(plane.bytes);
    }
    return Uint8List.fromList(bytes);
  }

  InputImage? _convertCameraImageToInputImage(CameraImage image) {
    try {
      final bytes = _concatenatePlanes(image);
      final imageSize = Size(image.width.toDouble(), image.height.toDouble());

      final camera = _cameraController!.description;
      final rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
          InputImageRotation.rotation0deg;

      final format = InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;

      final metadata = InputImageMetadata(
        size: imageSize,
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      );

      return InputImage.fromBytes(bytes: bytes, metadata: metadata);
    } catch (e) {
      debugPrint("convertCameraImage error: $e");
      return null;
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isBusy || _faceDetector == null || _cameraController == null) return;
    _isBusy = true;

    try {
      final inputImage = _convertCameraImageToInputImage(image);
      if (inputImage == null) {
        _isBusy = false;
        return;
      }

      final faces = await _faceDetector!.processImage(inputImage);

      if (!mounted) return;

      if (faces.isEmpty) {
        setState(() {
          _isFaceAligned = false;
          _statusMessage = "No face detected";
        });
      } else {
        final face = faces.first;
        final centerX = face.boundingBox.center.dx;
        final viewCenter = image.width / 2;
        final dx = (centerX - viewCenter).abs();

        final faceWidth = face.boundingBox.width;
        final faceHeight = face.boundingBox.height;
        final faceSizeOk = faceWidth > image.width * 0.18 && faceHeight > image.height * 0.18;

        final aligned = dx < image.width * 0.18 && faceSizeOk;

        setState(() {
          _isFaceAligned = aligned;
          _statusMessage = aligned ? "Perfect! Capture now." : "Align face in guide";
        });
      }
    } catch (e) {
      debugPrint("Face detection error: $e");
    } finally {
      _isBusy = false;
    }
  }

  Future<void> _captureStep() async {
    if (!_isFaceAligned || _cameraController == null) return;

    try {
      // Stop stream to take a high-quality picture
      if (_cameraController!.value.isStreamingImages) {
        await _cameraController!.stopImageStream();
      }

      final XFile file = await _cameraController!.takePicture();

      final dir = await getApplicationDocumentsDirectory();
      final saved = await File(file.path).copy('${dir.path}/face_${widget.studentId}_${_capturedImages.length + 1}.jpg');

      setState(() {
        _capturedImages.add(XFile(saved.path));
      });

      // Placeholder embedding (empty) — integrate TFLite here
      _capturedEmbeddings.add(<double>[]);

      if (_capturedImages.length >= 6) {
        _finishRegistration();
      } else {
        _currentStep = _capturedImages.length;
        // resume stream
        if (!_cameraController!.value.isStreamingImages) {
          await _cameraController!.startImageStream(_processCameraImage);
        }
        setState(() {});
      }
    } catch (e) {
      debugPrint("Capture error: $e");
      // try to resume stream
      try {
        if (_cameraController != null && !_cameraController!.value.isStreamingImages) {
          await _cameraController!.startImageStream(_processCameraImage);
        }
      } catch (_) {}
    }
  }

  void _finishRegistration() {
    try {
      if (_cameraController!.value.isStreamingImages) {
        _cameraController!.stopImageStream();
      }
    } catch (_) {}
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegistrationSummaryScreen(
          images: List<XFile>.from(_capturedImages),
          embeddings: List<List<double>>.from(_capturedEmbeddings),
          studentName: widget.studentName,
          studentId: widget.studentId,
          onSubmit: _onSubmitRegistration,
          onRetake: _onRetakeStep,
        ),
      ),
    ).then((_) async {
      // Reset after returning
      _capturedImages.clear();
      _capturedEmbeddings.clear();
      _currentStep = 0;
      _statusMessage = "Align your face within the frame";
      _isFaceAligned = false;
      if (_cameraController != null && !_cameraController!.value.isStreamingImages) {
        await _cameraController!.startImageStream(_processCameraImage);
      }
      if (mounted) setState(() {});
    });
  }

  void _onSubmitRegistration(List<XFile> images, List<List<double>> embeddings, String name, String sid) {
    final id = "USER-${registeredRecords.length + 1}";
    final finalImagePath = images.isNotEmpty ? images.last.path : '';
    registeredRecords.add(RegisteredUser(
      id: id,
      name: name,
      studentId: sid,
      imagePath: finalImagePath,
      dateTime: DateTime.now(),
      embeddings: embeddings,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Face registration recorded successfully!")),
    );
  }

  Future<void> _onRetakeStep(int index) async {
    if (index < 0 || index >= _capturedImages.length) return;
    setState(() {
      _capturedImages.removeAt(index);
      if (index < _capturedEmbeddings.length) _capturedEmbeddings.removeAt(index);
      _currentStep = index;
    });

    // Restart stream to capture again
    if (_cameraController != null && !_cameraController!.value.isStreamingImages) {
      await _cameraController!.startImageStream(_processCameraImage);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _faceDetector?.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final CameraController? cameraController = _cameraController;
    if (cameraController == null || !cameraController.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      await cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      await _initializeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final stepCount = 6;
    final progress = (_currentStep + 1) / stepCount;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Face Registration", style: TextStyle(color: Colors.black)),
        backgroundColor: _themeYellow,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            color: _themeYellow.withOpacity(0.06),
            child: Row(
              children: [
                Text("Step ${_currentStep + 1} of $stepCount", style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      color: _accentOrange,
                      minHeight: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FadeInDown(
            key: ValueKey<int>(_currentStep),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _instructions[_currentStep],
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: _softBlack),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 320,
                    height: 320,
                    child: ClipOval(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: CameraPreview(_cameraController!),
                      ),
                    ),
                  ),
                  Container(
                    width: 330,
                    height: 330,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isFaceAligned ? _themeYellow : Colors.grey.withOpacity(0.5),
                        width: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  _statusMessage,
                  style: TextStyle(color: _isFaceAligned ? Colors.green : _accentOrange, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      final captured = index < _capturedImages.length;
                      return Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: captured ? _themeYellow : Colors.transparent, width: 2),
                        ),
                        child: captured
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(File(_capturedImages[index].path), fit: BoxFit.cover),
                              )
                            : Icon(Icons.face, color: Colors.grey[300]),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                ZoomIn(
                  child: ElevatedButton(
                    onPressed: _isFaceAligned ? _captureStep : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _themeYellow,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text(
                      _capturedImages.length < 5 ? "CAPTURE ANGLE" : "CAPTURE FINAL",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.grey))),
                    TextButton(
                      onPressed: _capturedImages.isNotEmpty ? _finishRegistration : null,
                      child: Text("REVIEW (${_capturedImages.length})", style: TextStyle(color: _capturedImages.isNotEmpty ? _accentOrange : Colors.grey)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// --------------------
/// Summary screen
/// --------------------
class RegistrationSummaryScreen extends StatefulWidget {
  final List<XFile> images;
  final List<List<double>> embeddings;
  final String studentName;
  final String studentId;
  final void Function(List<XFile>, List<List<double>>, String, String) onSubmit;
  final Future<void> Function(int index) onRetake;

  const RegistrationSummaryScreen({
    super.key,
    required this.images,
    required this.embeddings,
    required this.studentName,
    required this.studentId,
    required this.onSubmit,
    required this.onRetake,
  });

  @override
  State<RegistrationSummaryScreen> createState() => _RegistrationSummaryScreenState();
}

class _RegistrationSummaryScreenState extends State<RegistrationSummaryScreen> {
  late List<XFile> _images;
  late List<List<double>> _embeddings;

  @override
  void initState() {
    super.initState();
    _images = List<XFile>.from(widget.images);
    _embeddings = List<List<double>>.from(widget.embeddings);
  }

  Future<void> _retake(int index) async {
    await widget.onRetake(index);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final Color themeYellow = const Color(0xFFF9D423);

    return Scaffold(
      appBar: AppBar(title: const Text("Review Scans"), backgroundColor: themeYellow, foregroundColor: Colors.black),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12),
              itemCount: 6,
              itemBuilder: (context, index) {
                final has = index < _images.length;
                return GestureDetector(
                  onTap: has ? () => _showPreview(index) : null,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[100],
                      border: Border.all(color: has ? themeYellow : Colors.transparent, width: 2),
                    ),
                    child: has
                        ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(_images[index].path), fit: BoxFit.cover))
                        : const Center(child: Icon(Icons.face, color: Colors.grey)),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: _images.isNotEmpty
                  ? () {
                      widget.onSubmit(_images, _embeddings, widget.studentName, widget.studentId);
                      Navigator.pop(context);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeYellow,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("SUBMIT REGISTRATION", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _showPreview(int index) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(File(_images[index].path)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("CLOSE")),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _retake(index);
                  },
                  child: const Text("RETAKE", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// --------------------
/// Registered faces listing
/// --------------------
class RegisteredFacesScreen extends StatelessWidget {
  const RegisteredFacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color themeYellow = const Color(0xFFF9D423);

    return Scaffold(
      appBar: AppBar(title: const Text("Registered Faces"), backgroundColor: themeYellow, foregroundColor: Colors.black),
      body: registeredRecords.isEmpty
          ? const Center(child: Text("No records found."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: registeredRecords.length,
              itemBuilder: (context, index) {
                final record = registeredRecords[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(radius: 30, backgroundImage: FileImage(File(record.imagePath))),
                    title: Text(record.id, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${record.name} • ${record.studentId}\n${DateFormat('yyyy-MM-dd HH:mm').format(record.dateTime)}"),
                    trailing: const Icon(Icons.check_circle, color: Colors.green),
                  ),
                );
              },
            ),
    );
  }
}
