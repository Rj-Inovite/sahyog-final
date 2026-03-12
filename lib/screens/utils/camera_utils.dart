import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

InputImage? getInputImage(CameraImage image, CameraDescription camera) {
  // 1. Handle Image Rotation
  // sensorOrientation is usually 90 or 270 on Android front cameras
  final sensorOrientation = camera.sensorOrientation;
  InputImageRotation? rotation;
  
  var rotations = {
    0: InputImageRotation.rotation0deg,
    90: InputImageRotation.rotation90deg,
    180: InputImageRotation.rotation180deg,
    270: InputImageRotation.rotation270deg,
  };
  rotation = rotations[sensorOrientation];
  if (rotation == null) return null;

  // 2. Handle Image Format
  final format = InputImageFormatValue.fromRawValue(image.format.raw);
  // ML Kit specifically requires YUV_420_888 or BGRA8888
  if (format == null || (format != InputImageFormat.yuv420 && format != InputImageFormat.bgra8888)) return null;

  // 3. Concatenate all planes (CRITICAL for YUV420)
  // We can't just take the first plane; we need the full YUV byte stream
  final WriteBuffer allBytes = WriteBuffer();
  for (final Plane plane in image.planes) {
    allBytes.putUint8List(plane.bytes);
  }
  final bytes = allBytes.done().buffer.asUint8List();

  // 4. Return the constructed InputImage
  return InputImage.fromBytes(
    bytes: bytes,
    metadata: InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation, // This tells ML Kit which way is "Up"
      format: format,
      bytesPerRow: image.planes[0].bytesPerRow,
    ),
  );
}