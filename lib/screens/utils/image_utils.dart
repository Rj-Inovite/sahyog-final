import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

class ImageUtils {
  /// Converts YUV420 CameraImage to an Image object efficiently
  static img.Image convertYUV420ToImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;

    // Create image container using the 'image' package
    final image = img.Image(width: width, height: height);

    final yPlane = cameraImage.planes[0];
    final uPlane = cameraImage.planes[1];
    final vPlane = cameraImage.planes[2];

    final yBuffer = yPlane.bytes;
    final uBuffer = uPlane.bytes;
    final vBuffer = vPlane.bytes;

    final int yRowStride = yPlane.bytesPerRow;
    final int uvRowStride = uPlane.bytesPerRow;
    final int uvPixelStride = uPlane.bytesPerPixel!;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int yIndex = y * yRowStride + x;
        final int uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

        final int yp = yBuffer[yIndex];
        final int up = uBuffer[uvIndex];
        final int vp = vBuffer[uvIndex];

        // Optimized YUV to RGB conversion
        int r = (yp + 1.402 * (vp - 128)).round().clamp(0, 255);
        int g = (yp - 0.344136 * (up - 128) - 0.714136 * (vp - 128)).round().clamp(0, 255);
        int b = (yp + 1.772 * (up - 128)).round().clamp(0, 255);

        image.setPixelRgb(x, y, r, g, b);
      }
    }

    // IMPORTANT: Front camera images are usually rotated 270 degrees on Android
    // We rotate it here so the 'cropFace' function works on a "standing up" face
    return img.copyRotate(image, angle: 270);
  }

  /// Crops the face out of the full image based on ML Kit's BoundingBox
  static img.Image cropFace(img.Image fullImage, dynamic boundingBox) {
    // 1. Convert bounding box to integers
    int left = boundingBox.left.toInt();
    int top = boundingBox.top.toInt();
    int width = boundingBox.width.toInt();
    int height = boundingBox.height.toInt();

    // 2. Ensure we don't crop outside the image boundaries
    left = left.clamp(0, fullImage.width);
    top = top.clamp(0, fullImage.height);
    width = width.clamp(0, fullImage.width - left);
    height = height.clamp(0, fullImage.height - top);

    // 3. Perform the crop
    img.Image faceCrop = img.copyCrop(
      fullImage,
      x: left,
      y: top,
      width: width,
      height: height,
    );

    // 4. Resize to 112x112 (Standard size for most TFLite face models like MobileFaceNet)
    return img.copyResize(faceCrop, width: 112, height: 112);
  }
}