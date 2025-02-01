import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../model/api_response_model.dart';
import '../utils/app_string.dart';


class ApiService {
  static final Dio _dio = getMyDio();
  static String token = "";

  static Future<ApiResponseModel> postApi(String url, body,
      {Map<String, String>? header}) async {
    dynamic responseJson;

    Options options = Options(headers: header);

    try {
      Response response = await _dio.post(url, data: body, options: options);

      responseJson = handleResponse(response);
    } on SocketException {
      return ApiResponseModel(503, AppString.noInternetConnection, {});
    } on FormatException {
      return ApiResponseModel(400, AppString.badResponseRequest, {});
    } on TimeoutException {
      return ApiResponseModel(408, AppString.requestTimeOut, {});
    } catch (e) {
      return ApiResponseModel(400, e.toString(), {});
    }

    return responseJson;
  }

  ///<<<======================== Get Api ==============================>>>

  static Future<ApiResponseModel> getApi(String url,
      {Map<String, String>? header}) async {
    dynamic responseJson;

    Options options = Options(headers: header);

    try {
      Response response = await _dio.get(url, options: options);

      responseJson = handleResponse(response);
    } on SocketException {
      return ApiResponseModel(503, AppString.noInternetConnection, {});
    } on FormatException {
      return ApiResponseModel(400, AppString.badResponseRequest, {});
    } on TimeoutException {
      return ApiResponseModel(408, AppString.requestTimeOut, {});
    } catch (e) {
      return ApiResponseModel(400, e.toString(), {});
    }
    return responseJson;
  }

  ///<<<======================== Put Api ==============================>>>

  static Future<ApiResponseModel> putApi(String url, Map<String, String> body,
      {Map<String, String>? header}) async {
    dynamic responseJson;

    Options options = Options(headers: header);

    try {
      Response response = await _dio.post(url, data: body, options: options);

      responseJson = handleResponse(response);
    } on SocketException {
      return ApiResponseModel(503, AppString.noInternetConnection, {});
    } on FormatException {
      return ApiResponseModel(400, AppString.badResponseRequest, {});
    } on TimeoutException {
      return ApiResponseModel(408, AppString.requestTimeOut, {});
    } catch (e) {
      return ApiResponseModel(400, e.toString(), {});
    }
    return responseJson;
  }

  ///<<<======================== Patch Api ==============================>>>

  static Future<ApiResponseModel> patchApi(
    String url, {
    Map<String, String>? body,
    Map<String, String>? header,
  }) async {
    dynamic responseJson;
    Options options = Options(headers: header);

    try {
      if (body != null) {
        Response response = await _dio.post(url, data: body, options: options);
        responseJson = handleResponse(response);
      } else {
        Response response = await _dio.post(url, options: options);

        responseJson = handleResponse(response);
      }
    } on SocketException {
      return ApiResponseModel(503, AppString.noInternetConnection, {});
    } on FormatException {
      return ApiResponseModel(400, AppString.badResponseRequest, {});
    } on TimeoutException {
      return ApiResponseModel(408, AppString.requestTimeOut, {});
    } catch (e) {
      return ApiResponseModel(400, e.toString(), {});
    }

    return responseJson;
  }

  ///<<<======================== Delete Api ==============================>>>

  static Future<ApiResponseModel> deleteApi(String url,
      {Map<String, String>? body, Map<String, String>? header}) async {
    dynamic responseJson;

    Options options = Options(headers: header);

    try {
      if (body != null) {
        Response response = await _dio.post(url, data: body, options: options);

        responseJson = handleResponse(response);
      } else {
        Response response = await _dio.post(url, options: options);
        responseJson = handleResponse(response);
      }
    } on SocketException {
      return ApiResponseModel(503, AppString.noInternetConnection, {});
    } on FormatException {
      return ApiResponseModel(400, AppString.badResponseRequest, {});
    } on TimeoutException {
      return ApiResponseModel(408, AppString.requestTimeOut, {});
    } catch (e) {
      return ApiResponseModel(400, e.toString(), {});
    }
    return responseJson;
  }

  static dynamic handleResponse(Response response) {
    switch (response.statusCode) {
      case 200:
        return ApiResponseModel(
            response.statusCode, response.data['message'], response.data);
      case 201:
        return ApiResponseModel(200, response.data['message'], response.data);
      case 401:
        // Get.offAllNamed(AppRoutes.signInScreen);
        return ApiResponseModel(
            response.statusCode, response.data['message'], response.data);
      case 400:
        return ApiResponseModel(
            response.statusCode, response.data['message'], response.data);
      case 404:
        return ApiResponseModel(
            response.statusCode, response.data['message'], response.data);
      default:
        return ApiResponseModel(
            response.statusCode, response.data['message'], response.data);
    }
  }
}

Dio getMyDio() {
  Dio dio = Dio();

  Stopwatch stopwatch = Stopwatch();

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      options.headers["Authorization"] = ApiService.token;
      options.headers["Content-Type"] = "application/json";
      options.sendTimeout = Duration(seconds: 30);
      options.receiveTimeout = Duration(seconds: 30);
      options.receiveDataWhenStatusError = true;

      if (kDebugMode) {
        stopwatch.start();
        print("Requested URL: ${options.uri}");
        print("Request Headers: ${options.headers}");
        print("Request Body: ${jsonEncode((options.data))}");
      }

      handler.next(options);
    },
    onResponse: (response, handler) {
      if (kDebugMode) {
        stopwatch.stop();
        print(
            "Response Time: ${stopwatch.elapsedMilliseconds / 1000} second\n");

        print("Response Status Code: ${response.statusCode}");
        print("Response Data: ${jsonEncode(response.data)}");

        stopwatch.reset();
      }

      handler.next(response);
    },
    onError: (error, handler) {
      if (kDebugMode) {
        stopwatch.stop();

        print(
            "Response Time: ${stopwatch.elapsedMilliseconds / 1000} second\n");

        print("Error Status Code: ${error.response?.statusCode}");
        print("Error Data: ${jsonEncode(error.response?.data)}");
        stopwatch.reset();
      }
      if (error.type == DioExceptionType.connectionError) {
        print("Error fdfdsfdsfdsfds Code: ${error.response?.statusCode}");
      }

      handler.next(error);
    },
  ));

  return dio;
}
