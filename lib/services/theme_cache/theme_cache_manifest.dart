class ThemeCacheManifest {
  final Map<String, String> themeVersions;

  const ThemeCacheManifest({
    this.themeVersions = const {},
  });

  bool contains(String themeId) {
    return themeVersions.containsKey(themeId);
  }

  String? getUpdatedAt(String themeId) {
    return themeVersions[themeId];
  }

  ThemeCacheManifest setVersion(
    String themeId,
    String updatedAt,
  ) {
    return ThemeCacheManifest(
      themeVersions: {
        ...themeVersions,
        themeId: updatedAt,
      },
    );
  }

  ThemeCacheManifest remove(String themeId) {
    final updated = Map<String, String>.from(themeVersions);
    updated.remove(themeId);

    return ThemeCacheManifest(
      themeVersions: updated,
    );
  }

  ThemeCacheManifest copyWith({
  Map<String, String>? themeVersions,
}) {
  return ThemeCacheManifest(
    themeVersions: themeVersions ?? this.themeVersions,
  );
}

  factory ThemeCacheManifest.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawVersions = json["themeVersions"];

    final versions = <String, String>{};

    if (rawVersions is Map) {
      for (final entry in rawVersions.entries) {
        if (entry.key != null && entry.value != null) {
          versions[entry.key.toString()] =
              entry.value.toString();
        }
      }
    }

    return ThemeCacheManifest(
      themeVersions: versions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "themeVersions": themeVersions,
    };
  }
}