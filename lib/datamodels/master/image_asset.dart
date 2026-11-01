// import 'dart:convert';
// import 'dart:typed_data';

// class ImageAsset {
//   final String imageData;
//   final String mimeType;

//   const ImageAsset({
//     required this.imageData,
//     required this.mimeType,
//   });

//   factory ImageAsset.fromJson(Map<String, dynamic>? json) {
//     if (json == null) {
//       return const ImageAsset(
//         imageData: "",
//         mimeType: "image/png",
//       );
//     }

//     return ImageAsset(
//       imageData: json["imageData"] ?? "",
//       mimeType: json["mimeType"] ?? "image/png",
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         "imageData": imageData,
//         "mimeType": mimeType,
//       };

//   bool get hasImage => imageData.isNotEmpty;

//   Uint8List? _decodeImageAsset(
//   ImageAsset? asset,
// ) {

//   if (asset == null || !asset.hasImage) {
//     return null;
//   }

//   var data =
//       asset.imageData.trim();

//   final commaIndex =
//       data.indexOf(",");

//   if (data.startsWith("data:") &&
//       commaIndex != -1) {

//     data =
//         data.substring(
//       commaIndex + 1,
//     );
//   }

//   try {

//     return base64Decode(data);

//   } catch (_) {

//     return null;

//   }
// }
// }


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

    return ImageAsset(
      imageData: json["imageData"]?.toString() ?? "",
      mimeType: json["mimeType"]?.toString() ?? "image/png",
    );
  }

  Map<String, dynamic> toJson() => {
        "imageData": imageData,
        "mimeType": mimeType,
      };

  bool get hasImage => imageData.isNotEmpty;

  // Uint8List? get bytes {
  //   if (!hasImage) return null;

  //   var data = imageData.trim();

  //   final commaIndex = data.indexOf(",");

  //   if (data.startsWith("data:") && commaIndex != -1) {
  //     data = data.substring(commaIndex + 1);
  //   }

  //   try {
  //     return base64Decode(data);
  //   } catch (_) {
  //     return null;
  //   }
  // }

  Uint8List? get bytes {

  if (!hasImage) {
    debugPrint("IMAGE ASSET: imageData is empty");
    return null;
  }

  var data = imageData.trim();

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