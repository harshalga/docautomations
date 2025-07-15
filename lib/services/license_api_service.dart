import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:docautomations/widgets/doctorinfo.dart';

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
}
