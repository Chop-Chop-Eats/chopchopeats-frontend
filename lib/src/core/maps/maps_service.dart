import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'maps_config.dart';

class PlaceSuggestion {
  PlaceSuggestion({
    required this.placeId,
    required this.primaryText,
    required this.secondaryText,
  });

  final String placeId;
  final String primaryText;
  final String secondaryText;

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
  MapsService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

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

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/autocomplete/json',
      params,
    );

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Places Autocomplete 请求失败: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
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

  Future<PlaceDetails?> fetchPlaceDetails(String placeId) async {
    if (placeId.isEmpty) return null;
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/details/json',
      {
        'place_id': placeId,
        'fields': 'geometry/location,formatted_address',
        'language': 'zh-CN',
        'key': MapsConfig.apiKey,
      },
    );

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Places Details 请求失败: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
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
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/geocode/json',
      {
        'latlng': '${position.latitude},${position.longitude}',
        'language': 'zh-CN',
        'key': MapsConfig.apiKey,
      },
    );

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('地理编码请求失败: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
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
}

final MapsService mapsService = MapsService();

