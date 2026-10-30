

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

      "/api/doctors/profile",

      data:
          request,

    );

    return Map<String, dynamic>.from(
      response.data,
    );

  }


  // //===========================================================================
  // // Upload Doctor Logo
  // //
  // // License-server expects JSON:
  // //
  // // {
  // //   "imageData": "<base64>",
  // //   "mimeType": "image/png"
  // // }
  // //
  // // No multipart/form-data is used.
  // //===========================================================================

  // Future<Map<String, dynamic>> uploadDoctorLogo({

  //   required List<int> bytes,

  //   required String mimeType,

  // }) async {

  //   final request = {

  //     "imageData":
  //         base64Encode(bytes),

  //     "mimeType":
  //         mimeType.trim().toLowerCase(),

  //   };


  //   final response =
  //       await _dio.post(

  //     "/api/doctors/logo",

  //     data:
  //         request,

  //   );


  //   return Map<String, dynamic>.from(
  //     response.data,
  //   );

  // }


  // //===========================================================================
  // // Download Doctor Logo
  // //
  // // License-server returns JSON containing Base64 image data.
  // //
  // // The API service decodes the Base64 data and returns raw bytes to the
  // // repository/application layer.
  // //===========================================================================

  // Future<List<int>> downloadDoctorLogo() async {

  //   final response =
  //       await _dio.get(

  //     "/api/doctors/logo",

  //   );


  //   final responseData =
  //       Map<String, dynamic>.from(
  //         response.data,
  //       );


  //   if (responseData["success"] != true) {

  //     throw Exception(

  //       responseData["message"] ??
  //           "Unable to download doctor logo.",

  //     );

  //   }


  //   final data =
  //       responseData["data"];


  //   if (data == null) {

  //     throw Exception(
  //       "Doctor logo not found.",
  //     );

  //   }


  //   final asset =
  //       Map<String, dynamic>.from(
  //         data,
  //       );


  //   final imageData =
  //       asset["imageData"]?.toString();


  //   if (imageData == null ||
  //       imageData.isEmpty) {

  //     throw Exception(
  //       "Doctor logo image data not found.",
  //     );

  //   }


  //   try {

  //     return base64Decode(
  //       imageData,
  //     );

  //   } catch (_) {

  //     throw Exception(
  //       "Invalid doctor logo image data.",
  //     );

  //   }

  // }


  // //===========================================================================
  // // Upload Doctor Signature
  // //
  // // License-server expects JSON:
  // //
  // // {
  // //   "imageData": "<base64>",
  // //   "mimeType": "image/png"
  // // }
  // //
  // // No multipart/form-data is used.
  // //===========================================================================

  // Future<Map<String, dynamic>> uploadDoctorSignature({

  //   required List<int> bytes,

  //   required String mimeType,

  // }) async {

  //   final request = {

  //     "imageData":
  //         base64Encode(bytes),

  //     "mimeType":
  //         mimeType.trim().toLowerCase(),

  //   };


  //   final response =
  //       await _dio.post(

  //     "/api/doctors/signature",

  //     data:
  //         request,

  //   );


  //   return Map<String, dynamic>.from(
  //     response.data,
  //   );

  // }


  // //===========================================================================
  // // Download Doctor Signature
  // //
  // // License-server returns JSON containing Base64 image data.
  // //
  // // The API service decodes the Base64 data and returns raw bytes to the
  // // repository/application layer.
  // //===========================================================================

  // Future<List<int>> downloadDoctorSignature() async {

  //   final response =
  //       await _dio.get(

  //     "/api/doctors/signature",

  //   );


  //   final responseData =
  //       Map<String, dynamic>.from(
  //         response.data,
  //       );


  //   if (responseData["success"] != true) {

  //     throw Exception(

  //       responseData["message"] ??
  //           "Unable to download doctor signature.",

  //     );

  //   }


  //   final data =
  //       responseData["data"];


  //   if (data == null) {

  //     throw Exception(
  //       "Doctor signature not found.",
  //     );

  //   }


  //   final asset =
  //       Map<String, dynamic>.from(
  //         data,
  //       );


  //   final imageData =
  //       asset["imageData"]?.toString();


  //   if (imageData == null ||
  //       imageData.isEmpty) {

  //     throw Exception(
  //       "Doctor signature image data not found.",
  //     );

  //   }


  //   try {

  //     return base64Decode(
  //       imageData,
  //     );

  //   } catch (_) {

  //     throw Exception(
  //       "Invalid doctor signature image data.",
  //     );

  //   }

  // }

  //New methods for images .

  
  // ============================================================
  // Doctor Asset API
  // Backend uses multipart uploads and raw image responses.
  // ============================================================

  static const String _logoEndpoint = '/api/doctor-logo';
  static const String _signatureEndpoint = '/api/doctor-signature';

  // ------------------------------------------------------------
  // Add logo - POST
  // ------------------------------------------------------------

  Future<Map<String, dynamic>> addDoctorLogo({
    required List<int> bytes,
    required String fileName,
    required String mimeType,
  }) async {
    return _uploadAsset(
      endpoint: _logoEndpoint,
      fieldName: 'logo',
      bytes: bytes,
      fileName: fileName,
      mimeType: mimeType,
      method: 'POST',
    );
  }

  // ------------------------------------------------------------
  // Replace logo - PUT
  // ------------------------------------------------------------

  Future<Map<String, dynamic>> replaceDoctorLogo({
    required List<int> bytes,
    required String fileName,
    required String mimeType,
  }) async {
    return _uploadAsset(
      endpoint: _logoEndpoint,
      fieldName: 'logo',
      bytes: bytes,
      fileName: fileName,
      mimeType: mimeType,
      method: 'PUT',
    );
  }

  // ------------------------------------------------------------
  // Add signature - POST
  // ------------------------------------------------------------

  Future<Map<String, dynamic>> addDoctorSignature({
    required List<int> bytes,
    required String fileName,
    required String mimeType,
  }) async {
    return _uploadAsset(
      endpoint: _signatureEndpoint,
      fieldName: 'signature',
      bytes: bytes,
      fileName: fileName,
      mimeType: mimeType,
      method: 'POST',
    );
  }

  // ------------------------------------------------------------
  // Replace signature - PUT
  // ------------------------------------------------------------

  Future<Map<String, dynamic>> replaceDoctorSignature({
    required List<int> bytes,
    required String fileName,
    required String mimeType,
  }) async {
    return _uploadAsset(
      endpoint: _signatureEndpoint,
      fieldName: 'signature',
      bytes: bytes,
      fileName: fileName,
      mimeType: mimeType,
      method: 'PUT',
    );
  }

  // ------------------------------------------------------------
  // Shared multipart upload
  // ------------------------------------------------------------
Future<Map<String, dynamic>> _uploadAsset({
  required String endpoint,
  required String fieldName,
  required List<int> bytes,
  required String fileName,
  required String mimeType,
  required String method,
}) async {
  if (bytes.isEmpty) {
    throw Exception('The selected image is empty.');
  }

  final normalizedMimeType = mimeType.toLowerCase().trim();

  const allowedMimeTypes = {
    'image/png',
    'image/jpeg',
    'image/webp',
  };

  if (!allowedMimeTypes.contains(normalizedMimeType)) {
    throw Exception('Select a PNG, JPEG, or WebP image.');
  }

  // Create a fresh multipart body for every upload.
  final formData = FormData.fromMap({
    fieldName: MultipartFile.fromBytes(
      bytes,
      filename: fileName,
      contentType: DioMediaType.parse(normalizedMimeType),
    ),
  });

  final response = await _dio.request(
    endpoint,
    data: formData,
    options: Options(
      method: method,
      contentType: Headers.multipartFormDataContentType,
    ),
  );

  final responseData = Map<String, dynamic>.from(response.data);

  if (responseData['success'] != true) {
    throw Exception(
      responseData['message'] ?? 'Image upload failed.',
    );
  }

  return responseData;
}
  // Future<Map<String, dynamic>> _uploadAsset({
  //   required String endpoint,
  //   required String fieldName,
  //   required List<int> bytes,
  //   required String fileName,
  //   required String mimeType,
  //   required String method,
  // }) async {
  //   if (bytes.isEmpty) {
  //     throw Exception('The selected image is empty.');
  //   }

  //   final normalizedMimeType = mimeType.toLowerCase().trim();

  //   const allowedMimeTypes = {
  //     'image/png',
  //     'image/jpeg',
  //     'image/webp',
  //   };

  //   if (!allowedMimeTypes.contains(normalizedMimeType)) {
  //     throw Exception('Select a PNG, JPEG, or WebP image.');
  //   }

  //   final formData = FormData.fromMap({
  //     fieldName: MultipartFile.fromBytes(
  //       bytes,
  //       filename: fileName,
  //       contentType: DioMediaType.parse(normalizedMimeType),
  //     ),
  //   });

  //   final response = method == 'POST'
  //       ? await _dio.post(endpoint, data: formData)
  //       : await _dio.put(endpoint, data: formData);

  //   final data = Map<String, dynamic>.from(response.data);

  //   if (data['success'] != true) {
  //     throw Exception(data['message'] ?? 'Image upload failed.');
  //   }

  //   return data;
  // }

  // ------------------------------------------------------------
  // Download logo - returns raw image bytes
  // ------------------------------------------------------------

  Future<List<int>> downloadDoctorLogo() async {
    return _downloadAsset(_logoEndpoint);
  }

  // ------------------------------------------------------------
  // Download signature - returns raw image bytes
  // ------------------------------------------------------------

  Future<List<int>> downloadDoctorSignature() async {
    return _downloadAsset(_signatureEndpoint);
  }

  Future<List<int>> _downloadAsset(String endpoint) async {
    final response = await _dio.get<List<int>>(
      endpoint,
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );

    final bytes = response.data;

    if (bytes == null || bytes.isEmpty) {
      throw Exception('The image response is empty.');
    }

    return bytes;
  }

  // ------------------------------------------------------------
  // Get metadata
  // ------------------------------------------------------------

  Future<Map<String, dynamic>> getDoctorLogoMetadata() async {
    return _getAssetMetadata('$_logoEndpoint/metadata');
  }

  Future<Map<String, dynamic>> getDoctorSignatureMetadata() async {
    return _getAssetMetadata('$_signatureEndpoint/metadata');
  }

  Future<Map<String, dynamic>> _getAssetMetadata(String endpoint) async {
    final response = await _dio.get(endpoint);
    final body = Map<String, dynamic>.from(response.data);

    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'Unable to retrieve image metadata.');
    }

    return Map<String, dynamic>.from(
      body['data'] as Map,
    );
  }

  // ------------------------------------------------------------
  // Delete assets
  // ------------------------------------------------------------

  Future<Map<String, dynamic>> deleteDoctorLogo() async {
    return _deleteAsset(_logoEndpoint);
  }

  Future<Map<String, dynamic>> deleteDoctorSignature() async {
    return _deleteAsset(_signatureEndpoint);
  }

  Future<Map<String, dynamic>> _deleteAsset(String endpoint) async {
    final response = await _dio.delete(endpoint);
    final body = Map<String, dynamic>.from(response.data);

    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'Unable to delete image.');
    }

    return body;
  }


}

