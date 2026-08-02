import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'asset_manifest.dart';
import 'asset_type.dart';

class AssetManager {
  static const String _assetFolder = "assets";
  static const String _manifestFile = "asset_manifest.json";

  //---------------------------------------------------------
  // Asset Folder
  //---------------------------------------------------------

  Future<Directory> getAssetDirectory() async {
    final documents = await getApplicationDocumentsDirectory();

    final directory = Directory(
      p.join(
        documents.path,
        _assetFolder,
      ),
    );

    if (!await directory.exists()) {
      await directory.create(
        recursive: true,
      );
    }

    return directory;
  }

  //---------------------------------------------------------
  // Asset File
  //---------------------------------------------------------

  Future<File> getAssetFile(
    AssetType assetType,
  ) async {
    final directory = await getAssetDirectory();

    return File(
      p.join(
        directory.path,
        assetType.fileName,
      ),
    );
  }

  //---------------------------------------------------------
  // Manifest File
  //---------------------------------------------------------

  Future<File> _getManifestFile() async {
    final directory = await getAssetDirectory();

    return File(
      p.join(
        directory.path,
        _manifestFile,
      ),
    );
  }

  //---------------------------------------------------------
  // Asset Exists
  //---------------------------------------------------------

  Future<bool> assetExists(
    AssetType assetType,
  ) async {
    final file = await getAssetFile(assetType);

    return file.exists();
  }

  //---------------------------------------------------------
  // Save Asset
  //---------------------------------------------------------

  Future<void> saveAsset(
    AssetType assetType,
    List<int> bytes,
  ) async {
    final file = await getAssetFile(assetType);

    await file.writeAsBytes(
      bytes,
      flush: true,
    );
  }

  //---------------------------------------------------------
  // Load Asset
  //---------------------------------------------------------

  Future<List<int>?> loadAsset(
    AssetType assetType,
  ) async {
    final file = await getAssetFile(assetType);

    if (!await file.exists()) {
      return null;
    }

    return file.readAsBytes();
  }

  //---------------------------------------------------------
  // Delete Asset
  //---------------------------------------------------------

  Future<void> deleteAsset(
    AssetType assetType,
  ) async {
    final file = await getAssetFile(assetType);

    if (await file.exists()) {
      await file.delete();
    }

    var manifest = await loadManifest();

    manifest = manifest.remove(assetType);

    await saveManifest(manifest);
  }

  //---------------------------------------------------------
  // Manifest
  //---------------------------------------------------------

  Future<AssetManifest> loadManifest() async {
    final file = await _getManifestFile();

    if (!await file.exists()) {
      return const AssetManifest();
    }

    final json =
        jsonDecode(await file.readAsString());

    return AssetManifest.fromJson(json);
  }

  Future<void> saveManifest(
    AssetManifest manifest,
  ) async {
    final file = await _getManifestFile();

    await file.writeAsString(
      jsonEncode(
        manifest.toJson(),
      ),
      flush: true,
    );
  }

  //---------------------------------------------------------
  // Synchronization Required?
  //---------------------------------------------------------

  Future<bool> needsSynchronization(
    AssetType assetType,
    int serverVersion,
  ) async {
    // Asset missing
    if (!await assetExists(assetType)) {
      return true;
    }

    final manifest = await loadManifest();

    // Manifest doesn't contain this asset
    if (!manifest.contains(assetType)) {
      return true;
    }

    final localVersion =
        manifest.getVersion(assetType);

    return serverVersion > localVersion;
  }

  //---------------------------------------------------------
  // Update Asset
  //---------------------------------------------------------

  Future<void> updateAsset({
    required AssetType assetType,
    required List<int> bytes,
    required int serverVersion,
  }) async {
    await saveAsset(
      assetType,
      bytes,
    );

    var manifest = await loadManifest();

    manifest = manifest.setVersion(
      assetType,
      serverVersion,
    );

    await saveManifest(manifest);
  }

  // //---------------------------------------------------------
  // // Synchronize Asset
  // //---------------------------------------------------------

  // Future<void> synchronizeAsset({
  //   required AssetType assetType,
  //   required int serverVersion,
  //   required Future<List<int>> Function()
  //       downloadAsset,
  // }) async {
  //   final requiredSync =
  //       await needsSynchronization(
  //     assetType,
  //     serverVersion,
  //   );

  //   if (!requiredSync) {
  //     return;
  //   }

  //   final bytes =
  //       await downloadAsset();

  //   await updateAsset(
  //     assetType: assetType,
  //     bytes: bytes,
  //     serverVersion: serverVersion,
  //   );
  // }

  //---------------------------------------------------------
  // Clear All Assets
  //---------------------------------------------------------

  Future<void> clearAssets() async {
    final directory = await getAssetDirectory();

    if (await directory.exists()) {
      await directory.delete(
        recursive: true,
      );
    }
  }
  ///---------------------------------------------------------
/// Returns the asset File.
/// Returns null if the asset does not exist.
///---------------------------------------------------------

Future<File?> getAsset(
  AssetType assetType,
) async {
  final file = await getAssetFile(assetType);

  if (!await file.exists()) {
    return null;
  }

  return file;
}

///---------------------------------------------------------
/// Returns the asset path.
/// Returns null if the asset does not exist.
///---------------------------------------------------------

Future<String?> getAssetPath(
  AssetType assetType,
) async {
  final file = await getAsset(assetType);

  return file?.path;
}

Future<Map<AssetType, File>> getAvailableAssets() async {
  final Map<AssetType, File> assets = {};

  for (final type in AssetType.values) {
    final file = await getAsset(type);

    if (file != null) {
      assets[type] = file;
    }
  }

  return assets;
}

}