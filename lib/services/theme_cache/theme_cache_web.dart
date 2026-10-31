import 'dart:convert';

import 'package:idb_shim/idb_browser.dart';

import 'theme_cache_manifest.dart';

class ThemeCachePlatform {
  static const String _databaseName =
      "prescriptor_theme_cache";

  static const String _storeName = "themes";

  static const String _manifestKey = "_theme_manifest";

  Future<Database> _openDatabase() async {
    final factory = getIdbFactory();

    if (factory == null) {
      throw Exception(
        "IndexedDB is not available in this browser.",
      );
    }

    return factory.open(
      _databaseName,
      version: 1,
      onUpgradeNeeded: (VersionChangeEvent event) {
        final db = event.database;

        if (!db.objectStoreNames.contains(_storeName)) {
          db.createObjectStore(_storeName);
        }
      },
    );
  }

  Future<Map<String, dynamic>?> loadTheme(
    String themeId,
  ) async {
    final db = await _openDatabase();

    try {
      final transaction = db.transaction(
        _storeName,
        idbModeReadOnly,
      );

      final value = await transaction
          .objectStore(_storeName)
          .getObject(themeId);

      if (value == null) return null;

      try {
        final decoded = jsonDecode(value.toString());

        if (decoded is! Map) return null;

        return Map<String, dynamic>.from(decoded);
      } catch (_) {
        return null;
      }
    } finally {
      db.close();
    }
  }

  //===========================================================================
  // Atomic Theme + Manifest Commit
  //===========================================================================

  Future<void> commitTheme({
    required String themeId,
    required Map<String, dynamic> themeJson,
    required ThemeCacheManifest manifest,
  }) async {
    final db = await _openDatabase();

    try {
      final transaction = db.transaction(
        _storeName,
        idbModeReadWrite,
      );

      final store = transaction.objectStore(_storeName);

      await store.put(
        jsonEncode(themeJson),
        themeId,
      );

      await store.put(
        jsonEncode(manifest.toJson()),
        _manifestKey,
      );

      await transaction.completed;
    } finally {
      db.close();
    }
  }

  //===========================================================================
  // Atomic Theme Removal + Manifest Update
  //===========================================================================

  Future<void> removeTheme({
    required String themeId,
    required ThemeCacheManifest manifest,
  }) async {
    final db = await _openDatabase();

    try {
      final transaction = db.transaction(
        _storeName,
        idbModeReadWrite,
      );

      final store = transaction.objectStore(_storeName);

      await store.delete(themeId);

      await store.put(
        jsonEncode(manifest.toJson()),
        _manifestKey,
      );

      await transaction.completed;
    } finally {
      db.close();
    }
  }

  //===========================================================================
  // Load Theme IDs
  //===========================================================================

  Future<List<String>> loadThemeIds() async {
    final db = await _openDatabase();

    try {
      final transaction = db.transaction(
        _storeName,
        idbModeReadOnly,
      );

      final keys = await transaction
          .objectStore(_storeName)
          .getAllKeys();

      return keys
          .map((key) => key.toString())
          .where((key) => key != _manifestKey)
          .toList();
    } finally {
      db.close();
    }
  }

  //===========================================================================
  // Manifest
  //===========================================================================

  Future<ThemeCacheManifest> loadManifest() async {
    final db = await _openDatabase();

    try {
      final transaction = db.transaction(
        _storeName,
        idbModeReadOnly,
      );

      final value = await transaction
          .objectStore(_storeName)
          .getObject(_manifestKey);

      if (value == null) {
        return const ThemeCacheManifest();
      }

      try {
        final decoded = jsonDecode(value.toString());

        if (decoded is! Map) {
          return const ThemeCacheManifest();
        }

        return ThemeCacheManifest.fromJson(
          Map<String, dynamic>.from(decoded),
        );
      } catch (_) {
        return const ThemeCacheManifest();
      }
    } finally {
      db.close();
    }
  }

  Future<void> saveManifest(
    ThemeCacheManifest manifest,
  ) async {
    final db = await _openDatabase();

    try {
      final transaction = db.transaction(
        _storeName,
        idbModeReadWrite,
      );

      await transaction.objectStore(_storeName).put(
            jsonEncode(manifest.toJson()),
            _manifestKey,
          );

      await transaction.completed;
    } finally {
      db.close();
    }
  }

  //===========================================================================
  // Clear Cache
  //===========================================================================

  Future<void> clearCache() async {
    final db = await _openDatabase();

    try {
      final transaction = db.transaction(
        _storeName,
        idbModeReadWrite,
      );

      await transaction.objectStore(_storeName).clear();

      await transaction.completed;
    } finally {
      db.close();
    }
  }
}