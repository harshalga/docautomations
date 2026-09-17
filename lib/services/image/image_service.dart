import 'dart:typed_data';

import 'package:docautomations/services/image/procesed_image.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';


class ImageService {
  //---------------------------------------------------------------------------
  // Constants
  //---------------------------------------------------------------------------

  static const int maxUploadSize = 2 * 1024 * 1024;

  static const int compressThreshold = 500 * 1024;

  static const int resizeWidth = 500;

  static const int resizeHeight = 500;

  //---------------------------------------------------------------------------
  // Image Picker
  //---------------------------------------------------------------------------

  final ImagePicker _picker = ImagePicker();

  //---------------------------------------------------------------------------
  // Pick Doctor Logo
  //---------------------------------------------------------------------------

  Future<ProcessedImage?> pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (picked == null) {
      return null;
    }

    return _processImage(
      picked,
    );
  }

  //---------------------------------------------------------------------------
  // Process Image
  //---------------------------------------------------------------------------

  Future<ProcessedImage> _processImage(
  XFile file,
) async {
  //---------------------------------------------------------------------------
  // Validate Extension
  //---------------------------------------------------------------------------

  final extension =
      file.name.split('.').last.toLowerCase();

  if (!_isSupported(extension)) {
    throw Exception(
      "Only PNG, JPG, JPEG and WEBP images are supported.",
    );
  }

  //---------------------------------------------------------------------------
  // Read Original Bytes
  //---------------------------------------------------------------------------

  final bytes = await file.readAsBytes();

  final originalSize = bytes.length;

  if (originalSize > maxUploadSize) {
    throw Exception(
      "Maximum allowed image size is 2 MB.",
    );
  }

  //---------------------------------------------------------------------------
  // Decode Image
  //---------------------------------------------------------------------------

  final image = img.decodeImage(bytes);

  if (image == null) {
    throw Exception(
      "Unable to decode image.",
    );
  }

  //---------------------------------------------------------------------------
  // Resize
  //---------------------------------------------------------------------------

  final resized = img.copyResize(
    image,
    width: resizeWidth,
    height: resizeHeight,
    interpolation: img.Interpolation.average,
  );

  //---------------------------------------------------------------------------
  // Compress
  //---------------------------------------------------------------------------

  final compressed = Uint8List.fromList(
    _compressImage(resized),
  );

  //---------------------------------------------------------------------------
  // Return Processed Image
  //---------------------------------------------------------------------------

  return ProcessedImage(
    bytes: compressed,
    mimeType: _mimeType(extension),
    width: image.width,
    height: image.height,
    originalSizeInBytes: originalSize,
    compressedSizeInBytes: compressed.length,
  );
}

  //---------------------------------------------------------------------------
  // Compress
  //---------------------------------------------------------------------------

  List<int> _compressImage(
    img.Image image,
  ) {
    List<int> bytes =
        img.encodeJpg(
      image,
      quality: 90,
    );

    if (bytes.length <=
        compressThreshold) {
      return bytes;
    }

    for (int quality = 85;
        quality >= 40;
        quality -= 5) {
      bytes = img.encodeJpg(
        image,
        quality: quality,
      );

      if (bytes.length <=
          compressThreshold) {
        break;
      }
    }

    return bytes;
  }

  //---------------------------------------------------------------------------
  // Supported Extension
  //---------------------------------------------------------------------------

  bool _isSupported(
    String extension,
  ) {
    return const [
      "png",
      "jpg",
      "jpeg",
      "webp",
    ].contains(extension);
  }

  //---------------------------------------------------------------------------
  // Mime Type
  //---------------------------------------------------------------------------

  String _mimeType(
    String extension,
  ) {
    switch (extension) {
      case "png":
        return "image/png";

      case "webp":
        return "image/webp";

      default:
        return "image/jpeg";
    }
  }
}