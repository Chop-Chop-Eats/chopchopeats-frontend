import 'package:dio/dio.dart';
import '../../app_services.dart';
import 'api_client.dart';

/// 一个全局的、简短的 API 调用快捷方式。
///
/// 它将所有调用代理到在 AppServices 中初始化的 ApiClient 实例，
/// 从而让我们既能享受简洁的静态调用语法，又能保持底层架构的可测试性和依赖注入特性。
class Http {
  Http._();

  /// 快捷访问 ApiClient 实例
  static ApiClient get _client => AppServices.apiClient;

  /// GET 请求的静态快捷方式
  static Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
      }) {
    return _client.get(
      path,
      queryParameters: queryParameters,
    );
  }

  /// POST 请求的静态快捷方式
  static Future<Response> post(
      String path, {
        dynamic data,
        bool encryptBody = true,
      }) {
    return _client.post(
      path,
      data: data,
      encryptBody: encryptBody,
    );
  }

  /// PUT 请求的静态快捷方式
  static Future<Response> put(
      String path, {
        dynamic data,
        bool encryptBody = true,
      }) {
    return _client.put(
      path,
      data: data,
      encryptBody: encryptBody,
    );
  }

  /// DELETE 请求的静态快捷方式
  static Future<Response> delete(
      String path, {
        Map<String, dynamic>? queryParameters,
      }) {
    return _client.delete(
      path,
      queryParameters: queryParameters,
    );
  }
}