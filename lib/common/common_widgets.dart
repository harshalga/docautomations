import 'dart:convert';
import 'package:flutter/material.dart';

Widget displayDoctorImage(String? base64Image) {
  if (base64Image != null && base64Image.isNotEmpty) {
    return Image.memory(base64Decode(base64Image), width: 120);
  } else {
    return const Text("No image selected");
  }
}

