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
}