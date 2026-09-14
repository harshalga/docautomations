import 'package:dio/dio.dart';

import 'package:docautomations/network/dio_client.dart';


class PrescriptionApiService {

  //===========================================================================
  // Constructor
  //===========================================================================

  PrescriptionApiService({
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
      "/api/prescriptions";


  //===========================================================================
  // Create Prescription
  //===========================================================================
  //
  // POST /api/prescriptions/
  //
  //===========================================================================

  Future<Map<String, dynamic>> createPrescription(
    Map<String, dynamic> request,
  ) async {

    final response =
        await _dio.post(

      _baseEndpoint,

      data:
          request,

    );

    return Map<String, dynamic>.from(
      response.data,
    );

  }


  //===========================================================================
  // Revise Prescription
  //===========================================================================
  //
  // POST /api/prescriptions/:prescriptionId/revise
  //
  //===========================================================================

  Future<Map<String, dynamic>> revisePrescription(

    String prescriptionId,

    Map<String, dynamic> request,

  ) async {

    final response =
        await _dio.post(

      "$_baseEndpoint/$prescriptionId/revise",

      data:
          request,

    );

    return Map<String, dynamic>.from(
      response.data,
    );

  }


  //===========================================================================
  // Get Latest Prescription
  //===========================================================================
  //
  // GET /api/prescriptions/latest/:patientDoctorId
  //
  //===========================================================================

  Future<Map<String, dynamic>> getLatestPrescription(
    String patientDoctorId,
  ) async {

    final response =
        await _dio.get(

      "$_baseEndpoint/latest/$patientDoctorId",

    );

    return Map<String, dynamic>.from(
      response.data,
    );

  }


  //===========================================================================
  // Get Prescription History
  //===========================================================================
  //
  // GET /api/prescriptions/history/:patientDoctorId
  //
  //===========================================================================

  Future<Map<String, dynamic>> getPrescriptionHistory(
    String patientDoctorId,
  ) async {

    final response =
        await _dio.get(

      "$_baseEndpoint/history/$patientDoctorId",

    );

    return Map<String, dynamic>.from(
      response.data,
    );

  }


  //===========================================================================
  // Get Prescription
  //===========================================================================
  //
  // GET /api/prescriptions/:prescriptionId
  //
  //===========================================================================

  Future<Map<String, dynamic>> getPrescription(
    String prescriptionId,
  ) async {

    final response =
        await _dio.get(

      "$_baseEndpoint/$prescriptionId",

    );

    return Map<String, dynamic>.from(
      response.data,
    );

  }


  //===========================================================================
  // Cancel Prescription
  //===========================================================================
  //
  // PUT /api/prescriptions/:prescriptionId/cancel
  //
  //===========================================================================

  Future<Map<String, dynamic>> cancelPrescription(
    String prescriptionId,
  ) async {

    final response =
        await _dio.put(

      "$_baseEndpoint/$prescriptionId/cancel",

    );

    return Map<String, dynamic>.from(
      response.data,
    );

  }

}

