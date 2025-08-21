import 'package:dio/dio.dart';
import '../../app/environment_config.dart';
import '../../utils/logger/logger.dart';
import 'api_exception.dart';
import 'api_interceptors.dart';

class ApiClient {
  late final Dio _dio;
  ApiClient() {
    final options = BaseOptions(
      // 基地址来自环境变量
      baseUrl: EnvironmentConfig.config.baseApi,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
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
    throw ApiException("未知网络错误");
  }

  /// GET 请求
  Future<T> get<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        T Function(Object? json)? fromJsonT,
      }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      if (fromJsonT != null) {
        return fromJsonT(response.data);
      }
      return response.data;
    } catch (e) {
      _handleError(e);
    }
  }

  /// POST 请求
  Future<T> post<T>(
      String path, {
        dynamic data,
        T Function(Object? json)? fromJsonT,
        bool encryptBody = true,
      }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        options: Options(
          extra: {'encrypt_body': encryptBody},
        ),
      );
      if (fromJsonT != null) {
        return fromJsonT(response.data);
      }
      return response.data;
    } catch (e) {
      _handleError(e);
    }
  }
}
