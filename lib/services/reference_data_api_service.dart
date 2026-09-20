import 'package:dio/dio.dart';

import 'package:docautomations/datamodels/master/country.dart';
import 'package:docautomations/network/dio_client.dart';


class ReferenceDataApiService {

  //===========================================================================
  // Dependencies
  //===========================================================================

  final Dio _dio;


  //===========================================================================
  // Constructor
  //===========================================================================

  ReferenceDataApiService({

    Dio? dio,

  }) : _dio =
          dio ?? DioClient.instance;


  //===========================================================================
  // Countries
  //===========================================================================

  Future<List<Country>> fetchCountries() async {

    final response =
        await _dio.get(

      "/api/countries",

    );


    final responseData =
        Map<String, dynamic>.from(
          response.data,
        );


    if (responseData["success"] != true) {

      throw Exception(

        responseData["message"] ??
            "Unable to fetch countries.",

      );

    }


    final data =
        responseData["data"];


    if (data == null) {

      return [];

    }


    final countries =
        List<dynamic>.from(
          data,
        );


    return countries
        .map(

          (item) =>
              Country.fromJson(

            Map<String, dynamic>.from(
              item,
            ),

          ),

        )
        .toList();

  }


  //===========================================================================
  // Get Country By ID
  //===========================================================================

  Future<Country> fetchCountry(
    String countryId,
  ) async {

    final response =
        await _dio.get(

      "/api/countries/$countryId",

    );


    final responseData =
        Map<String, dynamic>.from(
          response.data,
        );


    if (responseData["success"] != true) {

      throw Exception(

        responseData["message"] ??
            "Unable to fetch country.",

      );

    }


    final data =
        responseData["data"];


    if (data == null) {

      throw Exception(
        "Country not found.",
      );

    }


    return Country.fromJson(

      Map<String, dynamic>.from(
        data,
      ),

    );

  }


  //===========================================================================
  // Get Country By Code
  //===========================================================================

  Future<Country> fetchCountryByCode(
    String countryCode,
  ) async {

    final response =
        await _dio.get(

      "/api/countries/code/$countryCode",

    );


    final responseData =
        Map<String, dynamic>.from(
          response.data,
        );


    if (responseData["success"] != true) {

      throw Exception(

        responseData["message"] ??
            "Unable to fetch country.",

      );

    }


    final data =
        responseData["data"];


    if (data == null) {

      throw Exception(
        "Country not found.",
      );

    }


    return Country.fromJson(

      Map<String, dynamic>.from(
        data,
      ),

    );

  }

}