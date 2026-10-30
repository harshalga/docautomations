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


              // //-----------------------------------------------------------
              // // Retry Original Request
              // //-----------------------------------------------------------

              // request.headers[
              //     "Authorization"
              // ] =
              //     "Bearer $newAccessToken";


              // final response =
              //     await dio.request(

              //   request.path,

              //   data:
              //       request.data,

              //   queryParameters:
              //       request.queryParameters,

              //   options:
              //       Options(

              //         method:
              //             request.method,

              //         headers:
              //             request.headers,

              //         responseType:
              //             request.responseType,

              //         contentType:
              //             request.contentType,

              //         followRedirects:
              //             request.followRedirects,

              //         validateStatus:
              //             request.validateStatus,

              //         receiveDataWhenStatusError:
              //             request
              //                 .receiveDataWhenStatusError,

              //       ),

              // );


              // return handler.resolve(
              //   response,
              // );

              //---------------------------------------------------------------------------
                // Retry Original Request
                //---------------------------------------------------------------------------

                // Always use the refreshed access token.
                final retryHeaders = Map<String, dynamic>.from(
                  request.headers,
                );

                retryHeaders['Authorization'] =
                    'Bearer $newAccessToken';

                // Rebuild multipart data for the retry.
                // FormData.clone() creates a fresh FormData instance.
                final dynamic retryData;

                if (request.data is FormData) {
                  retryData = (request.data as FormData).clone();
                } else {
                  retryData = request.data;
                }

                final response = await dio.request(
                  request.path,

                  data: retryData,

                  queryParameters: request.queryParameters,

                  options: Options(
                    method: request.method,

                    headers: retryHeaders,

                    // Preserve retry protection.
                    extra: {
                      ...request.extra,
                      'retried': true,
                    },

                    responseType: request.responseType,

                    contentType: request.contentType,

                    followRedirects: request.followRedirects,

                    validateStatus: request.validateStatus,

                    receiveDataWhenStatusError:
                        request.receiveDataWhenStatusError,
                  ),
                );

                return handler.resolve(response);

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