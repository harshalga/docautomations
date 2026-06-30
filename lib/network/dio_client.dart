

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:docautomations/services/auth_service.dart';
import 'package:docautomations/utils/app_config.dart';
import '../services/logger_service.dart';

class DioClient {
  static Dio? _dio;

  static bool _isRefreshing = false;
  static Completer<bool>? _refreshCompleter;

  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }
//"https://license-server-0zfe.onrender.com";
  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 45),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        // ===============================
        // REQUEST
        // ===============================
        onRequest: (options, handler) async {
          final token = await AuthService.getToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] =
                'Bearer $token';
          }

          LoggerService.debug(
            '➡️ ${options.method} ${options.uri}',
          );

          handler.next(options);
        },

        // ===============================
        // RESPONSE
        // ===============================
        onResponse: (response, handler) {
          LoggerService.debug(
            '⬅️ ${response.statusCode} ${response.requestOptions.uri}',
          );

          handler.next(response);
        },

        // ===============================
        // ERROR + AUTO REFRESH TOKEN
        // ===============================
        onError:
            (DioException e, handler) async {
          final status =
              e.response?.statusCode;

          final path =
              e.requestOptions.path;

          final isRefreshCall =
              path.contains('/refresh');

          // --------------------------------
          // If token expired
          // --------------------------------
          if (status == 401 &&
              !isRefreshCall) {
            try {
              // another refresh already running
              if (_isRefreshing) {
                await _refreshCompleter
                    ?.future;
              } else {
                _isRefreshing = true;
                _refreshCompleter =
                    Completer<bool>();

                final refreshed =
                    await AuthService
                        .refreshAccessToken();

                _refreshCompleter
                    ?.complete(
                        refreshed);

                _isRefreshing =
                    false;
              }

              final success =
                  await _refreshCompleter!
                      .future;

              if (success) {
                final newToken =
                    await AuthService
                        .getToken();

                final request =
                    e.requestOptions;
                request.headers.remove('Authorization');
                request.headers[
                        'Authorization'] =
                    'Bearer $newToken';

                // final clonedResponse =
                //     await dio.fetch(
                //         request);

                final clonedResponse = await dio.request(
  request.path,
  data: request.data,
  queryParameters: request.queryParameters,
  options: Options(
    method: request.method,
    headers: request.headers,
  ),
);

                return handler.resolve(
                    clonedResponse);
              } else {
                await AuthService
                    .logout();
              }
            } catch (_) {
              await AuthService
                  .logout();
            }
          }

          await LoggerService.error(
            '❌ API Error',
            error: e,
            stack: e.stackTrace,
          );

          handler.next(e);
        },
      ),
    );

    return dio;
  }
}