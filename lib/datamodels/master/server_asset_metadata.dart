class ServerAssetMetadata {
  final bool exists;
  final int version;
  final String? mimeType;

  const ServerAssetMetadata({
    this.exists = false,
    this.version = 0,
    this.mimeType,
  });

  factory ServerAssetMetadata.fromJson(dynamic json) {
    if (json is! Map) {
      return const ServerAssetMetadata();
    }

    return ServerAssetMetadata(
      exists: json["exists"] == true,
      version: (json["version"] as num?)?.toInt() ?? 0,
      mimeType: json["mimeType"] as String?,
    );
  }
}