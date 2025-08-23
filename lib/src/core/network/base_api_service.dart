import 'api_client.dart';
import 'api_exception.dart';
import '../utils/logger/logger.dart';

/// API 服务基类
/// 提供统一的网络请求方法和错误处理，减少样板代码
abstract class BaseApiService {
  final ApiClient _apiClient;

  const BaseApiService(this._apiClient);

  /// 统一的 GET 请求方法
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic> json)? fromJson,
    String? tag,
  }) async {
    try {
      Logger.debug(tag ?? 'API', 'GET 请求: $path');
      
      final response = await _apiClient.get(path, queryParameters: queryParameters);
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        
        if (fromJson != null) {
          final result = fromJson(data);
          Logger.debug(tag ?? 'API', 'GET 请求成功: $path');
          return result;
        } else {
          return data as T;
        }
      } else {
        Logger.warn(tag ?? 'API', 'GET 请求失败: $path, 状态码: ${response.statusCode}');
        throw ApiException('请求失败', code: response.statusCode);
      }
    } catch (e) {
      Logger.error(tag ?? 'API', 'GET 请求异常: $path', error: e);
      if (e is ApiException) rethrow;
      throw ApiException('网络请求异常: ${e.toString()}', code: 0);
    }
  }

  /// 统一的 POST 请求方法
  Future<T> post<T>(
    String path, {
    dynamic data,
    T Function(Map<String, dynamic> json)? fromJson,
    String? tag,
  }) async {
    try {
      Logger.debug(tag ?? 'API', 'POST 请求: $path');
      
      final response = await _apiClient.post(path, data: data);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;
        
        if (fromJson != null) {
          final result = fromJson(responseData);
          Logger.debug(tag ?? 'API', 'POST 请求成功: $path');
          return result;
        } else {
          return responseData as T;
        }
      } else {
        Logger.warn(tag ?? 'API', 'POST 请求失败: $path, 状态码: ${response.statusCode}');
        throw ApiException('请求失败', code: response.statusCode);
      }
    } catch (e) {
      Logger.error(tag ?? 'API', 'POST 请求异常: $path', error: e);
      if (e is ApiException) rethrow;
      throw ApiException('网络请求异常: ${e.toString()}', code: 0);
    }
  }

  /// 统一的 PUT 请求方法
  Future<T> put<T>(
    String path, {
    dynamic data,
    T Function(Map<String, dynamic> json)? fromJson,
    String? tag,
  }) async {
    try {
      Logger.debug(tag ?? 'API', 'PUT 请求: $path');
      
      final response = await _apiClient.put(path, data: data);
      
      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        
        if (fromJson != null) {
          final result = fromJson(responseData);
          Logger.debug(tag ?? 'API', 'PUT 请求成功: $path');
          return result;
        } else {
          return responseData as T;
        }
      } else {
        Logger.warn(tag ?? 'API', 'PUT 请求失败: $path, 状态码: ${response.statusCode}');
        throw ApiException('请求失败', code: response.statusCode);
      }
    } catch (e) {
      Logger.error(tag ?? 'API', 'PUT 请求异常: $path', error: e);
      if (e is ApiException) rethrow;
      throw ApiException('网络请求异常: ${e.toString()}', code: 0);
    }
  }

  /// 统一的 DELETE 请求方法
  Future<T> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic> json)? fromJson,
    String? tag,
  }) async {
    try {
      Logger.debug(tag ?? 'API', 'DELETE 请求: $path');
      
      final response = await _apiClient.delete(path, queryParameters: queryParameters);
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        final responseData = response.data as Map<String, dynamic>?;
        
        if (fromJson != null && responseData != null) {
          final result = fromJson(responseData);
          Logger.debug(tag ?? 'API', 'DELETE 请求成功: $path');
          return result;
        } else {
          return responseData as T;
        }
      } else {
        Logger.warn(tag ?? 'API', 'DELETE 请求失败: $path, 状态码: ${response.statusCode}');
        throw ApiException('请求失败', code: response.statusCode);
      }
    } catch (e) {
      Logger.error(tag ?? 'API', 'DELETE 请求异常: $path', error: e);
      if (e is ApiException) rethrow;
      throw ApiException('网络请求异常: ${e.toString()}', code: 0);
    }
  }

  /// 处理标准 API 响应格式
  /// 假设后端返回格式为: { "success": true, "data": {...}, "message": "..." }
  Map<String, dynamic> handleStandardResponse(
    Map<String, dynamic> response,
    Map<String, dynamic> Function(Map<String, dynamic> json) fromJson,
    String? tag,
  ) {
    if (response['success'] == true) {
      final data = response['data'] as Map<String, dynamic>?;
      if (data != null) {
        // 返回整个 response，但确保 data 部分已经通过 fromJson 处理
        return response;
      } else {
        Logger.warn(tag ?? 'API', 'API 响应成功但 data 为空');
        throw Exception('响应数据为空');
      }
    } else {
      final message = response['message']?.toString() ?? '请求失败';
      Logger.warn(tag ?? 'API', 'API 响应失败: $message');
      throw Exception(message);
    }
  }
}
