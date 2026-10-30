
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
    String doctorId,
    AssetType assetType,
  ) {
    return _platform.assetExists(
      doctorId,
      assetType,
    );
  }

  //-------------------------------------------------------------------------
  // Save Asset
  //-------------------------------------------------------------------------

  Future<void> saveAsset(
    String doctorId,
    AssetType assetType,
    List<int> bytes,
  ) {
    return _platform.saveAsset(
      doctorId,
      assetType,
      bytes,
    );
  }

  //-------------------------------------------------------------------------
  // Load Asset
  //-------------------------------------------------------------------------

  Future<List<int>?> loadAsset(
    String doctorId,
    AssetType assetType,
  ) {
    return _platform.loadAsset(
      doctorId,
      assetType,
    );
  }

  //-------------------------------------------------------------------------
  // Delete Asset
  //-------------------------------------------------------------------------

  Future<void> deleteAsset(
    String doctorId,
    AssetType assetType,
  ) {
    return _platform.deleteAsset(
      doctorId,
      assetType,
    );
  }

  //-------------------------------------------------------------------------
  // Manifest
  //-------------------------------------------------------------------------

  Future<AssetManifest> loadManifest(
    String doctorId,
  ) {
    return _platform.loadManifest(
      doctorId,
    );
  }

  Future<void> saveManifest(
    String doctorId,
    AssetManifest manifest,
  ) {
    return _platform.saveManifest(
      doctorId,
      manifest,
    );
  }

  //-------------------------------------------------------------------------
  // Synchronization Required
  //-------------------------------------------------------------------------

  Future<bool> needsSynchronization(
    String doctorId,
    AssetType assetType,
    int serverVersion,
  ) {
    return _platform.needsSynchronization(
      doctorId,
      assetType,
      serverVersion,
    );
  }

  //-------------------------------------------------------------------------
  // Update Asset
  //-------------------------------------------------------------------------

  Future<void> updateAsset({
    required String doctorId,
    required AssetType assetType,
    required List<int> bytes,
    required int serverVersion,
  }) {
    return _platform.updateAsset(
      doctorId: doctorId,
      assetType: assetType,
      bytes: bytes,
      serverVersion: serverVersion,
    );
  }

  //-------------------------------------------------------------------------
  // Clear All Assets
  //-------------------------------------------------------------------------

  Future<void> clearAssets(
    String doctorId,
  ) {
    return _platform.clearAssets(
      doctorId,
    );
  }
}
