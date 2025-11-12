import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../utils/logger/logger.dart';
import 'maps_service.dart';

const _sentinel = Object();

class MapPickerState {
  const MapPickerState({
    this.currentPosition,
    this.currentAddress,
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
  }) {
    return MapPickerState(
      currentPosition: currentPosition ?? this.currentPosition,
      currentAddress: identical(currentAddress, _sentinel)
          ? this.currentAddress
          : currentAddress as String?,
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
  }) {
    state = state.copyWith(
      currentPosition: position,
      selectedPlaceId: 'current_position',
    );
    setAddress(address, markAsCurrent: true);
    loadNearbyPlaces(position);
    if (address == null) {
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
      setAddress(address, markAsCurrent: true);
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

  void setSelectedPlace(String placeId) {
    state = state.copyWith(selectedPlaceId: placeId);
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

  void setAddress(String? address, {bool markAsCurrent = true}) {
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
