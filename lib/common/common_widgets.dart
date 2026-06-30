import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';



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

