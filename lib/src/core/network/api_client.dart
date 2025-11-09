import 'package:dio/dio.dart';
import '../../core/config/environment_config.dart';
import 'api_exception.dart';
import 'api_interceptors.dart';

class ApiClient {
  late final Dio _dio;
  ApiClient() {
    final options = BaseOptions(
      // 基地址来自环境变量
      baseUrl: EnvironmentConfig.config.baseApi,
      connectTimeout: const Duration(seconds: 60),  // 连接超时延长到60秒
      receiveTimeout: const Duration(seconds: 60),  // 接收超时延长到60秒
      sendTimeout: const Duration(seconds: 60),     // 发送超时延长到60秒
    );
    _dio = Dio(options);
    // 添加统一拦截器
    _dio.interceptors.add(ApiInterceptor());
  }

  /// 统一的错误处理和异常抛出
  Never _handleError(Object e) {
    if (e is DioException && e.error is ApiException) {
      throw e.error as ApiException;
    }
    
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw ApiException("网络超时，请检查网络连接后重试");
        case DioExceptionType.connectionError:
          throw ApiException("网络连接失败，请检查网络设置");
        case DioExceptionType.badResponse:
          throw ApiException("服务器响应错误: ${e.response?.statusCode}");
        case DioExceptionType.cancel:
          throw ApiException("请求已取消");
        case DioExceptionType.unknown:
        default:
          throw ApiException("网络错误: ${e.message}");
      }
    }
    
    throw ApiException("未知网络错误: ${e.toString()}");
  }

  /// GET 请求
  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } catch (e) {
      _handleError(e);
    }
  }

  /// POST 请求
  Future<Response> post(
      String path, {
        dynamic data,
        bool encryptBody = true, 
        Map<String, String>? queryParameters,
        Options? options,
      }) async {
    try {
      final extra = <String, dynamic>{
        ...?options?.extra,
        'encrypt_body': encryptBody,
      };
      final requestOptions = options?.copyWith(extra: extra) ?? Options(extra: extra);
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
      );
      return response;
    } catch (e) {
      _handleError(e);
    }
  }

  /// PUT 请求
  Future<Response> put(
      String path, {
        dynamic data,
        bool encryptBody = true,
      }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        options: Options(
          extra: {'encrypt_body': encryptBody},
        ),
      );
      return response;
    } catch (e) {
      _handleError(e);
    }
  }

  /// DELETE 请求
  Future<Response> delete(
      String path, {
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      final response = await _dio.delete(path, queryParameters: queryParameters);
      return response;
    } catch (e) {
      _handleError(e);
    }
  }
}
