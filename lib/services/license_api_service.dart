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
      print("response status code is 401 and refreshtoken is not null");
      // Try refresh
      final refreshRes = await http.post(
        Uri.parse("$baseUrl/api/doctor/refresh"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      print("Refresh status: ${refreshRes.statusCode}");
      print("Refresh body: ${refreshRes.body}");

      if (refreshRes.statusCode == 200) {
        final newAccessToken = jsonDecode(refreshRes.body)["accessToken"];
        await prefs.setString("access_token", newAccessToken);
 
// ✅ Update both memory & storage
      accessToken = newAccessToken;
 print("🔑 Old access token: $accessToken");
print("🔑 New access token: $newAccessToken");

        response = await http.get(
          Uri.parse(url),
          headers: {"Authorization": "Bearer $accessToken"},
        );
      } else {
        print("inside logout");
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
/// 🔐 Helper: Authenticated PUT
static Future<http.Response> _authenticatedPut(
    String url, Map<String, dynamic> body) async {
  final prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.getString("access_token");
  String? refreshToken = prefs.getString("refresh_token");

  var response = await http.put(
    Uri.parse(url),
    headers: {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    },
    body: jsonEncode(body),
  );

  // 🔁 handle expired token
  if (response.statusCode == 401 && refreshToken != null) {
    final refreshRes = await http.post(
      Uri.parse("$baseUrl/api/doctor/refresh"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refreshToken": refreshToken}),
    );

    if (refreshRes.statusCode == 200) {
      final newAccessToken = jsonDecode(refreshRes.body)["accessToken"];
      await prefs.setString("access_token", newAccessToken);

      response = await http.put(
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

static Future<int?> incrementPrescriptionCount() async {
  try {
    
    final response = await _authenticatedPut(
      "$baseUrl/api/doctor/increment-prescription",
      {}, // no body needed, just empty JSON
    );
 
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      //saving to shared Pref 
      final prefs = await SharedPreferences.getInstance();
       // Optionally also cache doctor profile locally
    if (data["doctor"] != null) {
      await prefs.setString("doctor_profile", jsonEncode(data["doctor"]));
    }
 
      return data["prescriptionCount"] as int;
    } else {
      print("Failed to increment prescription count: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("Error incrementing prescription count: $e");
    return null;
  }
}



  /// ✅ Register doctor (no auth needed)
  static Future<bool> registerDoctorOnServer(DoctorInfo info) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/doctor/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(info.toJson()),
    );

    if (response.statusCode == 201) {
    final data = jsonDecode(response.body);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("access_token", data["accessToken"]);
    await prefs.setString("refresh_token", data["refreshToken"]);
    await prefs.setString("doctor_name", data["doctor"]["name"]);

    // Optionally also cache doctor profile locally
    if (data["doctor"] != null) {
      await prefs.setString("doctor_profile", jsonEncode(data["doctor"]));
    }

    return true;
    }
    else {
    print("❌ Registration failed: ${response.statusCode} ${response.body}");
    return false;
  }
  }


  /// ✅ Update doctor info (requires auth)
// static Future<bool> updateDoctorOnServer(DoctorInfo info) async {
//   try {
//     // Retrieve access token from SharedPreferences
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('access_token');

//     if (token == null) {
//       print("❌ No access token found, cannot update doctor info");
//       return false;
//     }

//     final response = await http.put(
//       Uri.parse('$baseUrl/api/doctor/update'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token', // ✅ auth header
//       },
//       body: jsonEncode(info.toJson()
//         ..removeWhere((key, value) => value == null || value == "")), // remove empty fields
//     );

//     if (response.statusCode == 200) {
//       print("✅ Doctor info updated successfully");
//       return true;
//     } else {
//       print("❌ Failed to update doctor info: ${response.body}");
//       return false;
//     }
//   } catch (e) {
//     print("❌ Exception in updateDoctorOnServer: $e");
//     return false;
//   }
// }

/// ✅ Update doctor info
static Future<bool> updateDoctorOnServer(DoctorInfo info) async {
  final response = await _authenticatedPut(
    "$baseUrl/api/doctor/update",
    info.toJson(),
  );
  final prefs = await SharedPreferences.getInstance();
  final doctorData = await fetchDoctorProfile();
  
  if (doctorData != null) {
    
     await prefs.setString("doctor_profile", jsonEncode(doctorData["doctor"]));
  }
  return response.statusCode == 200;
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
          await prefs.setString("doctor_name", data["doctor"]["name"]);
          
          
          await prefs.setString("doctor_profile", jsonEncode(data["doctor"]));
          
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

//   // license_api_service.dart
// static Future<Map<String, dynamic>?> fetchDoctorProfile() async {
//   try {
//     final prefs = await SharedPreferences.getInstance();
//     final accessToken = prefs.getString("access_token");

//     if (accessToken == null) return null;

//     final response = await http.get(
//       Uri.parse("$baseUrl/api/doctor/me"),
//       headers: {
//         "Authorization": "Bearer $accessToken",
//         "Content-Type": "application/json",
//       },
//     );

//     if (response.statusCode == 200) {
//       final profile = jsonDecode(response.body) as Map<String, dynamic>;
//       return profile;
//     } else if (response.statusCode == 401) {
//       print("⛔ Token expired, consider refreshing here");
//       return null;
//     } else {
//       print("❌ Fetch failed: ${response.statusCode} ${response.body}");
//       return null;
//     }
//   } catch (e) {
//     print("Error fetching doctor profile: $e");
//     return null;
//   }
// }

// ✅ license_api_service.dart

static Future<Map<String, dynamic>?> fetchDoctorProfile() async {
  try {
    final response = await _authenticatedGet("$baseUrl/api/doctor/me");

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 401) {
      // This means refresh also failed
      print("⛔ Unauthorized: token expired and refresh failed");
      return null;
    } else {
      print("❌ Failed to fetch profile: ${response.statusCode} ${response.body}");
      return null;
    }
  } catch (e) {
    print("⚠️ Error in fetchDoctorProfile: $e");
    return null;
  }
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
    await prefs.remove("access_token");
  await prefs.remove("refresh_token");
    await prefs.clear();
  }

  static Future<void> logoutDoctor() async => _logout();
}
