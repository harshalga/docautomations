// import 'package:docautomations/network/dio_client.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class AuthService {
//   static const storage = FlutterSecureStorage();

//   static Future<String?> getToken() async {
//     return await storage.read(key: "accessToken");
//   }

//   static Future<String?> getRefreshToken() async {
//     return await storage.read(key: "refreshToken");
//   }

//   static Future<void> saveTokens({required String accessToken,
//   required String refreshToken,}
       
//   ) async {
//     await storage.write(
//         key: "accessToken",
//         value: accessToken);

//     await storage.write(
//         key: "refreshToken",
//         value: refreshToken);
//   }

//   static Future<bool> refreshAccessToken() async {
//     try {
//       final refresh =
//           await getRefreshToken();

//       if (refresh == null) return false;

//       final response =
//           await DioClient.instance.post(
//         "/api/doctor/refresh",
//         data: {
//           "refreshToken": refresh
//         },
//       );

//       final newToken =
//           response.data["accessToken"];

//       await storage.write(
//         key: "accessToken",
//         value: newToken,
//       );

//       return true;

//     } catch (e) {
//       return false;
//     }
//   }

//   // ==========================
//   // LOGOUT
//   // ==========================
//   static Future<void> logout() async {
//     try {
//       await storage.delete(
//         key: "accessToken",
//       );

//       await storage.delete(
//         key: "refreshToken",
//       );

//       // Optional: clear all secure keys
//       // await _storage.deleteAll();

//       print("✅ User logged out");
//     } catch (e) {
//       print("❌ Logout error: $e");
//     }
//   }
// }


import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:docautomations/utils/app_config.dart';


class AuthService {

  //===========================================================================
  // Secure Storage
  //===========================================================================

  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();


  //===========================================================================
  // Storage Keys
  //===========================================================================

  static const String _accessTokenKey =
      "accessToken";

  static const String _refreshTokenKey =
      "refreshToken";


  //===========================================================================
  // API Endpoints
  //===========================================================================

  static const String _loginEndpoint =
      "/api/doctor/login";

  static const String _refreshEndpoint =
      "/api/doctor/refresh-token";

  static const String _logoutEndpoint =
      "/api/doctor/logout";


  //===========================================================================
  // Plain Authentication HTTP Client
  //
  // This Dio instance has NO interceptors.
  //
  // It must be used for:
  //
  // - Login
  // - Refresh Token
  // - Logout
  //
  // This prevents:
  //
  // DioClient → AuthService → DioClient circular dependency
  //===========================================================================

  static final Dio _authDio =
      Dio(

        BaseOptions(

          baseUrl:
              AppConfig.baseUrl,

          connectTimeout:
              const Duration(
                seconds: 15,
              ),

          receiveTimeout:
              const Duration(
                seconds: 45,
              ),

          headers: {

            "Content-Type":
                "application/json",

            "Accept":
                "application/json",

          },

        ),

      );


  //===========================================================================
  // Get Access Token
  //===========================================================================

  static Future<String?> getAccessToken() async {

    return await _storage.read(

      key:
          _accessTokenKey,

    );

  }


  //=========================================================================== // Get Token //
  // // Backward-compatible alias for existing application code. // 
  //// The canonical method is getAccessToken(). 
  ///// This method delegates to it and does not maintain separate state. 
  /////=========================================================================== 
  static Future<String?> getToken() async {
   return await getAccessToken(); 
   }


  //===========================================================================
  // Get Refresh Token
  //===========================================================================

  static Future<String?> getRefreshToken() async {

    return await _storage.read(

      key:
          _refreshTokenKey,

    );

  }


  //===========================================================================
  // Check Authentication
  //===========================================================================

  static Future<bool> isAuthenticated() async {

    final accessToken =
        await getAccessToken();

    return accessToken != null &&
        accessToken.isNotEmpty;

  }


  //===========================================================================
  // Save Tokens
  //===========================================================================

  static Future<void> saveTokens({

    required String accessToken,

    required String refreshToken,

  }) async {

    await _storage.write(

      key:
          _accessTokenKey,

      value:
          accessToken,

    );


    await _storage.write(

      key:
          _refreshTokenKey,

      value:
          refreshToken,

    );

  }


  //===========================================================================
  // Login
  //
  // Uses plain Dio.
  //===========================================================================

  static Future<Map<String, dynamic>> login({

    required String loginEmail,

    required String password,

  }) async {

    final response =
        await _authDio.post(

      _loginEndpoint,

      data: {

        "loginEmail":
            loginEmail,

        "password":
            password,

      },

    );


    final responseData =
        Map<String, dynamic>.from(
          response.data,
        );


    //-----------------------------------------------------------------------
    // Save Tokens
    //-----------------------------------------------------------------------

    if (
        responseData["success"] == true &&
        responseData["data"] != null
    ) {

      final data =
          Map<String, dynamic>.from(
            responseData["data"],
          );


      final accessToken =
          data["accessToken"];

      final refreshToken =
          data["refreshToken"];


      if (
          accessToken != null &&
          refreshToken != null
      ) {

        await saveTokens(

          accessToken:
              accessToken,

          refreshToken:
              refreshToken,

        );

      }

    }


    return responseData;

  }


  //===========================================================================
  // Refresh Access Token
  //
  // IMPORTANT:
  //
  // Uses _authDio instead of DioClient.
  //
  // This prevents the refresh request from entering the DioClient
  // interceptor and causing recursion.
  //===========================================================================

  static Future<bool> refreshAccessToken() async {

    try {

      //---------------------------------------------------------------------
      // Get Refresh Token
      //---------------------------------------------------------------------

      final refreshToken =
          await getRefreshToken();


      if (
          refreshToken == null ||
          refreshToken.isEmpty
      ) {

        return false;

      }


      //---------------------------------------------------------------------
      // Call Backend Using Plain Dio
      //---------------------------------------------------------------------

      final response =
          await _authDio.post(

        _refreshEndpoint,

        data: {

          "refreshToken":
              refreshToken,

        },

      );


      final responseData =
          Map<String, dynamic>.from(
            response.data,
          );


      //---------------------------------------------------------------------
      // Validate Response
      //---------------------------------------------------------------------

      if (
          responseData["success"] != true
      ) {

        return false;

      }


      final responsePayload =
          responseData["data"];


      if (
          responsePayload == null
      ) {

        return false;

      }


      final data =
          Map<String, dynamic>.from(
            responsePayload,
          );


      //---------------------------------------------------------------------
      // Get New Access Token
      //---------------------------------------------------------------------

      final newAccessToken =
          data["accessToken"];


      if (
          newAccessToken == null ||
          newAccessToken.isEmpty
      ) {

        return false;

      }


      //---------------------------------------------------------------------
      // Save Access Token
      //---------------------------------------------------------------------

      await _storage.write(

        key:
            _accessTokenKey,

        value:
            newAccessToken,

      );


      //---------------------------------------------------------------------
      // Refresh Token Rotation
      //
      // If backend returns a new refresh token,
      // replace the existing one.
      //---------------------------------------------------------------------

      final newRefreshToken =
          data["refreshToken"];


      if (
          newRefreshToken != null &&
          newRefreshToken.isNotEmpty
      ) {

        await _storage.write(

          key:
              _refreshTokenKey,

          value:
              newRefreshToken,

        );

      }


      return true;

    }
    catch (_) {

      return false;

    }

  }


  //===========================================================================
  // Logout
  //
  // Uses plain Dio.
  //===========================================================================

  static Future<void> logout() async {

    try {

      //---------------------------------------------------------------------
      // Get Refresh Token
      //---------------------------------------------------------------------

      final refreshToken =
          await getRefreshToken();


      //---------------------------------------------------------------------
      // Inform Backend
      //---------------------------------------------------------------------

      if (
          refreshToken != null &&
          refreshToken.isNotEmpty
      ) {

        try {

          await _authDio.post(

            _logoutEndpoint,

            data: {

              "refreshToken":
                  refreshToken,

            },

          );

        }
        catch (_) {

          //---------------------------------------------------------------
          // Ignore server failure.
          //
          // Local logout must always continue.
          //---------------------------------------------------------------

        }

      }

    }
    finally {

      //---------------------------------------------------------------------
      // Always Remove Local Tokens
      //---------------------------------------------------------------------

      await clearTokens();

    }

  }


  //===========================================================================
  // Clear Tokens
  //===========================================================================

  static Future<void> clearTokens() async {

    await _storage.delete(

      key:
          _accessTokenKey,

    );


    await _storage.delete(

      key:
          _refreshTokenKey,

    );

  }


  //===========================================================================
  // Clear Authentication Data
  //===========================================================================

  static Future<void> clearAuthenticationData() async {

    await clearTokens();

  }

}