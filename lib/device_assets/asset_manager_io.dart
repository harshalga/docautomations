
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'asset_manifest.dart';
import 'asset_type.dart';

class AssetManagerPlatform {

  static const String _assetFolder = "doctor_assets";
  static const String _manifestFile = "asset_manifest.json";

  //-------------------------------------------------------------------------
  // Validate Doctor ID
  //-------------------------------------------------------------------------

  String _validateDoctorId(String doctorId) {
    final id = doctorId.trim();

    if (id.isEmpty) {
      throw ArgumentError(
        "Doctor ID cannot be empty.",
      );
    }

    return id;
  }

  //-------------------------------------------------------------------------
  // Doctor Asset Directory
  //-------------------------------------------------------------------------

  Future<Directory> getAssetDirectory(
    String doctorId,
  ) async {

    final validDoctorId =
        _validateDoctorId(doctorId);

    final documents =
        await getApplicationDocumentsDirectory();

    final directory = Directory(
      p.join(
        documents.path,
        _assetFolder,
        validDoctorId,
      ),
    );

    if (!await directory.exists()) {
      await directory.create(
        recursive: true,
      );
    }

    return directory;
  }

  //-------------------------------------------------------------------------
  // Asset File
  //-------------------------------------------------------------------------

  Future<File> getAssetFile(
    String doctorId,
    AssetType assetType,
  ) async {

    final directory =
        await getAssetDirectory(doctorId);

    return File(
      p.join(
        directory.path,
        assetType.fileName,
      ),
    );
  }

  //-------------------------------------------------------------------------
  // Manifest File
  //-------------------------------------------------------------------------

  Future<File> _getManifestFile(
    String doctorId,
  ) async {

    final directory =
        await getAssetDirectory(doctorId);

    return File(
      p.join(
        directory.path,
        _manifestFile,
      ),
    );
  }

  //-------------------------------------------------------------------------
  // Asset Exists
  //-------------------------------------------------------------------------

  Future<bool> assetExists(
    String doctorId,
    AssetType assetType,
  ) async {

    final file =
        await getAssetFile(
      doctorId,
      assetType,
    );

    return file.exists();
  }

  //-------------------------------------------------------------------------
  // Save Asset
  //-------------------------------------------------------------------------

  Future<void> saveAsset(
    String doctorId,
    AssetType assetType,
    List<int> bytes,
  ) async {

    final file =
        await getAssetFile(
      doctorId,
      assetType,
    );

    await file.writeAsBytes(
      bytes,
      flush: true,
    );
  }

  //-------------------------------------------------------------------------
  // Load Asset
  //-------------------------------------------------------------------------

  Future<List<int>?> loadAsset(
    String doctorId,
    AssetType assetType,
  ) async {

    final file =
        await getAssetFile(
      doctorId,
      assetType,
    );

    if (!await file.exists()) {
      return null;
    }

    return file.readAsBytes();
  }

  //-------------------------------------------------------------------------
  // Delete Asset
  //-------------------------------------------------------------------------

  Future<void> deleteAsset(
    String doctorId,
    AssetType assetType,
  ) async {

    final file =
        await getAssetFile(
      doctorId,
      assetType,
    );

    if (await file.exists()) {
      await file.delete();
    }

    var manifest =
        await loadManifest(doctorId);

    manifest =
        manifest.remove(assetType);

    await saveManifest(
      doctorId,
      manifest,
    );
  }

  //-------------------------------------------------------------------------
  // Load Manifest
  //-------------------------------------------------------------------------

  Future<AssetManifest> loadManifest(
    String doctorId,
  ) async {

    final file =
        await _getManifestFile(doctorId);

    if (!await file.exists()) {
      return const AssetManifest();
    }

    final json =
        jsonDecode(
          await file.readAsString(),
        );

    return AssetManifest.fromJson(
      Map<String, dynamic>.from(json),
    );
  }

  //-------------------------------------------------------------------------
  // Save Manifest
  //-------------------------------------------------------------------------

  Future<void> saveManifest(
    String doctorId,
    AssetManifest manifest,
  ) async {

    final file =
        await _getManifestFile(doctorId);

    await file.writeAsString(
      jsonEncode(
        manifest.toJson(),
      ),
      flush: true,
    );
  }

  //-------------------------------------------------------------------------
  // Synchronization
  //-------------------------------------------------------------------------

  Future<bool> needsSynchronization(
    String doctorId,
    AssetType assetType,
    int serverVersion,
  ) async {

    if (!await assetExists(
      doctorId,
      assetType,
    )) {
      return true;
    }

    final manifest =
        await loadManifest(doctorId);

    if (!manifest.contains(assetType)) {
      return true;
    }

    final localVersion =
        manifest.getVersion(assetType);

    return serverVersion != localVersion;
  }

  //-------------------------------------------------------------------------
  // Update Asset
  //-------------------------------------------------------------------------

  Future<void> updateAsset({
    required String doctorId,
    required AssetType assetType,
    required List<int> bytes,
    required int serverVersion,
  }) async {

    await saveAsset(
      doctorId,
      assetType,
      bytes,
    );

    var manifest =
        await loadManifest(doctorId);

    manifest =
        manifest.setVersion(
      assetType,
      serverVersion,
    );

    await saveManifest(
      doctorId,
      manifest,
    );
  }

  //-------------------------------------------------------------------------
  // Clear Assets for One Doctor
  //-------------------------------------------------------------------------

  Future<void> clearAssets(
    String doctorId,
  ) async {

    final directory =
        await getAssetDirectory(doctorId);

    if (await directory.exists()) {
      await directory.delete(
        recursive: true,
      );
    }
  }
}
