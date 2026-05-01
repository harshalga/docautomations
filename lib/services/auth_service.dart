import 'package:docautomations/network/dio_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const storage = FlutterSecureStorage();

  static Future<String?> getToken() async {
    return await storage.read(key: "accessToken");
  }

  static Future<String?> getRefreshToken() async {
    return await storage.read(key: "refreshToken");
  }

  static Future<void> saveTokens({required String accessToken,
  required String refreshToken,}
       
  ) async {
    await storage.write(
        key: "accessToken",
        value: accessToken);

    await storage.write(
        key: "refreshToken",
        value: refreshToken);
  }

  static Future<bool> refreshAccessToken() async {
    try {
      final refresh =
          await getRefreshToken();

      if (refresh == null) return false;

      final response =
          await DioClient.instance.post(
        "/api/doctor/refresh",
        data: {
          "refreshToken": refresh
        },
      );

      final newToken =
          response.data["accessToken"];

      await storage.write(
        key: "accessToken",
        value: newToken,
      );

      return true;

    } catch (e) {
      return false;
    }
  }

  // ==========================
  // LOGOUT
  // ==========================
  static Future<void> logout() async {
    try {
      await storage.delete(
        key: "accessToken",
      );

      await storage.delete(
        key: "refreshToken",
      );

      // Optional: clear all secure keys
      // await _storage.deleteAll();

      print("✅ User logged out");
    } catch (e) {
      print("❌ Logout error: $e");
    }
  }
}