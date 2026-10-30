
import 'dart:convert';
import 'dart:typed_data';

import 'package:idb_shim/idb_browser.dart';

import 'asset_manifest.dart';
import 'asset_type.dart';

class AssetManagerPlatform {

  static const String _databaseName =
      "prescriptor_assets";

  static const String _storeName =
      "assets";

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
  // Doctor-Specific Keys
  //-------------------------------------------------------------------------

  String _assetKey(
    String doctorId,
    AssetType assetType,
  ) {
    final id = _validateDoctorId(doctorId);

    return "${id}_${assetType.fileName}";
  }

  String _manifestKey(
    String doctorId,
  ) {
    final id = _validateDoctorId(doctorId);

    return "${id}_manifest";
  }

  //-------------------------------------------------------------------------
  // Database
  //-------------------------------------------------------------------------

  Future<Database> _openDatabase() async {

    final factory =
        getIdbFactory();

    if (factory == null) {
      throw Exception(
        "IndexedDB is not available in this browser.",
      );
    }

    return factory.open(
      _databaseName,
      version: 1,
      onUpgradeNeeded: (
        VersionChangeEvent event,
      ) {

        final db =
            event.database;

        if (!db.objectStoreNames
            .contains(_storeName)) {

          db.createObjectStore(
            _storeName,
          );
        }
      },
    );
  }

  //-------------------------------------------------------------------------
  // Asset Exists
  //-------------------------------------------------------------------------

  Future<bool> assetExists(
    String doctorId,
    AssetType assetType,
  ) async {

    final db =
        await _openDatabase();

    try {

      final transaction =
          db.transaction(
        _storeName,
        idbModeReadOnly,
      );

      final store =
          transaction.objectStore(
            _storeName,
          );

      final value =
          await store.getObject(
        _assetKey(
          doctorId,
          assetType,
        ),
      );

      return value != null;

    } finally {

      db.close();

    }
  }

  //-------------------------------------------------------------------------
  // Save Asset
  //-------------------------------------------------------------------------

  Future<void> saveAsset(
    String doctorId,
    AssetType assetType,
    List<int> bytes,
  ) async {

    final db =
        await _openDatabase();

    try {

      final transaction =
          db.transaction(
        _storeName,
        idbModeReadWrite,
      );

      final store =
          transaction.objectStore(
            _storeName,
          );

      await store.put(
        Uint8List.fromList(bytes),
        _assetKey(
          doctorId,
          assetType,
        ),
      );

      await transaction.completed;

    } finally {

      db.close();

    }
  }

  //-------------------------------------------------------------------------
  // Load Asset
  //-------------------------------------------------------------------------

  Future<List<int>?> loadAsset(
    String doctorId,
    AssetType assetType,
  ) async {

    final db =
        await _openDatabase();

    try {

      final transaction =
          db.transaction(
        _storeName,
        idbModeReadOnly,
      );

      final store =
          transaction.objectStore(
            _storeName,
          );

      final value =
          await store.getObject(
        _assetKey(
          doctorId,
          assetType,
        ),
      );

      if (value == null) {
        return null;
      }

      if (value is Uint8List) {
        return value;
      }

      if (value is List<int>) {
        return value;
      }

      return null;

    } finally {

      db.close();

    }
  }

  //-------------------------------------------------------------------------
  // Delete Asset
  //-------------------------------------------------------------------------

  Future<void> deleteAsset(
    String doctorId,
    AssetType assetType,
  ) async {

    final db =
        await _openDatabase();

    try {

      final transaction =
          db.transaction(
        _storeName,
        idbModeReadWrite,
      );

      final store =
          transaction.objectStore(
            _storeName,
          );

      await store.delete(
        _assetKey(
          doctorId,
          assetType,
        ),
      );

      await transaction.completed;

    } finally {

      db.close();

    }

    var manifest =
        await loadManifest(doctorId);

    manifest =
        manifest.remove(
          assetType,
        );

    await saveManifest(
      doctorId,
      manifest,
    );
  }

  //-------------------------------------------------------------------------
  // Manifest
  //-------------------------------------------------------------------------

  Future<AssetManifest> loadManifest(
    String doctorId,
  ) async {

    final db =
        await _openDatabase();

    try {

      final transaction =
          db.transaction(
        _storeName,
        idbModeReadOnly,
      );

      final store =
          transaction.objectStore(
            _storeName,
          );

      final value =
          await store.getObject(
        _manifestKey(doctorId),
      );

      if (value == null) {
        return const AssetManifest();
      }

      final json =
          jsonDecode(
            value.toString(),
          );

      return AssetManifest.fromJson(
        Map<String, dynamic>.from(json),
      );

    } finally {

      db.close();

    }
  }

  Future<void> saveManifest(
    String doctorId,
    AssetManifest manifest,
  ) async {

    final db =
        await _openDatabase();

    try {

      final transaction =
          db.transaction(
        _storeName,
        idbModeReadWrite,
      );

      final store =
          transaction.objectStore(
            _storeName,
          );

      await store.put(
        jsonEncode(
          manifest.toJson(),
        ),
        _manifestKey(doctorId),
      );

      await transaction.completed;

    } finally {

      db.close();

    }
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
        manifest.getVersion(
          assetType,
        );

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

    final db =
        await _openDatabase();

    try {

      final transaction =
          db.transaction(
        _storeName,
        idbModeReadWrite,
      );

      final store =
          transaction.objectStore(
            _storeName,
          );

      // Delete only this doctor's assets.
      for (final assetType in AssetType.values) {
        await store.delete(
          _assetKey(
            doctorId,
            assetType,
          ),
        );
      }

      // Delete only this doctor's manifest.
      await store.delete(
        _manifestKey(doctorId),
      );

      await transaction.completed;

    } finally {

      db.close();

    }
  }
}
