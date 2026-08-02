class ImageAsset {
  final String base64Image;
  final String mimeType;

  const ImageAsset({
    required this.base64Image,
    required this.mimeType,
  });

  factory ImageAsset.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ImageAsset(
        base64Image: "",
        mimeType: "image/png",
      );
    }

    return ImageAsset(
      base64Image: json["imageData"] ?? "",
      mimeType: json["mimeType"] ?? "image/png",
    );
  }

  Map<String, dynamic> toJson() => {
        "imageData": base64Image,
        "mimeType": mimeType,
      };

  bool get hasImage => base64Image.isNotEmpty;
}