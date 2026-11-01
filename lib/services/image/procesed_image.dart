// import 'dart:typed_data';

// class ProcessedImage {

//   //===========================================================================
//   // Image Bytes
//   //===========================================================================

//   final Uint8List bytes;


//   //===========================================================================
//   // Image Metadata
//   //===========================================================================

//   final String mimeType;

//   final int width;

//   final int height;

//   final int originalSizeInBytes;

//   final int compressedSizeInBytes;


//   //===========================================================================
//   // Constructor
//   //===========================================================================

//   const ProcessedImage({

//     required this.bytes,

//     required this.mimeType,

//     required this.width,

//     required this.height,

//     required this.originalSizeInBytes,

//     required this.compressedSizeInBytes,

//   });


//   //===========================================================================
//   // Base64 Image Data
//   //===========================================================================

//   String get base64 =>

//       bytes.isEmpty

//           ? ""

//           : UriData.fromBytes(
//               bytes,
//               mimeType: mimeType,
//             ).contentAsString();


//   //===========================================================================
//   // API Image Data
//   //===========================================================================
//   //
//   // Backend AssetService expects:
//   //
//   //     imageData
//   //     mimeType
//   //
//   // imageData contains Base64 encoded image bytes.
//   //
//   //===========================================================================

//   String get imageData => base64;


//   //===========================================================================
//   // JSON Serialization
//   //===========================================================================

//   Map<String, dynamic> toJson() {

//     return {

//       "imageData":
//           imageData,

//       "mimeType":
//           mimeType,

//     };

//   }


//   //===========================================================================
//   // Compression Ratio
//   //===========================================================================

//   double get compressionRatio {

//     if (originalSizeInBytes == 0) {

//       return 0;

//     }

//     return (

//           (originalSizeInBytes -
//               compressedSizeInBytes) *

//           100

//         ) /

//         originalSizeInBytes;

//   }


//   //===========================================================================
//   // Human Readable Size
//   //===========================================================================

//   double get originalSizeKB =>

//       originalSizeInBytes / 1024;


//   double get compressedSizeKB =>

//       compressedSizeInBytes / 1024;

// }


import 'dart:convert';
import 'dart:typed_data';

class ProcessedImage {
  final Uint8List bytes;
  final String mimeType;
  final int width;
  final int height;
  final int originalSizeInBytes;
  final int compressedSizeInBytes;

  const ProcessedImage({
    required this.bytes,
    required this.mimeType,
    required this.width,
    required this.height,
    required this.originalSizeInBytes,
    required this.compressedSizeInBytes,
  });

  // Convert binary image bytes into Base64.
  String get base64 =>
      bytes.isEmpty ? "" : base64Encode(bytes);

  String get imageData => base64;

  Map<String, dynamic> toJson() => {
    "imageData": imageData,
    "mimeType": mimeType,
  };

  double get compressionRatio {
    if (originalSizeInBytes == 0) return 0;

    return ((originalSizeInBytes - compressedSizeInBytes) * 100) /
        originalSizeInBytes;
  }

  double get originalSizeKB => originalSizeInBytes / 1024;

  double get compressedSizeKB => compressedSizeInBytes / 1024;
}
