import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class MLService {
  // We initialize the detector with optimized settings for high-speed tracking
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      // 'accurate' is great, but 'fast' is better for the 6-step movement phase.
      // If you find detection is slow, switch this to FaceDetectorMode.fast
      performanceMode: FaceDetectorMode.accurate, 
      
      // Landmarks and Classification are heavy. 
      // Keep them true only if you plan to check for "Blink to Capture" later.
      enableLandmarks: true, 
      enableClassification: true, 
      
      // Tracking is CRITICAL for the 6-step process to ensure 
      // we are scanning the SAME student throughout the turn.
      enableTracking: true,
      
      // Setting a minimum face size prevents the AI from trying to detect 
      // small faces in the background.
      minFaceSize: 0.15,
    ),
  );

  // Process the camera image
  Future<List<Face>> getFaces(InputImage inputImage) async {
    try {
      final List<Face> faces = await _faceDetector.processImage(inputImage);
      return faces;
    } catch (e) {
      // In a release APK, avoid print(). Use debugPrint from flutter/foundation
      return [];
    }
  }

  // Close the detector to prevent memory leaks
  void dispose() {
    _faceDetector.close();
  }
}