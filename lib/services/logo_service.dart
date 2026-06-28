import 'dart:convert';
import 'dart:typed_data';

import 'package:docautomations/services/license_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoService {
  static const String _logoKey = "doctor_logo";

  /// Returns logo from cache.
  /// If not cached, downloads from server and caches it.
  static Future<Uint8List?> getLogo() async {
    final prefs = await SharedPreferences.getInstance();

    // ----------------------------
    // 1. Try local cache
    // ----------------------------
    final cachedLogo = prefs.getString(_logoKey);

    if (cachedLogo != null && cachedLogo.isNotEmpty) {
      try {
        return base64Decode(cachedLogo);
      } catch (_) {
        // Corrupted cache
        await prefs.remove(_logoKey);
      }
    }

    // ----------------------------
    // 2. Download from server
    // ----------------------------
    final bytes = await LicenseApiService.fetchDoctorLogo();

    if (bytes != null) {
      await cacheLogo(bytes);
    }

    return bytes;
  }

  /// Saves logo to cache.
  static Future<void> cacheLogo(Uint8List logoBytes) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _logoKey,
      base64Encode(logoBytes),
    );
  }

  /// Deletes cached logo.
  static Future<void> clearLogo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_logoKey);
  }

  /// Refreshes logo from server.
  static Future<Uint8List?> refreshLogo() async {
    await clearLogo();
    return await getLogo();
  }

  /// Returns true if logo already exists in cache.
  static Future<bool> hasCachedLogo() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.containsKey(_logoKey);
  }
}