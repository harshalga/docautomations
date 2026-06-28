import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

// Widget displayDoctorImage(String? base64Image) {
//   if (base64Image != null && base64Image.isNotEmpty) {
//     return Image.memory(base64Decode(base64Image), width: 120);
//   } else {
//     return const Text("No image selected");
//   }
// }


// Widget displayDoctorImage(  Uint8List? imageBytes,String? base64Image) {
 
 
 
 
 
//   // if (base64Image != null && base64Image.isNotEmpty) {
//   //   try {
//   //     // Remove the "data:image/xxx;base64," prefix if present
//   //     final cleanedBase64 = base64Image.contains(',')
//   //         ? base64Image.split(',')[1]
//   //         : base64Image;

//   //     final bytes = base64Decode(cleanedBase64);

//   //     return Image.memory(
//   //       bytes,
//   //       width: 120,
//   //       fit: BoxFit.contain,
//   //     );
//   //   } catch (e) {
//   //     return const Text(
//   //       "Invalid image format",
//   //       style: TextStyle(color: Colors.red),
//   //     );
//   //   }
//   // } else {
//   //   return const Text("No image selected");
//   // }
// }

Widget displayDoctorImage({
  Uint8List? imageBytes,
  String? base64Image,
}) {
  try {
    Uint8List? bytes = imageBytes;

    if (bytes == null &&
        base64Image != null &&
        base64Image.isNotEmpty) {
      final cleaned = base64Image.contains(',')
          ? base64Image.split(',')[1]
          : base64Image;

      bytes = base64Decode(cleaned);
    }

    if (bytes == null || bytes.isEmpty) {
      return const Text("No image selected");
    }

    return Image.memory(
      bytes,
      width: 120,
      fit: BoxFit.contain,
    );
  } catch (_) {
    return const Text(
      "Invalid image",
      style: TextStyle(color: Colors.red),
    );
  }
}

