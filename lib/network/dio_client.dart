// import 'package:dio/dio.dart';
// import '../services/logger_service.dart';


// class DioClient {
// final Dio dio;


// DioClient._internal(this.dio);


// factory DioClient({required String baseUrl}) {
// final options = BaseOptions(baseUrl: baseUrl, connectTimeout: const Duration(milliseconds: 15000), receiveTimeout: const Duration(milliseconds: 15000));
// final dio = Dio(options);


// dio.interceptors.add(InterceptorsWrapper(
// onRequest: (options, handler) async {
// await LoggerService.debug('➡️ Request: ${options.method} ${options.uri}');
// if (options.data != null) await LoggerService.debug('Body: ${options.data}');
// handler.next(options);
// },
// onResponse: (response, handler) async {
// await LoggerService.debug('⬅️ Response [${response.statusCode}] ${response.requestOptions.uri}');
// // Avoid logging very large bodies in production. Trim if needed.
// await LoggerService.debug('Response data: ${response.data}');
// handler.next(response);
// },
// onError: (DioException e, handler) async {
// await LoggerService.error('❌ Dio error: ${e.message}', error: e, stack: e.stackTrace);
// handler.next(e);
// },
// ));


// return DioClient._internal(dio);
// }
// }

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/logger_service.dart';

class DioClient {
  static Dio? _dio;

  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://license-server-0zfe.onrender.com',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 45),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          LoggerService.debug('➡️ ${options.method} ${options.uri}');
          handler.next(options);
        },

        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              final prefs = await SharedPreferences.getInstance();
              final newToken = prefs.getString('access_token');

              e.requestOptions.headers['Authorization'] =
                  'Bearer $newToken';

              return handler.resolve(
                await dio.fetch(e.requestOptions),
              );
            }
          }

          await LoggerService.error(
            '❌ API Error',
            error: e,
            stack: e.stackTrace,
          );

          handler.next(e);
        },

        onResponse: (response, handler) async {
          LoggerService.debug('⬅️ ${response.statusCode} ${response.requestOptions.uri}');
          handler.next(response);
        },
      ),
    );

    return dio;
  }

  static Future<bool> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      if (refreshToken == null) return false;

      final response = await Dio().post(
        'https://license-server-0zfe.onrender.com/api/doctor/refresh',
        data: {'refreshToken': refreshToken},
      );

      final newToken = response.data['accessToken'];
      await prefs.setString('access_token', newToken);
      return true;
    } catch (_) {
      return false;
    }
  }
}
