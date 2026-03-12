import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class FaceRecognitionService {
  late Interpreter interpreter;
  bool _isModelLoaded = false;

  // 1. Load the model from your specific assets path
  Future<void> loadModel() async {
    try {
      // Corrected: Setting threads for the latest tflite_flutter versions
      final options = InterpreterOptions()..threads = 4; // Using cascade operator

      interpreter = await Interpreter.fromAsset(
        'assets/mobilefacenet.tflite',
        options: options,
      );
      
      _isModelLoaded = true;
      print("✅ MobileFaceNet Model Loaded Successfully");
    } catch (e) {
      print("❌ Failed to load model: $e");
    }
  }

  // 2. The main function to turn an Image into a Vector
  List<double> runModel(img.Image faceImage) {
    if (!_isModelLoaded) {
      print("Model not loaded yet!");
      return [];
    }

    // A. Resize image to 112x112 (Standard for MobileFaceNet)
    img.Image resized = img.copyResize(faceImage, width: 112, height: 112);

    // B. Convert image to Float32 List [1, 112, 112, 3]
    var input = _imageToByteList(resized);

    // C. Define Output Buffer (MobileFaceNet outputs a 192-length vector)
    // Shape: [1, 192]
    var output = List.filled(1 * 192, 0.0).reshape([1, 192]);

    // D. Run Inference
    interpreter.run(input, output);

    // E. Return the first row of the output
    return List<double>.from(output[0]);
  }

  // Helper: Normalizes pixels to a range of -1 to 1 
  Float32List _imageToByteList(img.Image image) {
    var buffer = Float32List(1 * 112 * 112 * 3);
    int pixelIndex = 0;
    
    for (int y = 0; y < 112; y++) {
      for (int x = 0; x < 112; x++) {
        var pixel = image.getPixel(x, y);
        
        // Normalize: (PixelValue - 127.5) / 128.0
        // access r, g, b components
        buffer[pixelIndex++] = (pixel.r - 127.5) / 128.0;
        buffer[pixelIndex++] = (pixel.g - 127.5) / 128.0;
        buffer[pixelIndex++] = (pixel.b - 127.5) / 128.0;
      }
    }
    return buffer;
  }

  // 3. Close interpreter when not in use to free Sahyog app memory
  void dispose() {
    if (_isModelLoaded) {
      interpreter.close();
    }
  }
}