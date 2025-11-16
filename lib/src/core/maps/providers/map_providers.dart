import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../utils/logger/logger.dart';
import '../services/maps_service.dart';

const _sentinel = Object();
const _currentPositionId = 'current_position';

class MapPickerState {
  /// 构造函数  
  /// [currentPosition] 当前位置
  /// [currentAddress] 当前地址
  /// [currentLabel] 当前标签
  /// [isSearching] 是否正在搜索
  /// [isResolvingAddress] 是否正在解析地址
  /// [isNearbyLoading] 是否正在加载附近地点
  /// [isNearbyUpdating] 是否正在更新附近地点
  /// [suggestions] 搜索建议
  /// [nearbyPlaces] 附近地点
  /// [lastKnownPlace] 最后一次已知地点
  /// [selectedPlaceId] 选中的地点ID
  const MapPickerState({
    this.currentPosition,
    this.currentAddress,
    this.currentLabel,
    this.isSearching = false,
    this.isResolvingAddress = false,
    this.isNearbyLoading = false,
    this.isNearbyUpdating = false,
    this.suggestions = const <PlaceSuggestion>[],
    this.nearbyPlaces = const <PlaceSuggestion>[],
    this.lastKnownPlace,
    this.selectedPlaceId,
    this.nearbyError,
    this.nearbyRetryCount = 0,
  });

  final LatLng? currentPosition;
  final String? currentAddress;
  final String? currentLabel;
  final bool isSearching;
  final bool isResolvingAddress;
  final bool isNearbyLoading;
  final bool isNearbyUpdating;
  final List<PlaceSuggestion> suggestions;
  final List<PlaceSuggestion> nearbyPlaces;
  final PlaceSuggestion? lastKnownPlace;
  final String? selectedPlaceId;
  final String? nearbyError;
  final int nearbyRetryCount;

  MapPickerState copyWith({
    LatLng? currentPosition,
    Object? currentAddress = _sentinel,
    bool? isSearching,
    bool? isResolvingAddress,
    bool? isNearbyLoading,
    bool? isNearbyUpdating,
    List<PlaceSuggestion>? suggestions,
    List<PlaceSuggestion>? nearbyPlaces,
    Object? lastKnownPlace = _sentinel,
    Object? selectedPlaceId = _sentinel,
    Object? currentLabel = _sentinel,
    Object? nearbyError = _sentinel,
    int? nearbyRetryCount,
  }) {
    return MapPickerState(
      currentPosition: currentPosition ?? this.currentPosition,
      currentAddress: identical(currentAddress, _sentinel)
          ? this.currentAddress
          : currentAddress as String?,
      currentLabel: identical(currentLabel, _sentinel)
          ? this.currentLabel
          : currentLabel as String?,
      isSearching: isSearching ?? this.isSearching,
      isResolvingAddress: isResolvingAddress ?? this.isResolvingAddress,
      isNearbyLoading: isNearbyLoading ?? this.isNearbyLoading,
      isNearbyUpdating: isNearbyUpdating ?? this.isNearbyUpdating,
      suggestions: suggestions ?? this.suggestions,
      nearbyPlaces: nearbyPlaces ?? this.nearbyPlaces,
      lastKnownPlace: identical(lastKnownPlace, _sentinel)
          ? this.lastKnownPlace
          : lastKnownPlace as PlaceSuggestion?,
      selectedPlaceId: identical(selectedPlaceId, _sentinel)
          ? this.selectedPlaceId
          : selectedPlaceId as String?,
      nearbyError: identical(nearbyError, _sentinel)
          ? this.nearbyError
          : nearbyError as String?,
      nearbyRetryCount: nearbyRetryCount ?? this.nearbyRetryCount,
    );
  }
}

class MapPickerNotifier extends StateNotifier<MapPickerState> {
  MapPickerNotifier() : super(const MapPickerState());

  final Map<String, PlaceSuggestion> _placeCache = <String, PlaceSuggestion>{};
  String _coordsKey(LatLng position) =>
      'coords_${position.latitude.toStringAsFixed(6)}_${position.longitude.toStringAsFixed(6)}';

  String _buildSuggestionKey(
    PlaceSuggestion suggestion, {
    LatLng? fallbackPosition,
  }) {
    if (suggestion.placeId.isNotEmpty &&
        suggestion.placeId != _currentPositionId) {
      return suggestion.placeId;
    }
    final LatLng? position = suggestion.position ?? fallbackPosition;
    if (position != null) {
      return _coordsKey(position);
    }
    return suggestion.primaryText;
  }

  String suggestionKey(PlaceSuggestion suggestion) =>
      _buildSuggestionKey(suggestion);

  bool isCurrentPositionSuggestion(PlaceSuggestion suggestion) =>
      suggestion.placeId == _currentPositionId;

  PlaceSuggestion _cacheSuggestion(PlaceSuggestion suggestion) {
    if (suggestion.placeId.isEmpty) {
      return suggestion;
    }
    final cached = _placeCache[suggestion.placeId];
    if (cached == null) {
      _placeCache[suggestion.placeId] = suggestion;
      return suggestion;
    }
    final merged = cached.merge(suggestion);
    _placeCache[suggestion.placeId] = merged;
    return merged;
  }

  List<PlaceSuggestion> _cacheSuggestions(List<PlaceSuggestion> items) {
    return items.map(_cacheSuggestion).toList();
  }

  PlaceSuggestion cacheSuggestion(PlaceSuggestion suggestion) => _cacheSuggestion(suggestion);

  Future<PlaceSuggestion> ensureSuggestionDetails(PlaceSuggestion suggestion) async {
    if (suggestion.placeId.isEmpty || suggestion.placeId == 'current_position') {
      return suggestion;
    }

    final cached = _placeCache[suggestion.placeId];
    final candidate = cached?.merge(suggestion) ?? suggestion;
    final hasPosition = candidate.position != null;
    final hasAddress = (candidate.address ?? '').trim().isNotEmpty;

    if (hasPosition && hasAddress) {
      return _cacheSuggestion(candidate);
    }

    try {
      final details = await mapsService.fetchPlaceDetails(suggestion.placeId);
      if (details == null) {
        return _cacheSuggestion(candidate);
      }
      final enriched = PlaceSuggestion(
        placeId: suggestion.placeId,
        primaryText: suggestion.primaryText,
        secondaryText: suggestion.secondaryText,
        street: details.street ?? candidate.street,
        position: details.position,
        address: details.formattedAddress ?? candidate.address,
      );
      return _cacheSuggestion(enriched);
    } catch (e, stack) {
      Logger.error('MapPickerNotifier', '获取地点详情失败: $e', stackTrace: stack);
      return _cacheSuggestion(candidate);
    }
  }

  void reset() {
    _placeCache.clear();
    state = const MapPickerState();
  }

  void initialize({
    required LatLng position,
    String? address,
    String? label,
  }) {
    final initialKey = _coordsKey(position);
    state = state.copyWith(
      currentPosition: position,
      selectedPlaceId: initialKey,
      currentLabel: label ?? address,
    );
    
    // 如果label是"primaryText · secondaryText"格式，解析它来创建lastKnownPlace
    String? primaryText;
    String? secondaryText;
    if (label != null && label.contains(' · ')) {
      final parts = label.split(' · ');
      primaryText = parts.isNotEmpty ? parts[0].trim() : null;
      secondaryText = parts.length > 1 ? parts[1].trim() : null;
    } else if (address != null) {
      // 如果没有label，使用address作为primaryText
      primaryText = address;
    }
    
    // 创建lastKnownPlace
    if (primaryText != null) {
      final placeForDisplay = PlaceSuggestion(
        placeId: _currentPositionId,
        primaryText: primaryText,
        secondaryText: secondaryText ?? '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
        position: position,
        address: address ?? label,
      );
      final placeKey = _buildSuggestionKey(placeForDisplay, fallbackPosition: position);
      state = state.copyWith(
        lastKnownPlace: _cacheSuggestion(placeForDisplay),
        currentAddress: address,
        selectedPlaceId: placeKey,
      );
    } else {
      setAddress(address, label: label, markAsCurrent: true);
    }
    
    loadNearbyPlaces(position);
    if (address == null && primaryText == null) {
      resolveAddress(position);
    }
  }

  void updatePosition(LatLng position) {
    state = state.copyWith(currentPosition: position);
  }

  Future<void> resolveAddress(LatLng position) async {
    state = state.copyWith(isResolvingAddress: true);
    try {
      final address = await mapsService.reverseGeocode(position);
      setAddress(
        address,
        label: address,
        markAsCurrent: true,
      );
    } catch (e, stack) {
      Logger.error('MapPickerNotifier', '解析地址失败: $e', stackTrace: stack);
    } finally {
      state = state.copyWith(isResolvingAddress: false);
    }
  }

  Future<void> loadNearbyPlaces(LatLng position) async {
    final isFirstLoad = state.nearbyPlaces.isEmpty;
    state = state.copyWith(
      isNearbyLoading: isFirstLoad ? true : state.isNearbyLoading,
      isNearbyUpdating: !isFirstLoad,
      nearbyError: null,
      nearbyRetryCount: 0,
    );

    const maxAttempts = 3;
    var attempt = 0;
    String? lastError;
    List<PlaceSuggestion>? places;

    while (attempt < maxAttempts) {
      try {
        final fetched = await mapsService.fetchNearbyPlaces(position);
        places = fetched;
        break;
      } catch (e, stack) {
        attempt++;
        lastError = e.toString();
        Logger.error(
          'MapPickerNotifier',
          '获取周边地点失败 (attempt $attempt/$maxAttempts): $e',
          stackTrace: stack,
        );
        if (attempt < maxAttempts) {
          await Future.delayed(const Duration(milliseconds: 400));
        }
      }
    }

    if (places != null) {
      state = state.copyWith(
        nearbyPlaces: _cacheSuggestions(places),
        isNearbyLoading: false,
        isNearbyUpdating: false,
        nearbyError: null,
        nearbyRetryCount: 0,
      );
    } else {
      state = state.copyWith(
        isNearbyLoading: false,
        isNearbyUpdating: false,
        nearbyError: lastError ?? '周边地点加载失败',
        nearbyRetryCount: attempt,
      );
    }
  }

  Future<void> retryLoadNearbyPlaces() async {
    final position = state.currentPosition;
    if (position == null) return;
    await loadNearbyPlaces(position);
  }

  void setSelectedPlace({
    required PlaceSuggestion suggestion,
    LatLng? position,
    String? address,
    String? label,
    String? street,
  }) {
    final targetPosition = position ?? state.currentPosition;
    final resolvedAddress = address ?? suggestion.primaryText;
    final resolvedLabel = label ?? suggestion.primaryText;

    // 使用原始suggestion的primaryText和secondaryText，不要使用格式化地址和坐标
    final placeForDisplay = _cacheSuggestion(
      PlaceSuggestion(
        placeId: suggestion.placeId,
        primaryText: suggestion.primaryText,
        secondaryText: suggestion.secondaryText,
        street: street ?? suggestion.street,
        position: suggestion.position ?? targetPosition,
        address: suggestion.address ?? resolvedAddress,
      ),
    );
    final selectedKey =
        _buildSuggestionKey(placeForDisplay, fallbackPosition: targetPosition);

    state = state.copyWith(
      selectedPlaceId: selectedKey,
      currentPosition: targetPosition ?? state.currentPosition,
      currentAddress: resolvedAddress,
      currentLabel: resolvedLabel,
      lastKnownPlace: placeForDisplay,
    );
  }

  Future<void> searchSuggestions(String keyword, {LatLng? bias}) async {
    if (keyword.trim().isEmpty) {
      state = state.copyWith(suggestions: const []);
      return;
    }
    state = state.copyWith(isSearching: true);
    try {
      final items = await mapsService.fetchAutocomplete(
        keyword,
        biasLocation: bias,
      );
      state = state.copyWith(suggestions: _cacheSuggestions(items));
    } catch (e, stack) {
      Logger.error('MapPickerNotifier', '搜索建议失败: $e', stackTrace: stack);
    } finally {
      state = state.copyWith(isSearching: false);
    }
  }

  void clearSuggestions() {
    state = state.copyWith(suggestions: const []);
  }

  void setAddress(
    String? address, {
    String? label,
    bool markAsCurrent = true,
  }) {
    final position = state.currentPosition;
    final place = (address != null && position != null)
        ? PlaceSuggestion(
            placeId: _currentPositionId,
            primaryText: address,
            secondaryText:
                '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
            address: address,
            position: position,
          )
        : null;
    final placeKey =
        place != null ? _buildSuggestionKey(place, fallbackPosition: position) : null;
    state = state.copyWith(
      currentAddress: address,
      lastKnownPlace: place != null ? _cacheSuggestion(place) : null,
      currentLabel: label ?? state.currentLabel,
      selectedPlaceId: markAsCurrent ? placeKey : state.selectedPlaceId,
    );
  }

  void setNearbyPlaces(List<PlaceSuggestion> places) {
    state = state.copyWith(nearbyPlaces: _cacheSuggestions(places));
  }
}

final mapPickerProvider =
    StateNotifierProvider<MapPickerNotifier, MapPickerState>(
  (ref) => MapPickerNotifier(),
);
