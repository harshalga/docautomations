
import 'asset_manager_io.dart'
    if (dart.library.js_interop) 'asset_manager_web.dart';

import 'asset_type.dart';
import 'asset_manifest.dart';

class AssetManager {

  final AssetManagerPlatform _platform =
      AssetManagerPlatform();

  //-------------------------------------------------------------------------
  // Asset Exists
  //-------------------------------------------------------------------------

  Future<bool> assetExists(
    AssetType assetType,
  ) {
    return _platform.assetExists(
      assetType,
    );
  }

  //-------------------------------------------------------------------------
  // Save Asset
  //-------------------------------------------------------------------------

  Future<void> saveAsset(
    AssetType assetType,
    List<int> bytes,
  ) {
    return _platform.saveAsset(
      assetType,
      bytes,
    );
  }

  //-------------------------------------------------------------------------
  // Load Asset
  //-------------------------------------------------------------------------

  Future<List<int>?> loadAsset(
    AssetType assetType,
  ) {
    return _platform.loadAsset(
      assetType,
    );
  }

  //-------------------------------------------------------------------------
  // Delete Asset
  //-------------------------------------------------------------------------

  Future<void> deleteAsset(
    AssetType assetType,
  ) {
    return _platform.deleteAsset(
      assetType,
    );
  }

  //-------------------------------------------------------------------------
  // Manifest
  //-------------------------------------------------------------------------

  Future<AssetManifest> loadManifest() {
    return _platform.loadManifest();
  }

  Future<void> saveManifest(
    AssetManifest manifest,
  ) {
    return _platform.saveManifest(
      manifest,
    );
  }

  //-------------------------------------------------------------------------
  // Synchronization Required
  //-------------------------------------------------------------------------

  Future<bool> needsSynchronization(
    AssetType assetType,
    int serverVersion,
  ) {
    return _platform.needsSynchronization(
      assetType,
      serverVersion,
    );
  }

  //-------------------------------------------------------------------------
  // Update Asset
  //-------------------------------------------------------------------------

  Future<void> updateAsset({
    required AssetType assetType,
    required List<int> bytes,
    required int serverVersion,
  }) {
    return _platform.updateAsset(
      assetType: assetType,
      bytes: bytes,
      serverVersion: serverVersion,
    );
  }

  //-------------------------------------------------------------------------
  // Clear All Assets
  //-------------------------------------------------------------------------

  Future<void> clearAssets() {
    return _platform.clearAssets();
  }
}