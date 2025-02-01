import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:api_service_with_dio/helpers/prefs_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../model/api_response_model.dart';
import '../utils/app_string.dart';

class ApiService {
  static final Dio _dio = getMyDio();

  static Future<ApiResponseModel> postApi(String url, body,
      {Map<String, String>? header}) async {
    return requestApi(url, "POST", body: body, header: header);
  }

  static Future<ApiResponseModel> getApi(String url,
      {Map<String, String>? header}) async {
    return requestApi(url, "GET", header: header);
  }

  static Future<ApiResponseModel> putApi(String url, body,
      {Map<String, String>? header}) async {
    return requestApi(url, "PUT", body: body, header: header);
  }

  static Future<ApiResponseModel> patchApi(String url, body,
      {Map<String, String>? header}) async {
    return requestApi(url, "PATCH", body: body, header: header);
  }

  static Future<ApiResponseModel> deleteApi(String url,
      {Map<String, String>? body, Map<String, String>? header}) async {
    return requestApi(url, "DELETE", body: body, header: header);
  }



  static Future<ApiResponseModel> requestApi(
    String url,
    String method, {
    dynamic body,
    Map<String, String>? header,
  }) async {
    try {
      Response response = await _dio.request(
        url,
        data: body,
        options: Options(method: method, headers: header),
      );
      return handleResponse(response);
    } catch (e) {
      return handleError(e);
    }
  }

  static ApiResponseModel handleResponse(Response response) {
    return ApiResponseModel(response.statusCode ?? 500,
        response.data['message'] ?? "", response.data);
  }

  static ApiResponseModel handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return ApiResponseModel(408, AppString.requestTimeOut, {});
        case DioExceptionType.connectionError:
          return ApiResponseModel(503, AppString.noInternetConnection, {});
        default:
          return ApiResponseModel(
              error.response?.statusCode ?? 500, error.message ?? "", {});
      }
    } else if (error is SocketException) {
      return ApiResponseModel(503, AppString.noInternetConnection, {});
    } else if (error is FormatException) {
      return ApiResponseModel(400, AppString.badResponseRequest, {});
    } else if (error is TimeoutException) {
      return ApiResponseModel(408, AppString.requestTimeOut, {});
    } else {
      return ApiResponseModel(400, error.toString(), {});
    }
  }
}

Dio getMyDio() {
  Dio dio = Dio();
  Stopwatch stopwatch = Stopwatch();
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      options.headers["Authorization"] = PrefsHelper.token;
      options.headers["Content-Type"] = "application/json";
      options.sendTimeout = const Duration(seconds: 30);
      options.receiveTimeout = const Duration(seconds: 30);

      if (kDebugMode) {
        stopwatch.start();
        print("Api Service ==================>Requested method: ${options.method}");
        print("Api Service==================>Requested URL: ${options.uri}");
        print("Api Service==================>Request Headers: ${options.headers}");
        print("Api Service==================>Request Body: ${jsonEncode(options.data)}");
      }
      handler.next(options);
    },
    onResponse: (response, handler) {
      if (kDebugMode) {
        stopwatch.stop();
        print("Api Service==================>Response Time: ${stopwatch.elapsedMilliseconds / 1000} Second");
        print("Api Service==================>Response Status Code: ${response.statusCode}");
        print("Api Service==================>Response Data: ${jsonEncode(response.data)}");
        stopwatch.reset();
      }
      handler.next(response);
    },
    onError: (error, handler) {
      if (kDebugMode) {
        stopwatch.stop();
        print("Api Service==================>Response Time: ${stopwatch.elapsedMilliseconds / 1000} Second");
        print("Api Service==================>Error Status Code: ${error.response?.statusCode}");
        print("Api Service==================>Error Data: ${jsonEncode(error.response?.data)}");
        stopwatch.reset();
      }
      handler.next(error);
    },
  ));
  return dio;
}
