import 'package:dio/dio.dart';

import 'package:docautomations/network/dio_client.dart';


class LayoutApiService {

  //===========================================================================
  // Constructor
  //===========================================================================

  LayoutApiService({
    Dio? dio,
  }) : _dio =
          dio ?? DioClient.instance;


  //===========================================================================
  // Dependencies
  //===========================================================================

  final Dio _dio;


  //===========================================================================
  // Endpoint
  //===========================================================================

  static const String _baseEndpoint =
      "/api/layout";


  //===========================================================================
  // Get Doctor Layout
  //===========================================================================
  //
  // GET /api/layout/
  //
  // Returns the doctor's PrescriptionLayout with
  // selectedThemeId populated by the backend.
  //
  //===========================================================================

  Future<Map<String, dynamic>> getDoctorLayout() async {

    final response =
        await _dio.get(
      _baseEndpoint,
    );

    return Map<String, dynamic>.from(
      response.data,
    );
  }


  //===========================================================================
  // Update Doctor Layout
  //===========================================================================
  //
  // PUT /api/layout/
  //
  //===========================================================================

  Future<Map<String, dynamic>> updateDoctorLayout(
    Map<String, dynamic> request,
  ) async {

    final response =
        await _dio.put(
      _baseEndpoint,
      data: request,
    );

    return Map<String, dynamic>.from(
      response.data,
    );
  }


  //===========================================================================
  // Reset Doctor Layout
  //===========================================================================
  //
  // POST /api/layout/reset
  //
  //===========================================================================

  Future<Map<String, dynamic>> resetDoctorLayout() async {

    final response =
        await _dio.post(
      "$_baseEndpoint/reset",
    );

    return Map<String, dynamic>.from(
      response.data,
    );
  }

}