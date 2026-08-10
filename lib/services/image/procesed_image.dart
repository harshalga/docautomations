import 'dart:typed_data';

class ProcessedImage {
  //---------------------------------------------------------------------------
  // Image Bytes
  //---------------------------------------------------------------------------

  final Uint8List bytes;

  //---------------------------------------------------------------------------
  // Metadata
  //---------------------------------------------------------------------------

  final String mimeType;

  final int width;

  final int height;

  final int originalSizeInBytes;

  final int compressedSizeInBytes;

  //---------------------------------------------------------------------------
  // Constructor
  //---------------------------------------------------------------------------

  const ProcessedImage({
    required this.bytes,
    required this.mimeType,
    required this.width,
    required this.height,
    required this.originalSizeInBytes,
    required this.compressedSizeInBytes,
  });

  //---------------------------------------------------------------------------
  // Base64
  //---------------------------------------------------------------------------

  String get base64 =>
      bytes.isEmpty
          ? ""
          : UriData.fromBytes(
              bytes,
              mimeType: mimeType,
            ).contentAsString();

  //---------------------------------------------------------------------------
  // Compression %
  //---------------------------------------------------------------------------

  double get compressionRatio {

    if (originalSizeInBytes == 0) {
      return 0;
    }

    return ((originalSizeInBytes -
                    compressedSizeInBytes) *
                100) /
            originalSizeInBytes;
  }

  //---------------------------------------------------------------------------
  // Human Readable
  //---------------------------------------------------------------------------

  double get originalSizeKB =>
      originalSizeInBytes / 1024;

  double get compressedSizeKB =>
      compressedSizeInBytes / 1024;
}