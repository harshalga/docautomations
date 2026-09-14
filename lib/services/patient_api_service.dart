
import 'package:dio/dio.dart';

import 'package:docautomations/network/dio_client.dart';


class PatientApiService {

  //===========================================================================
  // Constructor
  //===========================================================================

  PatientApiService({
    Dio? dio,
  }) : _dio =
          dio ?? DioClient.instance;


  //===========================================================================
  // Dependencies
  //===========================================================================

  final Dio _dio;


  //===========================================================================
  // Endpoints
  //===========================================================================

  static const String _baseEndpoint =
      "/api/patients";


  //===========================================================================
  // Search Patients
  //===========================================================================
  //
  // GET /api/patients/search?searchText=...
  //
  //===========================================================================

  Future<Map<String, dynamic>> searchPatients({
    required String searchText,
  }) async {

    final response =
        await _dio.get(

      "$_baseEndpoint/search",

      queryParameters: {

        "searchText":
            searchText,

      },

    );

    return Map<String, dynamic>.from(
      response.data,
    );

  }


  //===========================================================================
  // Find Or Create Patient
  //===========================================================================
  //
  // POST /api/patients/
  //
  // Doctor ID is NOT sent from Flutter.
  // The backend obtains it from the authenticated JWT.
  //
  //===========================================================================

  Future<Map<String, dynamic>> findOrCreatePatient(
    Map<String, dynamic> patient,
  ) async {

    final response =
        await _dio.post(

      _baseEndpoint,

      data:
          patient,

    );

    return Map<String, dynamic>.from(
      response.data,
    );

  }


  //===========================================================================
  // Get Patient
  //===========================================================================
  //
  // GET /api/patients/:patientId
  //
  //===========================================================================

  Future<Map<String, dynamic>> getPatient(
    String patientId,
  ) async {

    final response =
        await _dio.get(

      "$_baseEndpoint/$patientId",

    );

    return Map<String, dynamic>.from(
      response.data,
    );

  }


  //===========================================================================
  // Update Patient
  //===========================================================================
  //
  // PUT /api/patients/:patientId
  //
  //===========================================================================

  Future<Map<String, dynamic>> updatePatient(

    String patientId,

    Map<String, dynamic> patient,

  ) async {

    final response =
        await _dio.put(

      "$_baseEndpoint/$patientId",

      data:
          patient,

    );

    return Map<String, dynamic>.from(
      response.data,
    );

  }


  //===========================================================================
  // Delete Patient
  //===========================================================================
  //
  // DELETE /api/patients/:patientId
  //
  //===========================================================================

  Future<Map<String, dynamic>> deletePatient(
    String patientId,
  ) async {

    final response =
        await _dio.delete(

      "$_baseEndpoint/$patientId",

    );

    return Map<String, dynamic>.from(
      response.data,
    );

  }

}

