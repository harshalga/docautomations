import 'dart:convert';
import 'package:http/http.dart' as http;

class LicenseApiService {
  static const String baseUrl = "https://license-server-0zfe.onrender.com/api";//"http://localhost:5173/api";

  static Future<bool> activateLicense(String email, String licenseKey) async {
    final response = await http.post(
      Uri.parse("$baseUrl/activate-license"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'licenseKey': licenseKey}),
    );

    return response.statusCode == 200 &&
           jsonDecode(response.body)['success'] == true;
  }

  static Future<Map<String, dynamic>> checkLicense(String email) async {
    final response = await http.post(
      Uri.parse("$baseUrl/check-license"),
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
      Uri.parse("$baseUrl/increment-pdf"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    return response.statusCode == 200 &&
           jsonDecode(response.body)['success'] == true;
  }
}
