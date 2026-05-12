// import 'dart:async';

// import 'package:dio/dio.dart';
// import 'package:docautomations/services/auth_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../services/logger_service.dart';


// class _QueuedRequest {
//   final RequestOptions options;
// //  final ErrorInterceptorHandler handler;

//   //_QueuedRequest(this.options, this.handler);
//   _QueuedRequest(this.options);
// }

// class DioClient {
//   static Dio? _dio;

//   static bool _isRefreshing = false;
//   static Completer<void>? _refreshCompleter;
  
//   //static final List<RequestOptions> _retryQueue = [];
//   static final List<_QueuedRequest> _retryQueue = [];

//   static Dio get instance {
//     _dio ??= _createDio();
//     return _dio!;
//   }

//   static Dio _createDio() {
//     final dio = Dio(
//       BaseOptions(
//         baseUrl: 'https://license-server-0zfe.onrender.com',
//         connectTimeout: const Duration(seconds: 15),
//         receiveTimeout: const Duration(seconds: 45),
//         headers: {'Content-Type': 'application/json'},
//       ),
//     );

//     dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) async {
//           // final prefs = await SharedPreferences.getInstance();
//           // final token = prefs.getString('access_token');
//           final token =
//           await AuthService.getToken();

//           if (token != null) {
//             options.headers['Authorization'] = 'Bearer $token';
//           }

//           LoggerService.debug('➡️ ${options.method} ${options.uri}');
//           handler.next(options);
//         },

//         onResponse: (response, handler) {
//           LoggerService.debug(
//               '⬅️ ${response.statusCode} ${response.requestOptions.uri}');
//           handler.next(response);
//         },
// onError: (DioException e, handler) async {

//   if (e.response?.statusCode == 401) {

//     final requestOptions = e.requestOptions;

//     // Refresh already running → queue request
//     if (_isRefreshing) {
//       //_retryQueue.add(_QueuedRequest(requestOptions, handler));
//       _retryQueue.add(_QueuedRequest(requestOptions));
//       return;
//     }

//     _isRefreshing = true;

//     final refreshed = await _refreshToken();

//     _isRefreshing = false;

//     final prefs = await SharedPreferences.getInstance();

//     if (refreshed) {

//       final newToken = prefs.getString('access_token');

//       requestOptions.headers['Authorization'] = 'Bearer $newToken';

//       final response = await dio.fetch(requestOptions);

//       // Retry queued requests
//       for (final queued in _retryQueue) {

//         queued.options.headers['Authorization'] = 'Bearer $newToken';

//         //final retryResponse = await dio.fetch(queued.options);
//          dio.fetch(queued.options);
//         //queued.handler.resolve(retryResponse);
//       }

//       _retryQueue.clear();

//       return handler.resolve(response);

//     } else {

//       // session invalid
//       await prefs.remove('access_token');
//       await prefs.remove('refresh_token');

//     }
//   }

//   await LoggerService.error(
//     '❌ API Error',
//     error: e,
//     stack: e.stackTrace,
//   );

//   handler.next(e);
// }
      
//       ),
//     );

//     return dio;
//   }

//   static Future<bool> _refreshToken() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final refreshToken = prefs.getString('refresh_token');

//       if (refreshToken == null) return false;

//       final response = await Dio().post(
//         'https://license-server-0zfe.onrender.com/api/doctor/refresh',
//         data: {'refreshToken': refreshToken},
//       );

//       final newToken = response.data['accessToken'];

//       await prefs.setString('access_token', newToken);

//       LoggerService.debug("🔄 Token refreshed");

//       return true;
//     } catch (e) {
//       LoggerService.debug("❌ Token refresh failed");
//       return false;
//     }
//   }

//   static Future<void> _logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//   }
// }

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:docautomations/services/auth_service.dart';
import '../services/logger_service.dart';

class DioClient {
  static Dio? _dio;

  static bool _isRefreshing = false;
  static Completer<bool>? _refreshCompleter;

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