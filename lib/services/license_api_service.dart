// import 'dart:convert';
// import 'package:docautomations/utils/logger.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:docautomations/widgets/doctorinfo.dart';

// class LicenseApiService {
//   static const String baseUrl = "https://license-server-0zfe.onrender.com";


//  static String? _accessToken;
//  static String? _refreshToken;


//   /// 🔐 Helper: Authenticated GET
//   static Future<http.Response> _authenticatedGet(String url) async {
    
//     await loadTokens();

//     final prefs = await SharedPreferences.getInstance();
//     String? accessToken1 = prefs.getString("access_token");
//     String? refreshToken1 = prefs.getString("refresh_token");


//     var response = await http.get(
//       Uri.parse(url),
//       headers: {"Authorization": "Bearer $accessToken1"},
//     );

//     if (response.statusCode == 401 && _refreshToken != null) {
     
//       // Try refresh
//       final refreshRes = await http.post(
//         Uri.parse("$baseUrl/api/doctor/refresh"),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({"refreshToken": _refreshToken}),
//       );

      

//       if (refreshRes.statusCode == 200) {
//         final newAccessToken = jsonDecode(refreshRes.body)["accessToken"];
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString("access_token", newAccessToken);
 
// // ✅ Update both memory & storage
//       _accessToken = newAccessToken;
 

//         response = await http.get(
//           Uri.parse(url),
//           headers: {"Authorization": "Bearer $_accessToken"},
//         );
//       } else {
        
//         await _logout();
//       }
//     }

//     return response;
//   }

//   /// 🔐 Helper: Authenticated POST
//   static Future<http.Response> _authenticatedPost(
//       String url, Map<String, dynamic> body) async {
//     await loadTokens();

//     var response = await http.post(
//       Uri.parse(url),
//       headers: {
//         "Authorization": "Bearer $_accessToken",
//         "Content-Type": "application/json",
//       },
//       body: jsonEncode(body),
//     );

//     if (response.statusCode == 401 && _refreshToken != null) {
//       final refreshRes = await http.post(
//         Uri.parse("$baseUrl/api/doctor/refresh"),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({"refreshToken": _refreshToken}),
//       );

//       if (refreshRes.statusCode == 200) {
//         final newAccessToken = jsonDecode(refreshRes.body)["accessToken"];
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString("access_token", newAccessToken);

//         response = await http.post(
//           Uri.parse(url),
//           headers: {
//             "Authorization": "Bearer $newAccessToken",
//             "Content-Type": "application/json",
//           },
//           body: jsonEncode(body),
//         );
//       } else {
//         await _logout();
//       }
//     }

//     return response;
//   }
// /// 🔐 Helper: Authenticated PUT
// static Future<http.Response> _authenticatedPut(
//     String url, Map<String, dynamic> body) async {
  
//    await loadTokens();
  
 

//   var response = await http.put(
//     Uri.parse(url),
//     headers: {
//       "Authorization": "Bearer $_accessToken",
//       "Content-Type": "application/json",
//     },
//     body: jsonEncode(body),
//   );

//   // 🔁 handle expired token
//   if (response.statusCode == 401 && _refreshToken != null) {
//     final refreshRes = await http.post(
//       Uri.parse("$baseUrl/api/doctor/refresh"),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({"refreshToken": _refreshToken}),
//     );

//     if (refreshRes.statusCode == 200) {
//       final newAccessToken = jsonDecode(refreshRes.body)["accessToken"];
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString("access_token", newAccessToken);

//       response = await http.put(
//         Uri.parse(url),
//         headers: {
//           "Authorization": "Bearer $newAccessToken",
//           "Content-Type": "application/json",
//         },
//         body: jsonEncode(body),
//       );
//     } else {
//       await _logout();
//     }
//   }

//   return response;
// }


// static Future<void> storeFeedbackBeforeUninstall( String feedback) async {
// try {
// final response = await _authenticatedPost(
//       "$baseUrl/api/feedback",
//        {'feedbackText': feedback}, // no body needed, just empty JSON
//     );

//   if (response.statusCode == 201) {
//     debugPrint("✅ Feedback stored successfully");
//   } else {
//     debugPrint("❌ Failed to store feedback: ${response.body}");
//   }
//   } catch (e) {
//     print("Error incrementing prescription count: $e");
   
//   }
// }

// Future<bool> resetPassword(String doctorEmailId, String newPassword) async {
//   final url = Uri.parse("$baseUrl/api/doctor/reset-password");
//   final response = await http.post(
//     url,
//     headers: {"Content-Type": "application/json"},
//     body: jsonEncode({
//       "loginEmail": doctorEmailId,
//       "newPassword": newPassword,
//     }),
//   );

//   return response.statusCode == 200;
// }


// static Future<int?> incrementPrescriptionCount() async {
//   try {
    
//     final response = await _authenticatedPut(
//       "$baseUrl/api/doctor/increment-prescription",
//       {}, // no body needed, just empty JSON
//     );
 
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);

//       //saving to shared Pref 
//       final prefs = await SharedPreferences.getInstance();
//        // Optionally also cache doctor profile locally
//     if (data["doctor"] != null) {
//       await prefs.setString("doctor_profile", jsonEncode(data["doctor"]));
//     }
 
//       return data["prescriptionCount"] as int;
//     } else {
//       print("Failed to increment prescription count: ${response.statusCode}");
//       return null;
//     }
//   } catch (e) {
//     print("Error incrementing prescription count: $e");
//     return null;
//   }
// }


// static String? lastErrorMessage;
//   /// ✅ Register doctor (no auth needed)
//   static  Future<Map<String, dynamic>> registerDoctorOnServer(DoctorInfo info) async {
//     try
//     {
  
    

//     final response = await http.post(
//       Uri.parse('$baseUrl/api/doctor/register'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode(info.toJson()),
//     );

// final data = jsonDecode(response.body);

//     if (response.statusCode == 201) {
//       lastErrorMessage = null; 

//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString("access_token", data["accessToken"]);
//     await prefs.setString("refresh_token", data["refreshToken"]);
//     await prefs.setString("doctor_name", data["doctor"]["name"]);

//     // Optionally also cache doctor profile locally
//     if (data["doctor"] != null) {
//       await prefs.setString("doctor_profile", jsonEncode(data["doctor"]));
//     }
    
// }
//       String     msg = "message" ;
//       if (response.statusCode == 400)
//       {
//         msg= "error";
//       }
      
//      lastErrorMessage = data[msg] ?? "Unknown error"; // 👈 save backend msg
//        return {
//       "success": response.statusCode == 201,
//       "message": data[msg] ?? "Unknown error"
//     };
//   //   else {
//   //   print("❌ Registration failed: ${response.statusCode} ${response.body}");
//   //   return false;
//   // }
//     }
//     catch(e)
//     {
//       lastErrorMessage = "Network error. Please try again.";
//       return {
//       "success": false,
//       "message": "Network error. Please try again."
//     };
//     }
//   }


  

// // /// ✅ Update doctor info
// // static Future<bool> updateDoctorOnServer(DoctorInfo info) async {
// //   print ("Before calling _authenticatedPut");
// //   final response = await _authenticatedPut(
// //     "$baseUrl/api/doctor/update",
// //     info.toJson(),
// //   );
// //   print ("after calling _authenticatedPut");
  
// //   final prefs = await SharedPreferences.getInstance();
// //   final doctorData = await fetchDoctorProfile();
  
// //   if (doctorData != null) {
    
// //      await prefs.setString("doctor_profile", jsonEncode(doctorData["doctor"]));
// //   }
  
// //   return response.statusCode == 200;
// // }

// static Future<bool> updateDoctorOnServer(DoctorInfo info) async {
  

//   http.Response? response;

//   try {
//     response = await _authenticatedPut(
//       "$baseUrl/api/doctor/update",
//       info.toJson(),
//     );
//   } catch (e, s) {
//     print("🔥 ERROR inside _authenticatedPut:");
//     print(e);
//     print(s);
//     return false;
//   }

  

//   final prefs = await SharedPreferences.getInstance();
//   final doctorData = await fetchDoctorProfile();

//   if (doctorData != null) {
//     await prefs.setString("doctor_profile", jsonEncode(doctorData["doctor"]));
//   }

//   return response.statusCode == 200;
// }


//   /// ✅ Login doctor
//   static Future<Map<String, String>?> loginDoctor(String loginEmail, String password) async {

//     try {

//     final response = await http.post(
//       Uri.parse("$baseUrl/api/doctor/login"),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({"loginEmail": loginEmail, "password": password}),
//     );

//      if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         _accessToken = data["accessToken"];
//         _refreshToken = data["refreshToken"];

        
//           final prefs = await SharedPreferences.getInstance();

//           if (_accessToken != null && _refreshToken != null) {
//           await prefs.setString("access_token", _accessToken!);
//           await prefs.setString("refresh_token", _refreshToken!);
//           }
//           await prefs.setString("doctor_name", data["doctor"]["name"]);
          
          
//           await prefs.setString("doctor_profile", jsonEncode(data["doctor"]));

           
          
//           return {
//             "accessToken": _accessToken!,
//             "refreshToken": _refreshToken!,
//           };
//         } 
      
      
//     } catch (e) {
//       print("Login error: $e");
//       await AppLogger.log("Login error: $e");
//     }
//     return null;
//   }

//   /// ✅ Fetch current doctor
//   static Future<DoctorInfo?> fetchCurrentDoctor() async {
//     final response = await _authenticatedGet("$baseUrl/api/doctor/me");

//     if (response.statusCode == 200) {
//       return DoctorInfo.fromJson(jsonDecode(response.body));
//     } else if (response.statusCode == 401) {
//       await _logout();
//     }
//     return null;
//   }



// static Future<Map<String, dynamic>?> fetchDoctorProfile() async {
//   try {
//     final response = await _authenticatedGet("$baseUrl/api/doctor/me");

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body) as Map<String, dynamic>;
//     } else if (response.statusCode == 401) {
//       // This means refresh also failed
//       print("⛔ Unauthorized: token expired and refresh failed");
//       return null;
//     } else {
//       print("❌ Failed to fetch profile: ${response.statusCode} ${response.body}");
//       return null;
//     }
//   } catch (e) {
//     print("⚠️ Error in fetchDoctorProfile: $e");
//     return null;
//   }
// }




//   // // /// ✅ Fetch doctor by ID (if needed)
//   // // static Future<DoctorInfo?> fetchRegisteredDoctor() async {
//   // //   final response = await _authenticatedGet("$baseUrl/api/doctor/current");

//   // //   if (response.statusCode == 200) {
//   // //     return DoctorInfo.fromJson(jsonDecode(response.body));
//   // //   }
//   // //   return null;
//   // // }

//   // // /// ✅ Activate license
//   // // static Future<bool> activateLicense(String email, String licenseKey) async {
//   // //   final response = await _authenticatedPost(
//   // //     "$baseUrl/api/license/activate-license",
//   // //     {'email': email, 'licenseKey': licenseKey},
//   // //   );
//   // //   return response.statusCode == 200 &&
//   // //       jsonDecode(response.body)['success'] == true;
//   // // }

//   // /// ✅ Check license
//   // // static Future<Map<String, dynamic>> checkLicense(String email) async {
//   // //   final response = await _authenticatedPost(
//   // //     "$baseUrl/license/check-license",
//   // //     {'email': email},
//   // //   );

//   // //   if (response.statusCode == 200) {
//   // //     return jsonDecode(response.body);
//   // //   }
//   // //   return {'isLicensed': false, 'pdfCount': 0};
//   // // }

//   // // /// ✅ Increment PDF usage
//   // // static Future<bool> incrementPdfCount(String email) async {
//   // //   final response = await _authenticatedPost(
//   // //     "$baseUrl/license/increment-pdf",
//   // //     {'email': email},
//   // //   );
//   // //   return response.statusCode == 200 &&
//   // //       jsonDecode(response.body)['success'] == true;
//   // // }

//   // /// ✅ Verify token
//   static Future<bool> verifyToken(String accessToken) async {
//     try 
//     {
//     final response = await http.get(
//       Uri.parse('$baseUrl/api/doctor/me'),
//       headers: {
//         'Authorization': 'Bearer $accessToken',
//         'Content-Type': 'application/json',
//       },
//     );
    
//     if (response.statusCode == 200) {
//         return true;
//       } else if (response.statusCode == 401) {
//         // Access token expired → try refreshing
//         final prefs = await SharedPreferences.getInstance();
//         final refreshToken = prefs.getString("refresh_token");

//         if (refreshToken != null) {
//           final newAccessToken = await refreshAccessToken(refreshToken);
//           if (newAccessToken != null) {
//             // Retry verification with new token
//             return await verifyToken(newAccessToken);
//           }
//         }
//       }
//       return false;
//     } catch (e) {
//       return false;
//     }
//   }
// /// Refresh the access token using refresh token
//   static Future<String?> refreshAccessToken(String refreshToken) async {
//     try {
//       final response = await http.post(
//         Uri.parse("$baseUrl/api/doctor/refresh"),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({"refreshToken": refreshToken}),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final newAccessToken = data["accessToken"];

//         // save new access token
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString("access_token", newAccessToken);

//         return newAccessToken;
//       } else {
//         return null;
//       }
//     } catch (e) {
//       return null;
//     }
//   }

//   static Future<void> loadTokens() async {
//     final prefs = await SharedPreferences.getInstance();
//     _accessToken = prefs.getString("access_token");
//     _refreshToken = prefs.getString("refresh_token");
//   }

//   /// ✅ Validate stored token
//   static Future<bool> isTokenValid(String token) async {
//     final response = await http.post(
//       Uri.parse("$baseUrl/api/doctor/validate-token"),
//       headers: {
//         "Content-Type": "application/json",
//         "Authorization": "Bearer $token",
//       },
//     );

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body)["valid"] == true;
//     }
//     return false;
//   }

//   /// ✅ Logout
//   static Future<void> _logout() async {
//      _accessToken = null;
//     _refreshToken = null;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove("access_token");
//   await prefs.remove("refresh_token");
//     await prefs.clear();
//   }

//   static Future<void> logoutDoctor() async => _logout();

// /// ------------------------
//   /// TRIAL MANAGEMENT
//   /// ------------------------
// /// Get trial status: { isTrialActive, prescriptionCount, trialEndDate }
//   static Future<Map<String, dynamic>?> getTrialStatus() async {
//     final response = await _authenticatedGet("$baseUrl/api/trial/status");
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     }
//     return null;
//   }

//   /// ------------------------
//   /// SUBSCRIPTION MANAGEMENT
//   /// ------------------------

//   /// Get subscription status: { isSubscribed, expiryDate, productId }
//   static Future<Map<String, dynamic>?> getSubscriptionStatus() async {
//     final response =
//         await _authenticatedGet("$baseUrl/api/subscription/status");
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     }
//     return null;
//   }

//   /// Record subscription purchase
//   static Future<bool> activateSubscription(
//       String productId, String transactionId, DateTime expiryDate,String platform,String receiptData) async {
//     final response = await _authenticatedPost(
//       "$baseUrl/api/subscription/activate",
//       {
//         "productId": productId,
//         "transactionId": transactionId,
//         "expiryDate": expiryDate.toIso8601String(),
//         "platform":platform,
//         "receiptData":receiptData,
//       },
//     );
//     return response.statusCode == 200;
//   }

  

// }

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:docautomations/network/dio_client.dart';
import 'package:docautomations/services/logger_service.dart';
import 'package:docautomations/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:docautomations/widgets/doctorinfo.dart';

class LicenseApiService {
  static const String baseUrl = "https://license-server-0zfe.onrender.com";


 static String? _accessToken;
 static String? _refreshToken;


  


static Future<void> storeFeedbackBeforeUninstall(String feedback) async {
  try {
    await DioClient.instance.post(
      '/api/feedback',
      data: {'feedbackText': feedback},
    );
  } catch (e, s) {
    await LoggerService.error(
      'Feedback submission failed',
      error: e,
      stack: s,
    );
  }
}

static Future<void> warmUpBackend() async {
  try {
    await DioClient.instance.get(
      '/api/doctor/health',
      options: Options(
        receiveTimeout: const Duration(seconds: 45),
      ),
    );
  } catch (_) {
    // ❗ Never block splash for warm-up failure
    // Login will still retry later
  }
}


Future<bool> resetPassword(String doctorEmailId, String newPassword) async {
  try {
    final response = await DioClient.instance.post(
      '/api/doctor/reset-password',
      data: {
        'loginEmail': doctorEmailId,
        'newPassword': newPassword,
      },
    );

    return response.statusCode == 200;
  } catch (e, s) {
    await LoggerService.error(
      'Reset password failed',
      error: e,
      stack: s,
    );
    return false;
  }
}



static Future<int?> incrementPrescriptionCount() async {
  try {
    final response = await DioClient.instance.put(
      '/api/doctor/increment-prescription',
    );

    if (response.statusCode == 200) {
      final data = response.data;

      // Cache updated doctor profile locally
      final prefs = await SharedPreferences.getInstance();
      if (data["doctor"] != null) {
        await prefs.setString(
          "doctor_profile",
          jsonEncode(data["doctor"]),
        );
      }

      return data["prescriptionCount"] as int;
    } else {
      await LoggerService.error(
        'Failed to increment prescription count',
        error: response.data,
      );
      return null;
    }
  } catch (e, s) {
    await LoggerService.error(
      'Error incrementing prescription count',
      error: e,
      stack: s,
    );
    return null;
  }
}


static String? lastErrorMessage;

/// ✅ Register doctor (no auth needed)
static Future<Map<String, dynamic>> registerDoctorOnServer(
    DoctorInfo info) async {
  try {
    final response = await DioClient.instance.post(
      '/api/doctor/register',
      data: info.toJson(),
    );

    final data = response.data;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("access_token", data["accessToken"]);
    await prefs.setString("refresh_token", data["refreshToken"]);
    await prefs.setString("doctor_name", data["doctor"]["name"]);
    await prefs.setString(
      "doctor_profile",
      jsonEncode(data["doctor"]),
    );

    lastErrorMessage = null;

    return {
      "success": true,
      "message": "Registered successfully",
    };
  } 
    catch (e, s) {
    String message = "Registration failed" ;

    if (e is DioException && e.response?.data != null) {
      // 🔥 Extract backend message (IMPORTANT)
      final responseData = e.response!.data;

      if (responseData is Map<String, dynamic>) {

        message = responseData["message"] ?? message;

      }
    }

  else
  {

    await LoggerService.error(
      'Doctor registration failed',
      error: e,
      stack: s,
    );
  }
  lastErrorMessage = message;
    return {
      "success": false,
      "message": message,
    };
  }
}

//static String? lastErrorMessage;
  // /// ✅ Register doctor (no auth needed)
  // static  Future<Map<String, dynamic>> registerDoctorOnServer(DoctorInfo info) async {
  //   try
  //   {
  
    

  //   // final response = await http.post(
  //   //   Uri.parse('$baseUrl/api/doctor/register'),
  //   //   headers: {'Content-Type': 'application/json'},
  //   //   body: jsonEncode(info.toJson()),
  //   // );

  //    final response = await DioClient.instance.post(
  //     '/api/doctor/register',
  //     data: info.toJson(),
  //   );

  //   final data = response.data;

  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString("access_token", data["accessToken"]);
  //   await prefs.setString("refresh_token", data["refreshToken"]);
  //   await prefs.setString("doctor_name", data["doctor"]["name"]);
  //   await prefs.setString("doctor_profile", jsonEncode(data["doctor"]));
    
  //   return {"success": true, "message": "Registered successfully"};
  // }
  //    catch (e) {
  //   return {"success": false, "message": "Registration failed"};
  // }
  // }


  



static Future<bool> updateDoctorOnServer(DoctorInfo info) async {
  try {
    await DioClient.instance.put(
      '/api/doctor/update',
      data: info.toJson(),
    );

    // Re-fetch updated doctor profile
    final prefs = await SharedPreferences.getInstance();
    final doctorData = await fetchDoctorProfile();

    if (doctorData != null) {
      await prefs.setString(
        "doctor_profile",
        jsonEncode(doctorData["doctor"]),
      );
    }

    return true;
  } catch (e, s) {
    await LoggerService.error(
      'Failed to update doctor on server',
      error: e,
      stack: s,
    );
    return false;
  }
}


  /// ✅ Login doctor (DioClient)
static Future<Map<String, String>?> loginDoctor(
  String loginEmail,
  String password,
) async {
  try {
    final response = await DioClient.instance.post(
      '/api/doctor/login',
      data: {
        "loginEmail": loginEmail,
        "password": password,
      },
      options: Options(
    receiveTimeout: const Duration(seconds: 45),),
    );

    final data = response.data;

    _accessToken = data["accessToken"];
    _refreshToken = data["refreshToken"];

    final prefs = await SharedPreferences.getInstance();

    if (_accessToken != null && _refreshToken != null) {
      await prefs.setString("access_token", _accessToken!);
      await prefs.setString("refresh_token", _refreshToken!);
    }

    await prefs.setString("doctor_name", data["doctor"]["name"]);
    await prefs.setString(
      "doctor_profile",
      jsonEncode(data["doctor"]),
    );

    return {
      "accessToken": _accessToken!,
      "refreshToken": _refreshToken!,
    };
  } catch (e, s) {
     String message = "Login failed";

     if (e is DioException) {
    if (e.type == DioExceptionType.receiveTimeout) {
      message = "Server is taking longer than usual. Please try again.";
    } else if (e.response?.data != null) {
      message = e.response!.data["message"] ?? message;
    }
  }

    await LoggerService.error(
      'Doctor login failed',
      error: e,
      stack: s,
    );
    return null;
  }
}


  /// ✅ Fetch current doctor (DioClient)
static Future<DoctorInfo?> fetchCurrentDoctor() async {
  try {
    final response = await DioClient.instance.get('/api/doctor/me');

    return DoctorInfo.fromJson(response.data);
  } catch (e, s) {
    // If refresh also failed, interceptor will land here
    await LoggerService.error(
      'Failed to fetch current doctor',
      error: e,
      stack: s,
    );

    // Optional: logout on auth failure
    if (e is DioException && e.response?.statusCode == 401) {
      await _logout();
    }

    return null;
  }
}




/// ✅ Fetch doctor profile (DioClient)
static Future<Map<String, dynamic>?> fetchDoctorProfile() async {
  try {
    final response = await DioClient.instance.get('/api/doctor/me');

    return response.data as Map<String, dynamic>;
  } catch (e, s) {
    // If refresh also failed, it will land here
    await LoggerService.error(
      'Failed to fetch doctor profile',
      error: e,
      stack: s,
    );

    // Optional: logout if auth is invalid
    if (e is DioException && e.response?.statusCode == 401) {
      await _logout();
    }

    return null;
  }
}


  // /// ✅ Verify token
/// ✅ Verify access token (DioClient)
static Future<bool> verifyToken() async {
  try {
    // If token is valid, this succeeds
    await DioClient.instance.get('/api/doctor/me');
    return true;
  } catch (e, s) {
    if (e is DioException &&
      e.error is SocketException) {
    // Network not available
    return false; // stay on login
  }
    await LoggerService.error(
      'Token verification failed',
      error: e,
      stack: s,
    );
    return false;
  }
}

/// 🔁 Refresh the access token using refresh token (DioClient-compliant)
static Future<String?> refreshAccessToken(String refreshToken) async {
  try {
    // Use a plain Dio call WITHOUT auth header injection
    final response = await DioClient.instance.post(
      '/api/doctor/refresh',
      data: {
        'refreshToken': refreshToken,
      },
      options: Options(
        headers: {
          // Ensure old Authorization header is NOT sent
          'Authorization': null,
        },
      ),
    );

    final newAccessToken = response.data['accessToken'];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', newAccessToken);

    return newAccessToken;
  } catch (e, s) {
    await LoggerService.error(
      'Failed to refresh access token',
      error: e,
      stack: s,
    );
    return null;
  }
}


  static Future<void> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString("access_token");
    _refreshToken = prefs.getString("refresh_token");
  }

  /// ✅ Validate stored token (DioClient)
static Future<bool> isTokenValid(String token) async {
  try {
    final response = await DioClient.instance.post(
      '/api/doctor/validate-token',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return response.data['valid'] == true;
  } catch (e, s) {
    await LoggerService.error(
      'Token validation failed',
      error: e,
      stack: s,
    );
    return false;
  }
}


  /// ✅ Logout
  static Future<void> _logout() async {
     _accessToken = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("access_token");
  await prefs.remove("refresh_token");
    await prefs.clear();
  }

  static Future<void> logoutDoctor() async => _logout();

/// ------------------------
/// TRIAL MANAGEMENT
/// ------------------------
/// Get trial status: { isTrialActive, prescriptionCount, trialEndDate }
static Future<Map<String, dynamic>?> getTrialStatus() async {
  try {
    final response = await DioClient.instance.get('/api/trial/status');

    return response.data as Map<String, dynamic>;
  } catch (e, s) {
    await LoggerService.error(
      'Failed to fetch trial status',
      error: e,
      stack: s,
    );
    return null;
  }
}

/// ------------------------
/// SUBSCRIPTION MANAGEMENT
/// ------------------------
/// Get subscription status: { isSubscribed, expiryDate, productId }
static Future<Map<String, dynamic>?> getSubscriptionStatus() async {
  try {
    final response =
        await DioClient.instance.get('/api/subscription/status');

    return response.data as Map<String, dynamic>;
  } catch (e, s) {
    await LoggerService.error(
      'Failed to fetch subscription status',
      error: e,
      stack: s,
    );
    return null;
  }
}


/// Record subscription purchase (DioClient)
static Future<bool> activateSubscription(
  String productId,
  String transactionId,
  DateTime expiryDate,
  String platform,
  String receiptData,
) async {
  try {
    await DioClient.instance.post(
      '/api/subscription/activate',
      data: {
        "productId": productId,
        "transactionId": transactionId,
        "expiryDate": expiryDate.toIso8601String(),
        "platform": platform,
        "receiptData": receiptData,
      },
    );

    // If we reach here, request succeeded (2xx)
    return true;
  } catch (e, s) {
    await LoggerService.error(
      'Failed to activate subscription',
      error: e,
      stack: s,
    );
    return false;
  }
}


  

}

