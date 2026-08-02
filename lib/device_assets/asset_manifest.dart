import 'asset_type.dart';

class AssetManifest {
  final Map<String, int> versions;

  const AssetManifest({
    this.versions = const {},
  });

  factory AssetManifest.fromJson(
    Map<String, dynamic> json,
  ) {
    return AssetManifest(
      versions: Map<String, int>.from(
        json["versions"] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "versions": versions,
    };
  }

  //---------------------------------------------------------
  // Returns version of the asset.
  // Returns 0 if not present.
  //---------------------------------------------------------

  int getVersion(
    AssetType assetType,
  ) {
    return versions[assetType.name] ?? 0;
  }

  //---------------------------------------------------------
  // Adds or Updates an asset version
  //---------------------------------------------------------

  AssetManifest setVersion(
    AssetType assetType,
    int version,
  ) {
    final updated =
        Map<String, int>.from(versions);

    updated[assetType.name] = version;

    return AssetManifest(
      versions: updated,
    );
  }

  //---------------------------------------------------------
  // Checks whether the asset exists
  //---------------------------------------------------------

  bool contains(
    AssetType assetType,
  ) {
    return versions.containsKey(
      assetType.name,
    );
  }

  //---------------------------------------------------------
  // Removes an asset entry
  //---------------------------------------------------------

  AssetManifest remove(
    AssetType assetType,
  ) {
    final updated =
        Map<String, int>.from(versions);

    updated.remove(
      assetType.name,
    );

    return AssetManifest(
      versions: updated,
    );
  }
}