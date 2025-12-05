import 'dart:convert';
import 'package:flutter/material.dart';

// Widget displayDoctorImage(String? base64Image) {
//   if (base64Image != null && base64Image.isNotEmpty) {
//     return Image.memory(base64Decode(base64Image), width: 120);
//   } else {
//     return const Text("No image selected");
//   }
// }


Widget displayDoctorImage(String? base64Image) {
  if (base64Image != null && base64Image.isNotEmpty) {
    try {
      // Remove the "data:image/xxx;base64," prefix if present
      final cleanedBase64 = base64Image.contains(',')
          ? base64Image.split(',')[1]
          : base64Image;

      final bytes = base64Decode(cleanedBase64);

      return Image.memory(
        bytes,
        width: 120,
        fit: BoxFit.contain,
      );
    } catch (e) {
      return const Text(
        "Invalid image format",
        style: TextStyle(color: Colors.red),
      );
    }
  } else {
    return const Text("No image selected");
  }
}


