import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../utils/logger/logger.dart';
import '../config/app_config.dart';
import '../constants/app_constant.dart';
import '../error/error_handler.dart';
import 'api_exception.dart';
import 'api_response.dart';
import 'api_header.dart';


class ApiInterceptor extends InterceptorsWrapper {
  final ApiHeader _apiHeader = const ApiHeader();
  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 记录请求开始时间
    options.extra[AppConstants.apiStartTime] = DateTime.now().millisecondsSinceEpoch;
    

    // 异步创建并添加请求头
    final customHeaders = await _apiHeader.createHeaders();
    options.headers.addAll(customHeaders);

    Logger.warn("API" , "--> ${options.method} ${options.uri}");
    Logger.warn("API" , "Headers: ${options.headers}");
    // 打印 Query 参数（通常用于 GET）
    if (options.queryParameters.isNotEmpty) {
      Logger.warn("API" ,"Query: ${options.queryParameters}");
    }
    // 打印 Body 数据（通常用于 POST/PUT）
    if (options.data != null) {
      Logger.warn("API" ,"Body data: ${options.data}");
    }

    // 检查是否是 POST 请求并且有数据需要加密
    // if (options.method == 'POST' && options.data != null) {
    //   final bool shouldEncrypt = options.extra['encrypt_body'] as bool? ?? true;
    //   if (shouldEncrypt && options.data is Map<String, dynamic>) {
    //     final encryptedData = AppServices.cryptoService.encryptPostBody(
    //       body: options.data,
    //       uuid: AppServices.uuid,
    //     );
    //     options.data = encryptedData;
    //     Logger.debug("API", "Encrypted data: ${options.data}");
    //   }
    // }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 计算并打印请求耗时
    final startTime = response.requestOptions.extra[AppConstants.apiStartTime] as int;
    final duration = DateTime.now().millisecondsSinceEpoch - startTime;
    Logger.warn("API" ,"<-- ${response.statusCode}  [${duration}ms]  ${response.requestOptions.uri}");
    Logger.warn("API" ,"Response: ${response.data}");

    // 统一处理后端所有报错

    // 只处理 Map<String, dynamic> 类型的响应体
    if (response.data is! Map<String, dynamic>) {
      super.onResponse(response, handler);
      return;
    }

    final data = response.data as Map<String, dynamic>;

    // 检查响应是否包含业务 code 字段，如果不包含，则认为不是标准API响应，直接透传
    if (!data.containsKey(AppConfig.codeKey)) {
      super.onResponse(response, handler);
      return;
    }

    // 符合 ApiResponse 结构，对结果进行解析
    final apiResponse = ApiResponse.fromJson(data, null);

    // 检查是否是认证错误码
    if (AppConfig.authErrorCodes.contains(apiResponse.code)) {
      // 如果是认证错误，抛出专门的 AuthException
      final error = AuthException(apiResponse.message, code: apiResponse.code);
      handler.reject(
        DioException(requestOptions: response.requestOptions, error: error),
        true,
      );
      return;
    }

    // 检查业务是否成功
    if (apiResponse.isSuccessful) {
      // 如果业务成功，我们直接返回 `data` 部分给调用方，简化使用
      response.data = apiResponse.data;
      handler.next(response);
    } else {
      // 业务失败，抛出 ApiException，由 onError 捕获
      final error = ApiException(apiResponse.message, code: apiResponse.code);
      handler.reject(
        DioException(requestOptions: response.requestOptions, error: error),
        true,
      );
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 计算并打印请求耗时
    final startTime = err.requestOptions.extra[AppConstants.apiStartTime] as int?;
    String durationTag = "";
    if (startTime != null) {
      final duration = DateTime.now().millisecondsSinceEpoch - startTime;
      durationTag = " [${duration}ms]";
    }

    Logger.error("API" ,"<-- DioError$durationTag: ", error: err.error, stackTrace: err.stackTrace);
    Logger.error("API" ,"Message: ${err.message}");

    // 将所有错误统一包装成 ApiException
    final ApiException apiException;

    if (err.error is ApiException) {
      // 如果是 onResponse 中抛出的业务异常，直接使用
      apiException = err.error as ApiException;
    } else {
      // 其他 Dio 异常（超时、网络、404等）
      switch (err.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          apiException = ApiException("网络超时，请稍后重试", code: -1);
          break;
        case DioExceptionType.badResponse:
        // 服务器返回了错误状态码 (4xx, 5xx)
          final statusCode = err.response?.statusCode;
          apiException = ApiException("服务器错误 [$statusCode]", code: statusCode);
          break;
        case DioExceptionType.cancel:
          apiException = ApiException("请求已取消", code: -1);
          break;
        default:
          apiException = ApiException("连接异常，请检查网络设置", code: -1);
      }
    }
    // 创建一个新的 DioException，用我们的 ApiException 替换原始的 error
    final newErr = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      stackTrace: err.stackTrace,
      // 【核心】将 error 字段替换为格式化后的 ApiException
      error: apiException,
    );

    if (err.error is AuthException) {
      final authException = err.error as AuthException;

      // 使用全局context处理认证错误
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ErrorHandler.handleAuthError(authException);
      });
    }

    //  使用 handler.reject() 将包装后的新异常传递下去
    return handler.reject(newErr);
  }
}
