import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:docautomations/widgets/doctorinfo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LicenseApiService {
  static const String baseUrl = "https://license-server-0zfe.onrender.com";//"http://localhost:5173/api";

   // Save doctor info to server
  static Future<bool> registerDoctorOnServer(DoctorInfo info) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/doctor/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(info.toJson()),
    );

    if (response.statusCode == 201) {
      print('✅ Doctor saved');
      return true;
    } else {
      print('❌ Failed to save: ${response.body}');
      return false;
    }
  }

//  static Future<bool> loginDoctor(String loginEmail, String password) async {
  
//   final url = Uri.parse('$baseUrl/api/doctor/login');
  
//   final response = await http.post(
//     url,
//     headers: { 'Content-Type': 'application/json' },
//     body: jsonEncode({
//       'loginEmail': loginEmail,
//       'password': password
//     }),
//   );

//   if (response.statusCode == 200) {
//     final data = jsonDecode(response.body);
//     print("Doctor logged in: ${data['doctor']['name']}");

       
//     // Save to SharedPreferences
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('jwt_token', data['token']);
//     await prefs.setString('doctor_loginEmail', loginEmail);
//     await prefs.setString('doctor_name', data['doctor']['name']);
//     print("Login successful. Token saved.");
//     return  true;
//   } else {
//     print("Login failed: ${response.body}");
//     return false;
//   }
// }

static Future<bool> verifyToken(String token) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/api/doctor/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
     if (response.statusCode == 200) {
      print("✅ Token valid: ${response.body}");
      return true;
    } else {
      print("❌ Token invalid: ${response.body}");
      return false;
    }
  } catch (e) {
    print("Token verification failed: $e");
    return false;
  }
}

  // Check if doctor exists by fixed ID or implement logic for auth later
  static Future<DoctorInfo?> fetchRegisteredDoctor() async {
    
     try {
    final response = await http.get(Uri.parse('$baseUrl/api/doctor/current'));
    print("🔁 Doctor fetch status: ${response.statusCode}");
    print("📦 Doctor fetch body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return DoctorInfo.fromJson(data);
    } else {
      print("❌ No doctor found");
      return null;
    }
  } catch (e) {
    print("❌ Exception in fetchRegisteredDoctor: $e");
    return null;
  }

  }
  

  
  static Future<bool> activateLicense(String email, String licenseKey) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/license/activate-license"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'licenseKey': licenseKey}),
    ).timeout(const Duration(seconds: 10));

    return response.statusCode == 200 &&
           jsonDecode(response.body)['success'] == true;
  }

  static Future<Map<String, dynamic>> checkLicense(String email) async {
    final response = await http.post(
      Uri.parse("$baseUrl/license/check-license"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return {'isLicensed': false, 'pdfCount': 0};
  }

  static Future<bool> incrementPdfCount(String email) async {
    final response = await http.post(
      Uri.parse("$baseUrl/license/increment-pdf"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    return response.statusCode == 200 &&
           jsonDecode(response.body)['success'] == true;
  }


  // ⏳ Check if token expired or invalid → auto logout
  static Future<DoctorInfo?> fetchCurrentDoctor() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      print("⚠️ No token saved, need login.");
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/doctor/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return DoctorInfo.fromJson(data);
    } else if (response.statusCode == 401) {
      // ⛔ Token expired or invalid → clear session
      print("⛔ Token expired. Logging out...");
      await _logout();
      return null;
    } else {
      print("❌ Failed fetch: ${response.body}");
      return null;
    }
  }

  static Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // removes jwt + doctor info
  }


  /// Login doctor
  static Future<bool> loginDoctor(String loginEmail, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/doctor/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"loginEmail": loginEmail, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("jwt_token", data["token"]);
      await prefs.setString("doctor_name", data["doctor"]["name"]);

      
      prefs.setString('doctor_info', jsonEncode(data));

      return true;
    }
    return false;
  }

  /// Validate stored token
  static Future<bool> isTokenValid(String token) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/doctor/validate-token"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result["valid"] == true;
    }
    return false;
  }

  /// Logout doctor (clear local storage)
  static Future<void> logoutDoctor() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("jwt_token");
    await prefs.remove("doctor_name");
  }


}
