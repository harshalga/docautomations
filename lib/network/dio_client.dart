

// import 'dart:async';
// import 'package:dio/dio.dart';
// import 'package:docautomations/services/auth_service.dart';
// import 'package:docautomations/utils/app_config.dart';
// import '../services/logger_service.dart';

// class DioClient {
//   static Dio? _dio;

//   static bool _isRefreshing = false;
//   static Completer<bool>? _refreshCompleter;

//   static Dio get instance {
//     _dio ??= _createDio();
//     return _dio!;
//   }
// //"https://license-server-0zfe.onrender.com";
//   static Dio _createDio() {
//     final dio = Dio(
//       BaseOptions(
//         baseUrl: AppConfig.baseUrl,
//         connectTimeout: const Duration(seconds: 15),
//         receiveTimeout: const Duration(seconds: 45),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//       ),
//     );

//     dio.interceptors.add(
//       InterceptorsWrapper(
//         // ===============================
//         // REQUEST
//         // ===============================
//         onRequest: (options, handler) async {
//           final token = await AuthService.getToken();

//           if (token != null && token.isNotEmpty) {
//             options.headers['Authorization'] =
//                 'Bearer $token';
//           }

//           LoggerService.debug(
//             '➡️ ${options.method} ${options.uri}',
//           );

//           handler.next(options);
//         },

//         // ===============================
//         // RESPONSE
//         // ===============================
//         onResponse: (response, handler) {
//           LoggerService.debug(
//             '⬅️ ${response.statusCode} ${response.requestOptions.uri}',
//           );

//           handler.next(response);
//         },

//         // ===============================
//         // ERROR + AUTO REFRESH TOKEN
//         // ===============================
//         onError:
//             (DioException e, handler) async {
//           final status =
//               e.response?.statusCode;

//           final path =
//               e.requestOptions.path;

//           final isRefreshCall =
//               path.contains('/refresh');

//           // --------------------------------
//           // If token expired
//           // --------------------------------
//           if (status == 401 &&
//               !isRefreshCall) {
//             try {
//               // another refresh already running
//               if (_isRefreshing) {
//                 await _refreshCompleter
//                     ?.future;
//               } else {
//                 _isRefreshing = true;
//                 _refreshCompleter =
//                     Completer<bool>();

//                 final refreshed =
//                     await AuthService
//                         .refreshAccessToken();

//                 _refreshCompleter
//                     ?.complete(
//                         refreshed);

//                 _isRefreshing =
//                     false;
//               }

//               final success =
//                   await _refreshCompleter!
//                       .future;

//               if (success) {
//                 final newToken =
//                     await AuthService
//                         .getToken();

//                 final request =
//                     e.requestOptions;
//                 request.headers.remove('Authorization');
//                 request.headers[
//                         'Authorization'] =
//                     'Bearer $newToken';

//                 // final clonedResponse =
//                 //     await dio.fetch(
//                 //         request);

//                 final clonedResponse = await dio.request(
//   request.path,
//   data: request.data,
//   queryParameters: request.queryParameters,
//   options: Options(
//     method: request.method,
//     headers: request.headers,
//   ),
// );

//                 return handler.resolve(
//                     clonedResponse);
//               } else {
//                 await AuthService
//                     .logout();
//               }
//             } catch (_) {
//               await AuthService
//                   .logout();
//             }
//           }

//           await LoggerService.error(
//             '❌ API Error',
//             error: e,
//             stack: e.stackTrace,
//           );

//           handler.next(e);
//         },
//       ),
//     );

//     return dio;
//   }
// }


import 'dart:async';

import 'package:dio/dio.dart';

import 'package:docautomations/services/auth_service.dart';
import 'package:docautomations/services/logger_service.dart';
import 'package:docautomations/utils/app_config.dart';

class DioClient {

  //===========================================================================
  // Singleton
  //===========================================================================

  static Dio? _dio;

  static Dio get instance {

    _dio ??= _createDio();

    return _dio!;

  }


  //===========================================================================
  // Token Refresh State
  //===========================================================================

  static bool _isRefreshing = false;

  static Completer<bool>? _refreshCompleter;


  //===========================================================================
  // Create Dio
  //===========================================================================

  static Dio _createDio() {

    final dio = Dio(

      BaseOptions(

        baseUrl: AppConfig.baseUrl,

        connectTimeout:
            const Duration(
              seconds: 15,
            ),

        receiveTimeout:
            const Duration(
              seconds: 45,
            ),

        headers: {

          "Content-Type":
              "application/json",

          "Accept":
              "application/json",

        },

      ),

    );


    //=========================================================================
    // Interceptors
    //=========================================================================

    dio.interceptors.add(

      InterceptorsWrapper(


        //---------------------------------------------------------------------
        // Request
        //---------------------------------------------------------------------

        onRequest:
            (
              options,
              handler,
            ) async {

          //---------------------------------------------------------------
          // Attach Access Token
          //---------------------------------------------------------------

          final token =
              await AuthService.getAccessToken();

          if (
              token != null &&
              token.isNotEmpty
          ) {

            options.headers[
                "Authorization"
            ] =
                "Bearer $token";

          }


          //---------------------------------------------------------------
          // Logging
          //---------------------------------------------------------------

          LoggerService.debug(

            "➡️ ${options.method} ${options.uri}",

          );


          handler.next(
            options,
          );

        },


        //---------------------------------------------------------------------
        // Response
        //---------------------------------------------------------------------

        onResponse:
            (
              response,
              handler,
            ) {

          LoggerService.debug(

            "⬅️ ${response.statusCode} "
            "${response.requestOptions.uri}",

          );

          handler.next(
            response,
          );

        },


        //---------------------------------------------------------------------
        // Error
        //---------------------------------------------------------------------

        onError:
            (
              DioException error,
              handler,
            ) async {

          final statusCode =
              error.response?.statusCode;

          final request =
              error.requestOptions;

          final path =
              request.path;


          //---------------------------------------------------------------
          // Do not refresh refresh-token requests
          //---------------------------------------------------------------

          final isRefreshRequest =
              path.contains(
                "/api/doctors/refresh",
              );


          //---------------------------------------------------------------
          // Check whether request was already retried
          //---------------------------------------------------------------

          final alreadyRetried =
              request.extra[
                  "retried"
              ] ==
              true;


          //---------------------------------------------------------------
          // Access Token Expired
          //---------------------------------------------------------------

          if (
              statusCode == 401 &&
              !isRefreshRequest &&
              !alreadyRetried
          ) {

            try {

              //-----------------------------------------------------------
              // Mark Request As Retried
              //-----------------------------------------------------------

              request.extra[
                  "retried"
              ] =
                  true;


              //-----------------------------------------------------------
              // Refresh Token
              //-----------------------------------------------------------

              final refreshed =
                  await _refreshToken();


              //-----------------------------------------------------------
              // Refresh Failed
              //-----------------------------------------------------------

              if (!refreshed) {

                await AuthService.logout();

                return handler.next(
                  error,
                );

              }


              //-----------------------------------------------------------
              // Get New Access Token
              //-----------------------------------------------------------

              final newAccessToken =
                  await AuthService.getAccessToken();


              if (
                  newAccessToken == null ||
                  newAccessToken.isEmpty
              ) {

                await AuthService.logout();

                return handler.next(
                  error,
                );

              }


              //-----------------------------------------------------------
              // Retry Original Request
              //-----------------------------------------------------------

              request.headers[
                  "Authorization"
              ] =
                  "Bearer $newAccessToken";


              final response =
                  await dio.request(

                request.path,

                data:
                    request.data,

                queryParameters:
                    request.queryParameters,

                options:
                    Options(

                      method:
                          request.method,

                      headers:
                          request.headers,

                      responseType:
                          request.responseType,

                      contentType:
                          request.contentType,

                      followRedirects:
                          request.followRedirects,

                      validateStatus:
                          request.validateStatus,

                      receiveDataWhenStatusError:
                          request
                              .receiveDataWhenStatusError,

                    ),

              );


              return handler.resolve(
                response,
              );

            }
            catch (refreshError, stackTrace) {

              await LoggerService.error(

                "❌ Token refresh failed",

                error:
                    refreshError,

                stack:
                    stackTrace,

              );

              await AuthService.logout();

            }

          }


          //---------------------------------------------------------------
          // Log API Error
          //---------------------------------------------------------------

          await LoggerService.error(

            "❌ API Error",

            error:
                error,

            stack:
                error.stackTrace,

          );


          handler.next(
            error,
          );

        },

      ),

    );


    return dio;

  }


  //===========================================================================
  // Refresh Token
  //===========================================================================

  static Future<bool> _refreshToken() async {

    //-----------------------------------------------------------------------
    // Another Refresh Already Running
    //-----------------------------------------------------------------------

    if (_isRefreshing) {

      return await _refreshCompleter!.future;

    }


    //-----------------------------------------------------------------------
    // Start Refresh
    //-----------------------------------------------------------------------

    _isRefreshing = true;

    _refreshCompleter =
        Completer<bool>();


    try {

      final refreshed =
          await AuthService.refreshAccessToken();


      _refreshCompleter!.complete(
        refreshed,
      );

      return refreshed;

    }
    catch (_) {

      if (
          !_refreshCompleter!.isCompleted
      ) {

        _refreshCompleter!.complete(
          false,
        );

      }

      return false;

    }
    finally {

      _isRefreshing = false;

    }

  }


  //===========================================================================
  // Reset Client
  //
  // Useful during logout or testing.
  //===========================================================================

  static void reset() {

    _dio = null;

    _isRefreshing = false;

    _refreshCompleter = null;

  }

}