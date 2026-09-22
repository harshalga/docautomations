


// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:dio/dio.dart';
// import 'package:docautomations/common/operation_result.dart';
// import 'package:docautomations/datamodels/master/country.dart';
// import 'package:docautomations/datamodels/request/doctor_registration_request.dart';
// import 'package:docautomations/datamodels/response/doctor_profile.dart';
// import 'package:docautomations/network/dio_client.dart';
// import 'package:docautomations/services/auth_service.dart';
// import 'package:docautomations/services/logger_service.dart';
// import 'package:docautomations/utils/activation_result.dart';
// import 'package:docautomations/utils/app_config.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:docautomations/widgets/doctorinfo.dart';

// class DoctorApiService {
//   //"https://license-server-0zfe.onrender.com";
//   static const String baseUrl =  AppConfig.baseUrl;  


//  static String? _accessToken;
//  static String? _refreshToken;


//   static Future<T?> _safeRequest<T>(
//   Future<Response> request,
//   T Function(dynamic data) parser,
// ) async {
//   try {
//     final response = await request;
//     return parser(response.data);
//   } catch (e, s) {
//     await LoggerService.error(
//       "API request failed",
//       error: e,
//       stack: s,
//     );
//     return null;
//   }
// }


// static Future<void> storeFeedbackBeforeUninstall(String feedback) async {
//   return _safeRequest(
//     DioClient.instance.post(
//       '/api/feedback',
//       data: {'feedbackText': feedback},
//     ),
//     (_) {}, // We don't care about the response for feedback
//   );
  
// }





// static Future<bool> checkBackendHealth() async {
//     final result = await _safeRequest(
//       DioClient.instance.get('/api/doctor/health'),
//       (_) => true, // If we get any response, consider it healthy
//     ); 
//       return result ?? false;

  
// }




// Future<bool> resetPassword(String doctorEmailId, String newPassword) async {
//   try {
//     final response = await DioClient.instance.post(
//       '/api/doctor/reset-password',
//       data: {
//         'loginEmail': doctorEmailId,
//         'newPassword': newPassword,
//       },
//     );

//     return response.statusCode == 200;
//   } catch (e, s) {
//     await LoggerService.error(
//       'Reset password failed',
//       error: e,
//       stack: s,
//     );
//     return false;
//   }
// }



// static Future<int?> incrementPrescriptionCount() async {
//   try {
//     final response = await DioClient.instance.put(
//       '/api/doctor/increment-prescription',
//     );

//     if (response.statusCode == 200) {
//       final data = response.data;

//       // Cache updated doctor profile locally
//       final prefs = await SharedPreferences.getInstance();
//       if (data["doctor"] != null) {
//         await prefs.setString(
//           "doctor_profile",
//           jsonEncode(data["doctor"]),
//         );
//       }

//       return data["prescriptionCount"] as int;
//     } else {
//       await LoggerService.error(
//         'Failed to increment prescription count',
//         error: response.data,
//       );
//       return null;
//     }
//   } catch (e, s) {
//     await LoggerService.error(
//       'Error incrementing prescription count',
//       error: e,
//       stack: s,
//     );
//     return null;
//   }
// }


// static String? lastErrorMessage;


// Future<OperationResult> registerDoctor(
//   DoctorRegistrationRequest request,
// ) async {
//   try {
//     final response = await DioClient.instance.post(
//       '/api/doctor/registerdoctor',
//       data: request.toJson(),
//     );

//     if (response.data["success"] == true) {
//       return OperationResult.success(
//         response.data["message"] ?? "Registration successful.",
//       );
//     }

//     return OperationResult.failure(
//       response.data["message"] ?? "Registration failed.",
//     );
//   } catch (e, s) {
//     await LoggerService.error(
//       'Doctor registration failed.',
//       error: e,
//       stack: s,
//     );

//     if (e is DioException) {
//       final data = e.response?.data;

//       if (data is Map<String, dynamic>) {
//         return OperationResult.failure(
//           data["message"] ??
//               "Unable to register doctor.",
//         );
//       }
//     }

//     return OperationResult.failure(
//       "Unable to register doctor.",
//     );
//   }
// }

// /// ✅ Register doctor (no auth needed)
// static Future<Map<String, dynamic>> registerDoctorOnServer(
//     DoctorInfo info) async {
//   try {
//     final response = await DioClient.instance.post(
//       '/api/doctor/register',
//       data: info.toJson(),
//     );

//     final data = response.data;

//     await AuthService.saveTokens(
//   accessToken: data["accessToken"],
//   refreshToken: data["refreshToken"],
// );

//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString("access_token", data["accessToken"]);
//     await prefs.setString("refresh_token", data["refreshToken"]);
//     await prefs.setString("doctor_name", data["doctor"]["name"]);
//     await prefs.setString(
//       "doctor_profile",
//       jsonEncode(data["doctor"]),
//     );

//     lastErrorMessage = null;

//     return {
//       "success": true,
//       "message": "Registered successfully",
//     };
//   } 
//     catch (e, s) {
//     String message = "Registration failed" ;

//     if (e is DioException && e.response?.data != null) {
//       // 🔥 Extract backend message (IMPORTANT)
//       final responseData = e.response!.data;

//       if (responseData is Map<String, dynamic>) {

//         message = responseData["message"] ?? message;

//       }
//     }

//   else
//   {

//     await LoggerService.error(
//       'Doctor registration failed',
//       error: e,
//       stack: s,
//     );
//   }
//   lastErrorMessage = message;
//     return {
//       "success": false,
//       "message": message,
//     };
//   }
// }




  

// static Future<bool> isEmailAlreadyRegistered(String email) async {
//   try {
//     final res = await DioClient.instance.get(
//       "/api/doctor/check-email",
//       queryParameters: {
//         "email": email.trim().toLowerCase(),
//       },
//     );

//     final data = res.data;

//     if (data == null) return false;

//     return data["exists"] ?? false;
//   } catch (e) {
//     debugPrint("Email check failed: $e");
//     return false;
//   }
// }



// static Future<bool> updateDoctorOnServer(DoctorInfo info) async {
//   try {
//     await DioClient.instance.put(
//       '/api/doctor/update',
//       data: info.toJson(),
//     );

//     // Re-fetch updated doctor profile
//     final prefs = await SharedPreferences.getInstance();
//     final doctorData = await fetchDoctorProfile();

//     if (doctorData != null) {
//       await prefs.setString(
//         "doctor_profile",
//         jsonEncode(doctorData["doctor"]),
//       );
//     }

//     return true;
//   } catch (e, s) {
//     await LoggerService.error(
//       'Failed to update doctor on server',
//       error: e,
//       stack: s,
//     );
//     return false;
//   }
// }


//   /// ✅ Login doctor (DioClient)
// static Future<Map<String, String>?> loginDoctor(
//   String loginEmail,
//   String password,
// ) async {
//   try {
//     final response = await DioClient.instance.post(
//       '/api/doctor/login',
//       data: {
//         "loginEmail": loginEmail,
//         "password": password,
//       },
//       options: Options(
//     receiveTimeout: const Duration(seconds: 45),),
//     );

//     final data = response.data;

//     _accessToken = data["accessToken"];
//     _refreshToken = data["refreshToken"];

//     final prefs = await SharedPreferences.getInstance();

//     if (_accessToken != null && _refreshToken != null) {
//       await prefs.setString("access_token", _accessToken!);
//       await prefs.setString("refresh_token", _refreshToken!);

//       await AuthService.saveTokens(
//   accessToken: data["accessToken"],
//   refreshToken: data["refreshToken"],
//             );
//     }

//     await prefs.setString("doctor_name", data["doctor"]["name"]);
//     await prefs.setString(
//       "doctor_profile",
//       jsonEncode(data["doctor"]),
//     );

//     return {
//       "accessToken": _accessToken!,
//       "refreshToken": _refreshToken!,
//     };
//   } catch (e, s) {
//      String message = "Login failed";

//      if (e is DioException) {
//     if (e.type == DioExceptionType.receiveTimeout) {
//       message = "Server is taking longer than usual. Please try again.";
//     } else if (e.response?.data != null) {
//       message = e.response!.data["message"] ?? message;
//     }
//   }

//     await LoggerService.error(
//       'Doctor login failed',
//       error: e,
//       stack: s,
//     );
//     return null;
//   }
// }


// static Future<Uint8List?> fetchDoctorLogo() async {
//   try {
    
//  final response = await DioClient.instance.get('/api/doctor/logo' ,
//       options: Options(
//         responseType: ResponseType.bytes,
//       ),
//     );
    

//     if (response.statusCode == 200) {
//       return Uint8List.fromList(response.data as List<int>);
//     }

//     return null;
//   } catch (e,s) {
//     await LoggerService.error(
//       'Failed to fetch doctor logo',
//       error: e,
//       stack: s,
//     );

//     return null;
//   }
// }

//   /// ✅ Fetch current doctor (DioClient)
// static Future<DoctorInfo?> fetchCurrentDoctor() async {
//   try {
//     final response = await DioClient.instance.get('/api/doctor/me');

//     return DoctorInfo.fromJson(response.data);
//   } catch (e, s) {
//     // If refresh also failed, interceptor will land here
//     await LoggerService.error(
//       'Failed to fetch current doctor',
//       error: e,
//       stack: s,
//     );

//     // Optional: logout on auth failure
//     if (e is DioException && e.response?.statusCode == 401) {
//       await _logout();
//     }

//     return null;
//   }
// }


// Future<List<Country>> fetchCountriesFromServer() async {
//   try {
//     final response = await DioClient.instance.get(
//       '/api/doctor/countries',
//     );

//     if (response.data == null) {
//       return [];
//     }

//     final List<dynamic> countriesJson =
//         response.data["data"] as List<dynamic>;

//     return countriesJson
//         .map(
//           (json) => Country.fromJson(
//             json as Map<String, dynamic>,
//           ),
//         )
//         .toList();
//   } catch (e, s) {
//     await LoggerService.error(
//       'Failed to fetch countries',
//       error: e,
//       stack: s,
//     );

//     if (e is DioException &&
//         e.response?.statusCode == 401) {
//       await _logout();
//     }

//     return [];
//   }
// }

// Future<List<int>> downloadDoctorLogo() async {
//   try {
//     final response = await DioClient.instance.get(
//       '/api/doctor/logo',
//       options: Options(
//         responseType: ResponseType.bytes,
//       ),
//     );

//     return List<int>.from(response.data);
//   } catch (e, s) {
//     await LoggerService.error(
//       'Failed to download doctor logo.',
//       error: e,
//       stack: s,
//     );

//     if (e is DioException &&
//         e.response?.statusCode == 401) {
//       await _logout();
//     }

//     rethrow;
//   }
// }

// Future<List<int>> downloadDoctorSignature() async {
//   try {
//     final response = await DioClient.instance.get(
//       '/api/doctor/signature',
//       options: Options(
//         responseType: ResponseType.bytes,
//       ),
//     );

//     return List<int>.from(response.data);
//   } catch (e, s) {
//     await LoggerService.error(
//       'Failed to download doctor signature.',
//       error: e,
//       stack: s,
//     );

//     if (e is DioException &&
//         e.response?.statusCode == 401) {
//       await _logout();
//     }

//     rethrow;
//   }
// }

// Future<DoctorProfile> fetchDoctorProfileFromServer() async {
//   try {
//     final response = await DioClient.instance.get(
//       '/api/doctor/getDoctorProfile',
//     );

//     if (response.data == null) {
//       return null;
//     }

//     return DoctorProfile.fromJson(
//       response.data["data"]  as Map<String, dynamic>,
//     );
//   } catch (e, s) {
//     await LoggerService.error(
//       'Failed to fetch doctor profile',
//       error: e,
//       stack: s,
//     );

//     if (e is DioException &&
//         e.response?.statusCode == 401) {
//       await _logout();
//     }

//     return null;
//   }
// }



// /// ✅ Fetch doctor profile (DioClient)
// static Future<Map<String, dynamic>?> fetchDoctorProfile() async {
//   try {
//     final response = await DioClient.instance.get('/api/doctor/me');

//     return response.data as Map<String, dynamic>;
//   } catch (e, s) {
//     // If refresh also failed, it will land here
//     await LoggerService.error(
//       'Failed to fetch doctor profile',
//       error: e,
//       stack: s,
//     );

//     // Optional: logout if auth is invalid
//     if (e is DioException && e.response?.statusCode == 401) {
//       await _logout();
//     }

//     return null;
//   }
// }


//   // /// ✅ Verify token
// /// ✅ Verify access token (DioClient)
// static Future<bool> verifyToken() async {
//   try {
//     // If token is valid, this succeeds
//     await DioClient.instance.get('/api/doctor/me');
//     return true;
//   } catch (e, s) {
//     if (e is DioException &&
//       e.error is SocketException) {
//     // Network not available
//     return false; // stay on login
//   }
//     await LoggerService.error(
//       'Token verification failed',
//       error: e,
//       stack: s,
//     );
//     return false;
//   }
// }

// /// 🔁 Refresh the access token using refresh token (DioClient-compliant)
// static Future<String?> refreshAccessToken(String refreshToken) async {
//   try {
//     // Use a plain Dio call WITHOUT auth header injection
//     final response = await DioClient.instance.post(
//       '/api/doctor/refresh',
//       data: {
//         'refreshToken': refreshToken,
//       },
//       options: Options(
//         headers: {
//           // Ensure old Authorization header is NOT sent
//           'Authorization': null,
//         },
//       ),
//     );

//     final newAccessToken = response.data['accessToken'];

//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('access_token', newAccessToken);

//     return newAccessToken;
//   } catch (e, s) {
//     await LoggerService.error(
//       'Failed to refresh access token',
//       error: e,
//       stack: s,
//     );
//     return null;
//   }
// }


//   static Future<void> loadTokens() async {
//     final prefs = await SharedPreferences.getInstance();
//     _accessToken = prefs.getString("access_token");
//     _refreshToken = prefs.getString("refresh_token");
//   }

//   /// ✅ Validate stored token (DioClient)
// static Future<bool> isTokenValid(String token) async {
//   try {
//     final response = await DioClient.instance.post(
//       '/api/doctor/validate-token',
//       options: Options(
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       ),
//     );

//     return response.data['valid'] == true;
//   } catch (e, s) {
//     await LoggerService.error(
//       'Token validation failed',
//       error: e,
//       stack: s,
//     );
//     return false;
//   }
// }


//   /// ✅ Logout
//   static Future<void> _logout() async {
//      _accessToken = null;
//     _refreshToken = null;
//       AuthService.logout();
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove("access_token");
//   await prefs.remove("refresh_token");
//     await prefs.clear();
//   }

//   static Future<void> logoutDoctor() async => _logout();

// /// ------------------------
// /// TRIAL MANAGEMENT
// /// ------------------------
// /// Get trial status: { isTrialActive, prescriptionCount, trialEndDate }
// static Future<Map<String, dynamic>?> getTrialStatus() async {
//   try {
//     final response = await DioClient.instance.get('/api/trial/status');

//     return response.data as Map<String, dynamic>;
//   } catch (e, s) {
//     await LoggerService.error(
//       'Failed to fetch trial status',
//       error: e,
//       stack: s,
//     );
//     return null;
//   }
// }

// /// Check whether email is registered
//   static Future<bool> checkEmailExists(String email) async {
//     try {
//       final Response response = await DioClient.instance.post(
//         "/api/doctor/check-email",
//         data: {
//           "email": email.trim(),
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = response.data;

//         if (data is Map<String, dynamic>) {
//           return data["exists"] == true;
//         }
//       }

//       return false;
//     } on DioException catch (e) {
//       print("checkEmailExists Dio error: ${e.message}");
//       return false;
//     } catch (e) {
//       print("checkEmailExists error: $e");
//       return false;
//     }
//   }

// /// ------------------------
// /// SUBSCRIPTION MANAGEMENT
// /// ------------------------
// /// Get subscription status: { isSubscribed, expiryDate, productId }
// static Future<Map<String, dynamic>?> getSubscriptionStatus() async {
//   try {
//     final response =
//         await DioClient.instance.get('/api/subscription/status');

//     //return response.data as Map<String, dynamic>;
//     return response.data ?? {
//       "isSubscribed": false,
//       "expiryDate": null,
//       "productId": null,
//     };
//   } 
//   on DioException catch (e) {

//   print("STATUS CODE: ${e.response?.statusCode}");
//   print("RESPONSE: ${e.response?.data}");
//   print("ERROR: $e");


//   rethrow;
// }
//   catch (e, s) {

//     debugPrint("Subscription status error: $e");

//     await LoggerService.error(
//       'Failed to fetch subscription status',
//       error: e,
//       stack: s,
//     );

//       return {
//     "isSubscribed": false,
//     "expiryDate": null,
//     "productId": null
//   };

// //    return null;
//   }
// }


// /// Record subscription purchase (DioClient)
// static Future<ActivationResult> activateSubscription(
//   String productId,
//   String transactionId,
//   //DateTime expiryDate,
//   String platform,
//   String receiptData,
// ) async {
//   try {
//     print({
//  'productId': productId,
//  'purchaseToken': receiptData,
// });
//    final response = await DioClient.instance.post(
//       '/api/subscription/activate',
//       data: {
//         "productId": productId,
//         "transactionId": transactionId,
//     //    "expiryDate": expiryDate.toIso8601String(),
//         "platform": platform,
//         "receiptData": receiptData,
//       },
//     );
// final subscription = response.data['subscription'];
// final expiryDate = DateTime.parse(
//   subscription['expiryDate'],
// );
// print("🔥 EXPIRY FROM BACKEND: $expiryDate");
//     // If we reach here, request succeeded (2xx)
//     return ActivationResult(
//       success: response.data['success'],
//       expiryDate: expiryDate,
//       productId: productId,
//     );
//   } catch (e, s) {
//     await LoggerService.error(
//       'Failed to activate subscription',
//       error: e,
//       stack: s,
//     );
//     //return false;
//     if (e is DioException) {
//        if (e.response?.statusCode == 401) {
//           return ActivationResult(
//           success: false,
//         );
//         }}
//  rethrow;
//   }
// }


  

// }



import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:docautomations/datamodels/request/doctor_registration_request.dart';
import 'package:docautomations/datamodels/response/doctor_profile.dart';

import 'package:docautomations/network/dio_client.dart';
import 'package:flutter/material.dart';


class DoctorApiService {

  //===========================================================================
  // Dependencies
  //===========================================================================

  final Dio _dio;


  //===========================================================================
  // Constructor
  //===========================================================================

  DoctorApiService({
    Dio? dio,
  }) : _dio =
          dio ?? DioClient.instance;


  //===========================================================================
  // Register Doctor
  //===========================================================================

  Future<Map<String, dynamic>> registerDoctor(
    DoctorRegistrationRequest request,
  ) async {
try
{
    final response =
        await _dio.post(

      "/api/doctors/register",

      data:
          request.toJson(),

    );

    return Map<String, dynamic>.from(
      response.data,
    );
}
on DioException catch (error) {
  debugPrint(
    'Registration status: ${error.response?.statusCode}',
  );

  debugPrint(
    'Registration response: ${error.response?.data}',
  );

  rethrow;
  }
  }


  //===========================================================================
  // Get Doctor Profile
  //===========================================================================

  Future<DoctorProfile> fetchDoctorProfile() async {

    final response =
        await _dio.get(

      "/api/doctors/profile",

    );


debugPrint(
  'PROFILE RESPONSE TYPE: ${response.data.runtimeType}',
);

debugPrint(
  'PROFILE RESPONSE DATA: ${response.data}',
);



    final responseData =
        Map<String, dynamic>.from(
          response.data,
        );


    if (responseData["success"] != true) {

      throw Exception(

        responseData["message"] ??
            "Unable to fetch doctor profile.",

      );

    }


    final data =
        responseData["data"];


    if (data == null) {

      throw Exception(
        "Doctor profile data not found.",
      );

    }

    //TODO: Need to be deleted after testing
      debugPrint(
  'PROFILE DATA KEYS: ${data.keys.toList()}',
);

debugPrint(
  'DOCTOR DATA: ${data['doctor']}',
);
debugPrint(
  'LAYOUT DATA: ${data['layout']}',
);

debugPrint(
  'THEME DATA: ${data['theme']}',
);
debugPrint(
  'ASSETS DATA: ${data['assets']}',
);

    return DoctorProfile.fromJson(

      Map<String, dynamic>.from(
        data,
      ),

    );

  }


  //===========================================================================
  // Update Doctor Profile
  //===========================================================================

  Future<Map<String, dynamic>> updateDoctorProfile(
    Map<String, dynamic> request,
  ) async {

    final response =
        await _dio.put(

      "/api/doctor/profile",

      data:
          request,

    );

    return Map<String, dynamic>.from(
      response.data,
    );

  }


  //===========================================================================
  // Upload Doctor Logo
  //
  // License-server expects JSON:
  //
  // {
  //   "imageData": "<base64>",
  //   "mimeType": "image/png"
  // }
  //
  // No multipart/form-data is used.
  //===========================================================================

  Future<Map<String, dynamic>> uploadDoctorLogo({

    required List<int> bytes,

    required String mimeType,

  }) async {

    final request = {

      "imageData":
          base64Encode(bytes),

      "mimeType":
          mimeType.trim().toLowerCase(),

    };


    final response =
        await _dio.post(

      "/api/doctors/logo",

      data:
          request,

    );


    return Map<String, dynamic>.from(
      response.data,
    );

  }


  //===========================================================================
  // Download Doctor Logo
  //
  // License-server returns JSON containing Base64 image data.
  //
  // The API service decodes the Base64 data and returns raw bytes to the
  // repository/application layer.
  //===========================================================================

  Future<List<int>> downloadDoctorLogo() async {

    final response =
        await _dio.get(

      "/api/doctors/logo",

    );


    final responseData =
        Map<String, dynamic>.from(
          response.data,
        );


    if (responseData["success"] != true) {

      throw Exception(

        responseData["message"] ??
            "Unable to download doctor logo.",

      );

    }


    final data =
        responseData["data"];


    if (data == null) {

      throw Exception(
        "Doctor logo not found.",
      );

    }


    final asset =
        Map<String, dynamic>.from(
          data,
        );


    final imageData =
        asset["imageData"]?.toString();


    if (imageData == null ||
        imageData.isEmpty) {

      throw Exception(
        "Doctor logo image data not found.",
      );

    }


    try {

      return base64Decode(
        imageData,
      );

    } catch (_) {

      throw Exception(
        "Invalid doctor logo image data.",
      );

    }

  }


  //===========================================================================
  // Upload Doctor Signature
  //
  // License-server expects JSON:
  //
  // {
  //   "imageData": "<base64>",
  //   "mimeType": "image/png"
  // }
  //
  // No multipart/form-data is used.
  //===========================================================================

  Future<Map<String, dynamic>> uploadDoctorSignature({

    required List<int> bytes,

    required String mimeType,

  }) async {

    final request = {

      "imageData":
          base64Encode(bytes),

      "mimeType":
          mimeType.trim().toLowerCase(),

    };


    final response =
        await _dio.post(

      "/api/doctors/signature",

      data:
          request,

    );


    return Map<String, dynamic>.from(
      response.data,
    );

  }


  //===========================================================================
  // Download Doctor Signature
  //
  // License-server returns JSON containing Base64 image data.
  //
  // The API service decodes the Base64 data and returns raw bytes to the
  // repository/application layer.
  //===========================================================================

  Future<List<int>> downloadDoctorSignature() async {

    final response =
        await _dio.get(

      "/api/doctors/signature",

    );


    final responseData =
        Map<String, dynamic>.from(
          response.data,
        );


    if (responseData["success"] != true) {

      throw Exception(

        responseData["message"] ??
            "Unable to download doctor signature.",

      );

    }


    final data =
        responseData["data"];


    if (data == null) {

      throw Exception(
        "Doctor signature not found.",
      );

    }


    final asset =
        Map<String, dynamic>.from(
          data,
        );


    final imageData =
        asset["imageData"]?.toString();


    if (imageData == null ||
        imageData.isEmpty) {

      throw Exception(
        "Doctor signature image data not found.",
      );

    }


    try {

      return base64Decode(
        imageData,
      );

    } catch (_) {

      throw Exception(
        "Invalid doctor signature image data.",
      );

    }

  }

}

