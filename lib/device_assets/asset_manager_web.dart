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

  static const String _manifestKey =
      "__manifest__";

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
        assetType.fileName,
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
        assetType.fileName,
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
        assetType.fileName,
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
        assetType.fileName,
      );

      await transaction.completed;

    } finally {

      db.close();

    }

    var manifest =
        await loadManifest();

    manifest =
        manifest.remove(
          assetType,
        );

    await saveManifest(
      manifest,
    );
  }

  //-------------------------------------------------------------------------
  // Manifest
  //-------------------------------------------------------------------------

  Future<AssetManifest> loadManifest() async {

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
        _manifestKey,
      );

      if (value == null) {
        return const AssetManifest();
      }

      final json =
          jsonDecode(
            value.toString(),
          );

      return AssetManifest.fromJson(
        json,
      );

    } finally {

      db.close();

    }
  }

  Future<void> saveManifest(
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
        _manifestKey,
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
    AssetType assetType,
    int serverVersion,
  ) async {

    if (!await assetExists(assetType)) {
      return true;
    }

    final manifest =
        await loadManifest();

    if (!manifest.contains(assetType)) {
      return true;
    }

    final localVersion =
        manifest.getVersion(
          assetType,
        );

    return serverVersion > localVersion;
  }

  //-------------------------------------------------------------------------
  // Update Asset
  //-------------------------------------------------------------------------

  Future<void> updateAsset({
    required AssetType assetType,
    required List<int> bytes,
    required int serverVersion,
  }) async {

    await saveAsset(
      assetType,
      bytes,
    );

    var manifest =
        await loadManifest();

    manifest =
        manifest.setVersion(
          assetType,
          serverVersion,
        );

    await saveManifest(
      manifest,
    );
  }

  //-------------------------------------------------------------------------
  // Clear Assets
  //-------------------------------------------------------------------------

  Future<void> clearAssets() async {

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

      await store.clear();

      await transaction.completed;

    } finally {

      db.close();

    }
  }
}