import 'package:dio/dio.dart';

import '../utils/logger/logger.dart';

class MapsApiClient {
  MapsApiClient({
    Dio? dio,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://maps.googleapis.com',
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                sendTimeout: const Duration(seconds: 15),
              ),
            );

  final Dio _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    Logger.info('MapsApiClient', '--> GET  https://maps.googleapis.com$path');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      Logger.debug('MapsApiClient', 'Query: $queryParameters');
    }
    try {
      final response = await _dio.get<T>(path, queryParameters: queryParameters);
      Logger.info('MapsApiClient', '<-- ${response.statusCode}  https://maps.googleapis.com$path');
      Logger.debug('MapsApiClient', 'Response: ${response.data}');
      return response;
    } on DioException catch (e, stackTrace) {
      Logger.error(
        'MapsApiClient',
        '请求失败: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}


