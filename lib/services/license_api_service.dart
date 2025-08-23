// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:docautomations/widgets/doctorinfo.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class LicenseApiService {
//   static const String baseUrl = "https://license-server-0zfe.onrender.com";//"http://localhost:5173/api";

//    // Save doctor info to server
//   static Future<bool> registerDoctorOnServer(DoctorInfo info) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/api/doctor/register'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode(info.toJson()),
//     );

//     if (response.statusCode == 201) {
//       print('✅ Doctor saved');
//       return true;
//     } else {
//       print('❌ Failed to save: ${response.body}');
//       return false;
//     }
//   }



// static Future<bool> verifyToken(String token) async {
//   try {
//     final response = await http.get(
//       Uri.parse('$baseUrl/api/doctor/me'),
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },
//     );
//      if (response.statusCode == 200) {
//       print("✅ Token valid: ${response.body}");
//       return true;
//     } else {
//       print("❌ Token invalid: ${response.body}");
//       return false;
//     }
//   } catch (e) {
//     print("Token verification failed: $e");
//     return false;
//   }
// }

//   // Check if doctor exists by fixed ID or implement logic for auth later
//   static Future<DoctorInfo?> fetchRegisteredDoctor() async {
    
//      try {
//     final response = await http.get(Uri.parse('$baseUrl/api/doctor/current'));
//     print("🔁 Doctor fetch status: ${response.statusCode}");
//     print("📦 Doctor fetch body: ${response.body}");

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       return DoctorInfo.fromJson(data);
//     } else {
//       print("❌ No doctor found");
//       return null;
//     }
//   } catch (e) {
//     print("❌ Exception in fetchRegisteredDoctor: $e");
//     return null;
//   }

//   }
  

  
//   static Future<bool> activateLicense(String email, String licenseKey) async {
//     final response = await http.post(
//       Uri.parse("$baseUrl/api/license/activate-license"),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'email': email, 'licenseKey': licenseKey}),
//     ).timeout(const Duration(seconds: 10));

//     return response.statusCode == 200 &&
//            jsonDecode(response.body)['success'] == true;
//   }

//   static Future<Map<String, dynamic>> checkLicense(String email) async {
//     final response = await http.post(
//       Uri.parse("$baseUrl/license/check-license"),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'email': email}),
//     );

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     }

//     return {'isLicensed': false, 'pdfCount': 0};
//   }

//   static Future<bool> incrementPdfCount(String email) async {
//     final response = await http.post(
//       Uri.parse("$baseUrl/license/increment-pdf"),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'email': email}),
//     );

//     return response.statusCode == 200 &&
//            jsonDecode(response.body)['success'] == true;
//   }


//   // ⏳ Check if token expired or invalid → auto logout
//   static Future<DoctorInfo?> fetchCurrentDoctor() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('jwt_token');

//     if (token == null) {
//       print("⚠️ No token saved, need login.");
//       return null;
//     }

//     final response = await http.get(
//       Uri.parse('$baseUrl/api/doctor/me'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       return DoctorInfo.fromJson(data);
//     } else if (response.statusCode == 401) {
//       // ⛔ Token expired or invalid → clear session
//       print("⛔ Token expired. Logging out...");
//       await _logout();
//       return null;
//     } else {
//       print("❌ Failed fetch: ${response.body}");
//       return null;
//     }
//   }

//   static Future<void> _logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear(); // removes jwt + doctor info
//   }


//   /// Login doctor
//   static Future<bool> loginDoctor(String loginEmail, String password) async {
//     final response = await http.post(
//       Uri.parse("$baseUrl/api/doctor/login"),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({"loginEmail": loginEmail, "password": password}),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);

//       final prefs = await SharedPreferences.getInstance();
//      //await prefs.setString("jwt_token", data["token"]);
//       await prefs.setString("access_token", data["accessToken"]);
//       await prefs.setString("refresh_token", data["refreshToken"]);

//       await prefs.setString("doctor_name", data["doctor"]["name"]);

      
//       prefs.setString('doctor_info', jsonEncode(data));

//       return true;
//     }
//     return false;
//   }

// Future<http.Response> authenticatedGet(String url) async {
//   final prefs = await SharedPreferences.getInstance();
//   String? accessToken = prefs.getString("access_token");
//   String? refreshToken = prefs.getString("refresh_token");

//   var response = await http.get(
//     Uri.parse(url),
//     headers: {"Authorization": "Bearer $accessToken"},
//   );

//   if (response.statusCode == 401 && refreshToken != null) {
//     // Try refresh
//     final refreshRes = await http.post(
//       Uri.parse("$baseUrl/api/doctor/refresh"),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({"refreshToken": refreshToken}),
//     );

//     if (refreshRes.statusCode == 200) {
//       final newAccessToken = jsonDecode(refreshRes.body)["accessToken"];
//       await prefs.setString("access_token", newAccessToken);

//       // Retry original request
//       response = await http.get(
//         Uri.parse(url),
//         headers: {"Authorization": "Bearer $newAccessToken"},
//       );
//     } else {
//       // Refresh failed → logout
//       _logout();
//     }
//   }

//   return response;
// }


// Future<http.Response> authenticatedPost(String url, Map<String, dynamic> body) async {
//   final prefs = await SharedPreferences.getInstance();
//   String? accessToken = prefs.getString("access_token");
//   String? refreshToken = prefs.getString("refresh_token");

//   var response = await http.post(
//     Uri.parse(url),
//     headers: {
//       "Authorization": "Bearer $accessToken",
//       "Content-Type": "application/json",
//     },
//     body: jsonEncode(body),
//   );

//   if (response.statusCode == 401 && refreshToken != null) {
//     final refreshRes = await http.post(
//       Uri.parse("$baseUrl/api/doctor/refresh"),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({"refreshToken": refreshToken}),
//     );

//     if (refreshRes.statusCode == 200) {
//       final newAccessToken = jsonDecode(refreshRes.body)["accessToken"];
//       await prefs.setString("access_token", newAccessToken);

//       response = await http.post(
//         Uri.parse(url),
//         headers: {
//           "Authorization": "Bearer $newAccessToken",
//           "Content-Type": "application/json",
//         },
//         body: jsonEncode(body),
//       );
//     } else {
//       _logout();
//     }
//   }

//   return response;
// }


//   /// Validate stored token
//   static Future<bool> isTokenValid(String token) async {
//     final response = await http.post(
//       Uri.parse("$baseUrl/api/doctor/validate-token"),
//       headers: {
//         "Content-Type": "application/json",
//         "Authorization": "Bearer $token",
//       },
//     );

//     if (response.statusCode == 200) {
//       final result = jsonDecode(response.body);
//       return result["valid"] == true;
//     }
//     return false;
//   }

//   /// Logout doctor (clear local storage)
//   static Future<void> logoutDoctor() async {
//     final prefs = await SharedPreferences.getInstance();
//     //await prefs.remove("jwt_token");
//     await prefs.remove("access_token");
//     await prefs.remove("refresh_token");
//         await prefs.remove("doctor_name");
//   }


// }
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:docautomations/widgets/doctorinfo.dart';

class LicenseApiService {
  static const String baseUrl = "https://license-server-0zfe.onrender.com";

  /// 🔐 Helper: Authenticated GET
  static Future<http.Response> _authenticatedGet(String url) async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("access_token");
    String? refreshToken = prefs.getString("refresh_token");

    var response = await http.get(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $accessToken"},
    );

    if (response.statusCode == 401 && refreshToken != null) {
      // Try refresh
      final refreshRes = await http.post(
        Uri.parse("$baseUrl/api/doctor/refresh"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      if (refreshRes.statusCode == 200) {
        final newAccessToken = jsonDecode(refreshRes.body)["accessToken"];
        await prefs.setString("access_token", newAccessToken);

        response = await http.get(
          Uri.parse(url),
          headers: {"Authorization": "Bearer $newAccessToken"},
        );
      } else {
        await _logout();
      }
    }

    return response;
  }

  /// 🔐 Helper: Authenticated POST
  static Future<http.Response> _authenticatedPost(
      String url, Map<String, dynamic> body) async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("access_token");
    String? refreshToken = prefs.getString("refresh_token");

    var response = await http.post(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $accessToken",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 401 && refreshToken != null) {
      final refreshRes = await http.post(
        Uri.parse("$baseUrl/api/doctor/refresh"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      if (refreshRes.statusCode == 200) {
        final newAccessToken = jsonDecode(refreshRes.body)["accessToken"];
        await prefs.setString("access_token", newAccessToken);

        response = await http.post(
          Uri.parse(url),
          headers: {
            "Authorization": "Bearer $newAccessToken",
            "Content-Type": "application/json",
          },
          body: jsonEncode(body),
        );
      } else {
        await _logout();
      }
    }

    return response;
  }

  /// ✅ Register doctor (no auth needed)
  static Future<bool> registerDoctorOnServer(DoctorInfo info) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/doctor/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(info.toJson()),
    );

    return response.statusCode == 201;
  }

  /// ✅ Login doctor
  static Future<Map<String, String>?> loginDoctor(String loginEmail, String password) async {

    try {

    final response = await http.post(
      Uri.parse("$baseUrl/api/doctor/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"loginEmail": loginEmail, "password": password}),
    );

     if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final accessToken = data["accessToken"];
        final refreshToken = data["refreshToken"];

        if (accessToken != null && refreshToken != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("access_token", accessToken);
          await prefs.setString("refresh_token", refreshToken);

          return {
            "accessToken": accessToken,
            "refreshToken": refreshToken,
          };
        }
      }
    } catch (e) {
      print("Login error: $e");
    }
    return null;
  }

  /// ✅ Fetch current doctor
  static Future<DoctorInfo?> fetchCurrentDoctor() async {
    final response = await _authenticatedGet("$baseUrl/api/doctor/me");

    if (response.statusCode == 200) {
      return DoctorInfo.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      await _logout();
    }
    return null;
  }

  /// ✅ Fetch doctor by ID (if needed)
  static Future<DoctorInfo?> fetchRegisteredDoctor() async {
    final response = await _authenticatedGet("$baseUrl/api/doctor/current");

    if (response.statusCode == 200) {
      return DoctorInfo.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  /// ✅ Activate license
  static Future<bool> activateLicense(String email, String licenseKey) async {
    final response = await _authenticatedPost(
      "$baseUrl/api/license/activate-license",
      {'email': email, 'licenseKey': licenseKey},
    );
    return response.statusCode == 200 &&
        jsonDecode(response.body)['success'] == true;
  }

  /// ✅ Check license
  static Future<Map<String, dynamic>> checkLicense(String email) async {
    final response = await _authenticatedPost(
      "$baseUrl/license/check-license",
      {'email': email},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return {'isLicensed': false, 'pdfCount': 0};
  }

  /// ✅ Increment PDF usage
  static Future<bool> incrementPdfCount(String email) async {
    final response = await _authenticatedPost(
      "$baseUrl/license/increment-pdf",
      {'email': email},
    );
    return response.statusCode == 200 &&
        jsonDecode(response.body)['success'] == true;
  }

  /// ✅ Verify token
  static Future<bool> verifyToken(String accessToken) async {
    try 
    {
    final response = await http.get(
      Uri.parse('$baseUrl/api/doctor/me'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        // Access token expired → try refreshing
        final prefs = await SharedPreferences.getInstance();
        final refreshToken = prefs.getString("refresh_token");

        if (refreshToken != null) {
          final newAccessToken = await refreshAccessToken(refreshToken);
          if (newAccessToken != null) {
            // Retry verification with new token
            return await verifyToken(newAccessToken);
          }
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
/// Refresh the access token using refresh token
  static Future<String?> refreshAccessToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/doctor/refresh"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data["accessToken"];

        // save new access token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("access_token", newAccessToken);

        return newAccessToken;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
  /// ✅ Validate stored token
  static Future<bool> isTokenValid(String token) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/doctor/validate-token"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["valid"] == true;
    }
    return false;
  }

  /// ✅ Logout
  static Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> logoutDoctor() async => _logout();
}
