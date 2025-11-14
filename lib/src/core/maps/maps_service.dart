import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'maps_config.dart';
import 'maps_api_client.dart';
import '../utils/logger/logger.dart';

class PlaceSuggestion {
  PlaceSuggestion({
    required this.placeId,
    required this.primaryText,
    required this.secondaryText,
    this.street,
  });

  final String placeId;
  final String primaryText;
  final String secondaryText;
  final String? street;

  String get description => [primaryText, secondaryText].where((e) => e.isNotEmpty).join(' · ');
}

class PlaceDetails {
  PlaceDetails({
    required this.position,
    required this.formattedAddress,
  });

  final LatLng position;
  final String? formattedAddress;
}

class MapsService {
  MapsService({MapsApiClient? client}) : _client = client ?? MapsApiClient();

  final MapsApiClient _client;

  /// 获取地图API响应
  /// [path] 路径
  /// [params] 参数
  Future<Map<String, dynamic>> _get(
    String path, {
    required Map<String, String> params,
  }) async {
    final response = await _client.get<dynamic>(
      path,
      queryParameters: params,
    );
    final data = response.data;
    if (data == null) {
      throw Exception('Maps API 响应为空');
    }
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw Exception('Maps API 响应格式不正确: ${data.runtimeType}');
  }


  /// 获取地点自动补全
  /// [input] 输入
  /// [biasLocation] 偏置位置
  Future<List<PlaceSuggestion>> fetchAutocomplete(
    String input, {
    LatLng? biasLocation,
  }) async {
    if (input.trim().isEmpty) return const [];

    final params = <String, String>{
      'input': input,
      'key': MapsConfig.apiKey,
      'language': 'zh-CN',
      'types': 'geocode',
    };

    if (biasLocation != null) {
      params['location'] = '${biasLocation.latitude},${biasLocation.longitude}';
      params['radius'] = '50000';
    }

    final data = await _get(
      '/maps/api/place/autocomplete/json',
      params: params,
    );

    final status = data['status'] as String? ?? 'UNKNOWN_ERROR';
    if (status != 'OK') {
      if (status == 'ZERO_RESULTS') {
        return const [];
      }
      final errorMessage = data['error_message'] as String? ?? status;
      throw Exception('Places Autocomplete 错误: $errorMessage');
    }

    final predictions = data['predictions'] as List<dynamic>;
    return predictions.map((raw) {
      final map = raw as Map<String, dynamic>;
      final structured = map['structured_formatting'] as Map<String, dynamic>? ?? {};
      return PlaceSuggestion(
        placeId: map['place_id'] as String? ?? '',
        primaryText: structured['main_text'] as String? ?? '',
        secondaryText: structured['secondary_text'] as String? ?? '',
      );
    }).where((item) => item.placeId.isNotEmpty).toList();
  }

  /// 获取地点详情
  /// [placeId] 地点ID
  Future<PlaceDetails?> fetchPlaceDetails(String placeId) async {
    if (placeId.isEmpty) return null;
    final data = await _get(
      '/maps/api/place/details/json',
      params: <String, String>{
        'place_id': placeId,
        'fields': 'geometry/location,formatted_address',
        'language': 'zh-CN',
        'key': MapsConfig.apiKey,
      },
    );

    final status = data['status'] as String? ?? 'UNKNOWN_ERROR';
    if (status != 'OK') {
      final errorMessage = data['error_message'] as String? ?? status;
      throw Exception('Places Details 错误: $errorMessage');
    }

    final result = data['result'] as Map<String, dynamic>? ?? {};
    final geometry = result['geometry'] as Map<String, dynamic>? ?? {};
    final location = geometry['location'] as Map<String, dynamic>? ?? {};
    if (location.isEmpty) return null;

    final lat = (location['lat'] as num?)?.toDouble();
    final lng = (location['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;

    return PlaceDetails(
      position: LatLng(lat, lng),
      formattedAddress: result['formatted_address'] as String?,
    );
  }

  Future<String?> reverseGeocode(LatLng position) async {
    final data = await _get(
      '/maps/api/geocode/json',
      params: <String, String>{
        'latlng': '${position.latitude},${position.longitude}',
        'language': 'zh-CN',
        'key': MapsConfig.apiKey,
      },
    );

    final status = data['status'] as String? ?? 'UNKNOWN_ERROR';
    if (status != 'OK') {
      if (status == 'ZERO_RESULTS') {
        return null;
      }
      final errorMessage = data['error_message'] as String? ?? status;
      throw Exception('地理编码错误: $errorMessage');
    }

    final results = data['results'] as List<dynamic>;
    if (results.isEmpty) return null;
    final first = results.first as Map<String, dynamic>;
    return first['formatted_address'] as String?;
  }

  /// 获取附近地点
  /// [location] 位置
  /// [radius] 半径
  /// [language] 语言
  Future<List<PlaceSuggestion>> fetchNearbyPlaces(
    LatLng location, {
    int radius = 1000,
    String language = 'zh-CN',
  }) async {
    final data = await _get(
      '/maps/api/place/nearbysearch/json',
      params: <String, String>{
        'location': '${location.latitude},${location.longitude}',
        'radius': radius.toString(),
        'key': MapsConfig.apiKey,
        'language': language,
      },
    );

    final status = data['status'] as String? ?? 'UNKNOWN_ERROR';
    if (status != 'OK') {
      if (status == 'ZERO_RESULTS') {
        return const [];
      }
      final errorMessage = data['error_message'] as String? ?? status;
      throw Exception('Nearby Places 错误: $errorMessage');
    }

    final results = data['results'] as List<dynamic>? ?? const [];
    final suggestions = results.map((raw) {
      final map = raw as Map<String, dynamic>;
      final placeId = (map['place_id'] as String? ?? '').trim();
      final name = (map['name'] as String? ?? '').trim();
      final vicinity = (map['vicinity'] as String? ?? '').trim();
      final formattedAddress = (map['formatted_address'] as String? ?? '').trim();

      final primaryText = name.isNotEmpty
          ? name
          : (formattedAddress.isNotEmpty ? formattedAddress : vicinity);
      final secondaryText = vicinity.isNotEmpty
          ? vicinity
          : (formattedAddress.isNotEmpty ? formattedAddress : name);

      if (placeId.isEmpty || primaryText.isEmpty) {
        return null;
      }

      return PlaceSuggestion(
        placeId: placeId,
        primaryText: primaryText,
        secondaryText: secondaryText,
      );
    }).whereType<PlaceSuggestion>().toList();

    Logger.info('MapsService', 'Nearby places count: ${suggestions.length}');
    return suggestions;
  }

  /// 从完整地址中提取街道部分
  /// [formattedAddress] 完整格式化地址
  /// 返回街道部分（通常是第一个逗号之前的内容）
  static String extractStreetFromAddress(String? formattedAddress) {
    if (formattedAddress == null || formattedAddress.trim().isEmpty) {
      return '';
    }
    final trimmed = formattedAddress.trim();
    final commaIndex = trimmed.indexOf(',');
    if (commaIndex > 0) {
      return trimmed.substring(0, commaIndex).trim();
    }
    return trimmed;
  }
}

final MapsService mapsService = MapsService();

