import 'dart:convert';
import 'dart:typed_data';

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
      imageData: json["imageData"] ?? "",
      mimeType: json["mimeType"] ?? "image/png",
    );
  }

  Map<String, dynamic> toJson() => {
        "imageData": imageData,
        "mimeType": mimeType,
      };

  bool get hasImage => imageData.isNotEmpty;

  Uint8List? _decodeImageAsset(
  ImageAsset? asset,
) {

  if (asset == null || !asset.hasImage) {
    return null;
  }

  var data =
      asset.imageData.trim();

  final commaIndex =
      data.indexOf(",");

  if (data.startsWith("data:") &&
      commaIndex != -1) {

    data =
        data.substring(
      commaIndex + 1,
    );
  }

  try {

    return base64Decode(data);

  } catch (_) {

    return null;

  }
}
}