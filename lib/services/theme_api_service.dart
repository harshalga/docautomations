import 'package:dio/dio.dart';
import 'package:docautomations/network/dio_client.dart';

class ThemeApiService {
  ThemeApiService({
    Dio? dio,
  }) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  static const String _baseEndpoint = "/api/themes";

  //===========================================================================
  // Get All Active Themes
  //===========================================================================
  //
  // GET /api/themes/
  //
  // Backend repository already filters themes using isActive: true.
  //
  //===========================================================================

  Future<Map<String, dynamic>> getAllThemes() async {
    final response = await _dio.get(_baseEndpoint);

    return Map<String, dynamic>.from(response.data);
  }
}