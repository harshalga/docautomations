import 'dart:convert';

import 'theme_cache_io.dart'
    if (dart.library.js_interop) 'theme_cache_web.dart';

import 'package:docautomations/datamodels/master/prescription_theme.dart';

import 'theme_cache_manifest.dart';

class ThemeCacheManager {
  final ThemeCachePlatform _platform = ThemeCachePlatform();

  //===========================================================================
  // Reconcile Cache
  //===========================================================================

  Future<ThemeCacheManifest> _reconcileCache() async {
  var manifest = await _platform.loadManifest();

  final cachedThemeIds = await _platform.loadThemeIds();
  final cachedIds = cachedThemeIds.toSet();

  // Remove manifest entries whose files no longer exist.
  for (final themeId in manifest.themeVersions.keys.toList()) {
    if (!cachedIds.contains(themeId)) {
      manifest = manifest.remove(themeId);
    }
  }

  // Recover valid theme files that are missing from the manifest.
  for (final themeId in cachedThemeIds) {
    if (manifest.contains(themeId)) continue;

    final json = await _platform.loadTheme(themeId);

    if (json == null) {
      await _platform.removeTheme(
        themeId: themeId,
        manifest: manifest,
      );
      continue;
    }

    try {
      final theme = PrescriptionTheme.fromJson(json);

      if (theme.id != themeId || !theme.isActive) {
        await _platform.removeTheme(
          themeId: themeId,
          manifest: manifest,
        );
        continue;
      }

      final updatedAt =
          theme.updatedAt?.toUtc().toIso8601String() ?? "";

      manifest = manifest.setVersion(
        themeId,
        updatedAt,
      );
    } catch (_) {
      await _platform.removeTheme(
        themeId: themeId,
        manifest: manifest,
      );
    }
  }

  await _platform.saveManifest(manifest);

  return manifest;
}

  //===========================================================================
  // Load Cached Themes
  //===========================================================================

  Future<List<PrescriptionTheme>> loadCachedThemes() async {
    final manifest = await _reconcileCache();

    final themes = <PrescriptionTheme>[];

    for (final themeId in manifest.themeVersions.keys) {
      final json = await _platform.loadTheme(themeId);

      if (json == null) continue;

      try {
        final theme = PrescriptionTheme.fromJson(json);

        if (theme.isActive) {
          themes.add(theme);
        }
      } catch (_) {
        // Ignore an invalid cache entry.
      }
    }

    themes.sort(
      (a, b) => a.name.compareTo(b.name),
    );

    return themes;
  }

  //===========================================================================
  // Synchronize Themes
  //===========================================================================

  Future<List<PrescriptionTheme>> synchronize({
    required Future<List<PrescriptionTheme>> Function() fetchThemes,
  }) async {
    // Fetch before modifying the cache.
    // A network failure therefore leaves the existing cache untouched.
    final serverThemes = await fetchThemes();

    final activeThemes = serverThemes
        .where((theme) => theme.isActive)
        .toList();

    var manifest = await _reconcileCache();

    final activeThemeIds = activeThemes
        .map((theme) => theme.id)
        .toSet();

    //------------------------------------------------------------------------
    // Save new or updated themes
    //------------------------------------------------------------------------

    for (final theme in activeThemes) {
      if (theme.id.trim().isEmpty) {
        throw Exception(
          "Cannot cache a theme with an empty ID.",
        );
      }

      final cachedJson = await _platform.loadTheme(theme.id);

      final serverJson = theme.toJson();

      final serverUpdatedAt =
          theme.updatedAt?.toUtc().toIso8601String() ?? "";

      final cachedUpdatedAt =
          manifest.getUpdatedAt(theme.id);

      final needsUpdate = cachedJson == null ||
    !manifest.contains(theme.id) ||
    serverUpdatedAt != cachedUpdatedAt ||
    (serverUpdatedAt.isEmpty &&
        jsonEncode(cachedJson) != jsonEncode(serverJson));

      if (needsUpdate) {
        final updatedManifest = manifest.setVersion(
          theme.id,
          serverUpdatedAt,
        );

        // Theme and manifest are committed together logically.
        await _platform.commitTheme(
          themeId: theme.id,
          themeJson: serverJson,
          manifest: updatedManifest,
        );

        manifest = updatedManifest;
      }
    }

    //------------------------------------------------------------------------
    // Remove themes that are no longer active
    //------------------------------------------------------------------------

    final cachedThemeIds = await _platform.loadThemeIds();

    for (final cachedThemeId in cachedThemeIds) {
      if (!activeThemeIds.contains(cachedThemeId)) {
        final updatedManifest = manifest.remove(cachedThemeId);

        await _platform.removeTheme(
          themeId: cachedThemeId,
          manifest: updatedManifest,
        );

        manifest = updatedManifest;
      }
    }

    await _platform.saveManifest(manifest);

    return loadCachedThemes();
  }

  //===========================================================================
  // Clear Theme Cache
  //===========================================================================

  Future<void> clearCache() async {
    await _platform.clearCache();
  }
}