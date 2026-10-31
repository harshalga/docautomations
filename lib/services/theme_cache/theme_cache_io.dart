import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'theme_cache_manifest.dart';

class ThemeCachePlatform {
  static const String _cacheFolder = "prescription_theme_cache";
  static const String _manifestFile = "theme_manifest.json";

  Future<Directory> _getCacheDirectory() async {
    final documents = await getApplicationDocumentsDirectory();

    final directory = Directory(
      p.join(documents.path, _cacheFolder),
    );

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return directory;
  }

  void _validateThemeId(String themeId) {
    if (!RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(themeId)) {
      throw ArgumentError("Invalid theme ID: $themeId");
    }
  }

  Future<File> _getThemeFile(String themeId) async {
    _validateThemeId(themeId);

    final directory = await _getCacheDirectory();

    return File(
      p.join(directory.path, "$themeId.json"),
    );
  }

  Future<File> _getManifestFile() async {
    final directory = await _getCacheDirectory();

    return File(
      p.join(directory.path, _manifestFile),
    );
  }

  Future<Map<String, dynamic>?> loadTheme(
    String themeId,
  ) async {
    final file = await _getThemeFile(themeId);

    if (!await file.exists()) return null;

    try {
      final decoded = jsonDecode(await file.readAsString());

      if (decoded is! Map) return null;

      return Map<String, dynamic>.from(decoded);
    } catch (_) {
      return null;
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
    final file = await _getThemeFile(themeId);

    final temporaryFile = File("${file.path}.tmp");

    try {
      await temporaryFile.writeAsString(
        jsonEncode(themeJson),
        flush: true,
      );

      // Replace the theme record first.
      await temporaryFile.rename(file.path);

      // The manifest is the commit record.
      await saveManifest(manifest);
    } catch (_) {
      if (await temporaryFile.exists()) {
        await temporaryFile.delete();
      }

      rethrow;
    }
  }

  //===========================================================================
  // Remove Theme + Manifest
  //===========================================================================

  Future<void> removeTheme({
    required String themeId,
    required ThemeCacheManifest manifest,
  }) async {
    // Remove the ID from the manifest first.
    await saveManifest(manifest);

    final file = await _getThemeFile(themeId);

    if (await file.exists()) {
      await file.delete();
    }
  }

  //===========================================================================
  // Load Theme IDs
  //===========================================================================

  Future<List<String>> loadThemeIds() async {
    final directory = await _getCacheDirectory();

    final files = directory
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith(".json"))
        .where((file) => !file.path.endsWith(_manifestFile))
        .where((file) => !file.path.endsWith(".tmp"));

    return files
        .map((file) => p.basenameWithoutExtension(file.path))
        .toList();
  }

  //===========================================================================
  // Manifest
  //===========================================================================

  Future<ThemeCacheManifest> loadManifest() async {
    final file = await _getManifestFile();

    if (!await file.exists()) {
      return const ThemeCacheManifest();
    }

    try {
      final decoded = jsonDecode(await file.readAsString());

      if (decoded is! Map) {
        return const ThemeCacheManifest();
      }

      return ThemeCacheManifest.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } catch (_) {
      return const ThemeCacheManifest();
    }
  }

  Future<void> saveManifest(
    ThemeCacheManifest manifest,
  ) async {
    final file = await _getManifestFile();
    final temporaryFile = File("${file.path}.tmp");

    try {
      await temporaryFile.writeAsString(
        jsonEncode(manifest.toJson()),
        flush: true,
      );

      await temporaryFile.rename(file.path);
    } catch (_) {
      if (await temporaryFile.exists()) {
        await temporaryFile.delete();
      }

      rethrow;
    }
  }

  //===========================================================================
  // Clear Cache
  //===========================================================================

  Future<void> clearCache() async {
    final directory = await _getCacheDirectory();

    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }
}