import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

class ImageAsset {
  final String imageData;
  final String mimeType;

  const ImageAsset({
    required this.imageData,
    required this.mimeType,
  });

  factory ImageAsset.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ImageAsset(
        imageData: "",
        mimeType: "image/png",
      );
    }

    final rawImageData = json["imageData"];
    String normalizedImageData = "";

    // Case 1: Backend sends Base64 as a String.
    if (rawImageData is String) {
      normalizedImageData = rawImageData;
    }

    // Case 2: Backend sends a Node.js Buffer JSON object.
    // Example: { "type": "Buffer", "data": [137, 80, 78, ...] }
    else if (rawImageData is Map &&
        rawImageData["data"] is List) {
      final bytes = (rawImageData["data"] as List)
          .map((value) => (value as num).toInt())
          .toList();

      normalizedImageData = base64Encode(bytes);
    }

    // Case 3: Image data is already a byte list.
    else if (rawImageData is List) {
      final bytes = rawImageData
          .map((value) => (value as num).toInt())
          .toList();

      normalizedImageData = base64Encode(bytes);
    }

    return ImageAsset(
      imageData: normalizedImageData,
      mimeType: json["mimeType"]?.toString() ?? "image/png",
    );
  }

  Map<String, dynamic> toJson() => {
        "imageData": imageData,
        "mimeType": mimeType,
      };

  bool get hasImage => imageData.isNotEmpty;

  Uint8List? get bytes {
    if (!hasImage) {
      debugPrint("IMAGE ASSET: imageData is empty");
      return null;
    }

    var data = imageData.trim();

    // Support data URI format:
    // data:image/png;base64,....
    final commaIndex = data.indexOf(",");

    if (data.startsWith("data:") && commaIndex != -1) {
      data = data.substring(commaIndex + 1);
    }

    try {
      final decoded = base64Decode(data);

      debugPrint("IMAGE BASE64 LENGTH: ${data.length}");
      debugPrint("IMAGE DECODED LENGTH: ${decoded.length}");

      if (decoded.length >= 8) {
        debugPrint(
          "IMAGE SIGNATURE: ${decoded.take(8).toList()}",
        );
      }

      return decoded;
    } catch (e) {
      debugPrint("IMAGE BASE64 DECODE ERROR: $e");
      return null;
    }
  }
}