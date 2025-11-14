import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../utils/logger/logger.dart';
import 'maps_service.dart';

const _sentinel = Object();

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
    );
  }
}

class MapPickerNotifier extends StateNotifier<MapPickerState> {
  MapPickerNotifier() : super(const MapPickerState());

  void reset() {
    state = const MapPickerState();
  }

  void initialize({
    required LatLng position,
    String? address,
    String? label,
  }) {
    state = state.copyWith(
      currentPosition: position,
      selectedPlaceId: 'current_position',
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
        placeId: 'current_position',
        primaryText: primaryText,
        secondaryText: secondaryText ?? '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
      );
      state = state.copyWith(
        lastKnownPlace: placeForDisplay,
        currentAddress: address,
        selectedPlaceId: 'current_position',
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
    );
    try {
      final places = await mapsService.fetchNearbyPlaces(position);
      state = state.copyWith(nearbyPlaces: places);
    } catch (e, stack) {
      Logger.error('MapPickerNotifier', '获取周边地点失败: $e', stackTrace: stack);
    } finally {
      state = state.copyWith(
        isNearbyLoading: false,
        isNearbyUpdating: false,
      );
    }
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
    final placeForDisplay = PlaceSuggestion(
      placeId: suggestion.placeId,
      primaryText: suggestion.primaryText,
      secondaryText: suggestion.secondaryText,
      street: street ?? suggestion.street,
    );

    state = state.copyWith(
      selectedPlaceId: suggestion.placeId,
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
      state = state.copyWith(suggestions: items);
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
            placeId: 'current_position',
            primaryText: address,
            secondaryText:
                '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
          )
        : null;
    state = state.copyWith(
      currentAddress: address,
      lastKnownPlace: place,
      currentLabel: label ?? state.currentLabel,
      selectedPlaceId: markAsCurrent ? 'current_position' : state.selectedPlaceId,
    );
  }

  void setNearbyPlaces(List<PlaceSuggestion> places) {
    state = state.copyWith(nearbyPlaces: places);
  }
}

final mapPickerProvider =
    StateNotifierProvider<MapPickerNotifier, MapPickerState>(
  (ref) => MapPickerNotifier(),
);
