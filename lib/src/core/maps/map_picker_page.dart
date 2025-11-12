import 'dart:async';

import 'package:chop_user/src/core/utils/pop/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:unified_popups/unified_popups.dart';

import '../l10n/app_localizations.dart';
import '../routing/navigate.dart';
import '../theme/app_theme.dart';
import '../widgets/common_indicator.dart';
import '../widgets/common_spacing.dart';
import '../utils/logger/logger.dart';
import 'maps_config.dart';
import 'maps_service.dart';

class MapPickerArguments {
  MapPickerArguments({
    required this.initialPosition,
    this.initialAddress,
    this.title,
    this.confirmText,
    this.searchHint,
    this.enableReverseGeocode = true,
  });

  final LatLng initialPosition;
  final String? initialAddress;
  final String? title;
  final String? confirmText;
  final String? searchHint;
  final bool enableReverseGeocode;
}

class MapPickerResult {
  MapPickerResult({
    required this.position,
    this.address,
  });

  final LatLng position;
  final String? address;
}

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key, required this.arguments});

  final MapPickerArguments arguments;

  static Future<MapPickerResult?> open(
    BuildContext context, {
    required MapPickerArguments arguments,
  }) {
    return Navigator.of(context).push<MapPickerResult>(
      MaterialPageRoute<MapPickerResult>(
        builder: (_) => MapPickerPage(arguments: arguments),
      ),
    );
  }

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ValueNotifier<bool> _isSearching = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isResolvingAddress = ValueNotifier<bool>(false);
  final List<PlaceSuggestion> _suggestions = <PlaceSuggestion>[];
  final ValueNotifier<List<PlaceSuggestion>> _nearbyPlaces =
      ValueNotifier<List<PlaceSuggestion>>(<PlaceSuggestion>[]);
  late final UniqueKey _mapViewKey;

  GoogleMapController? _mapController;
  late LatLng _currentPosition;
  String? _currentAddress;
  Timer? _debounce;
  bool _isCameraMoving = false;
  bool _hasShownSheet = false;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.arguments.initialPosition;
    _currentAddress = widget.arguments.initialAddress;
    _mapViewKey = UniqueKey();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshNearbyPlaces();
      _showSheetOnce();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _mapController?.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _isSearching.dispose();
    _isResolvingAddress.dispose();
    _nearbyPlaces.dispose();
    super.dispose();
  }

  Future<void> _handleCameraIdle() async {
    if (!_isCameraMoving) {
      return;
    }
    _isCameraMoving = false;

    if (widget.arguments.enableReverseGeocode) {
      _isResolvingAddress.value = true;
      try {
        final address = await mapsService.reverseGeocode(_currentPosition);
        if (!mounted) return;
        setState(() {
          _currentAddress = address;
        });
      } catch (e, stack) {
        Logger.error('MapPickerPage', '反向地理编码失败: $e\n$stack');
      } finally {
        if (mounted) {
          _isResolvingAddress.value = false;
        }
      }
    }

    if (!mounted) return;
    await _refreshNearbyPlaces();
  }

  void _onCameraMove(CameraPosition position) {
    _isCameraMoving = true;
    _currentPosition = position.target;
  }

  Future<void> _moveCamera(LatLng target) async {
    await _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: target,
          zoom: MapsConfig.defaultZoom,
        ),
      ),
    );
  }

  Future<void> _refreshNearbyPlaces() async {
    try {
      final places = await mapsService.fetchNearbyPlaces(_currentPosition);
      if (!mounted) return;
      _nearbyPlaces.value = places;
    } catch (e, stack) {
      Logger.error('MapPickerPage', '获取周边地点失败: $e\n$stack');
    }
  }

  Future<void> _onSuggestionSelected(PlaceSuggestion suggestion) async {
    _isSearching.value = true;
    try {
      final details = await mapsService.fetchPlaceDetails(suggestion.placeId);
      if (details == null) return;
      await _moveCamera(details.position);
      if (!mounted) return;
      setState(() {
        _currentPosition = details.position;
        _currentAddress = details.formattedAddress ?? suggestion.description;
      });
      await _refreshNearbyPlaces();
      _searchController.text = suggestion.description;
      _clearSuggestions();
      _searchFocusNode.unfocus();
    } catch (e, stack) {
      Logger.error('MapPickerPage', '获取地点详情失败: $e\n$stack');
      if (!mounted) return;
      toast.warn(AppLocalizations.of(context)?.mapPlaceDetailFailed ?? '解析地点失败，请稍后重试');
    } finally {
      if (mounted) {
        _isSearching.value = false;
      }
    }
  }

  Future<void> _onSearchChanged(String value) async {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      if (!mounted) return;
      final keyword = value.trim();
      if (keyword.isEmpty) {
        _clearSuggestions();
        return;
      }
      _isSearching.value = true;
      
      //  _searchFocusNode.unfocus(); // 收起键盘

      try {
        final items = await mapsService.fetchAutocomplete(
          keyword,
          biasLocation: _currentPosition,
        );
        if (!mounted) return;
        setState(() {
          _suggestions
            ..clear()
            ..addAll(items);
        });
      } catch (e, stack) {
        Logger.error('MapPickerPage', '搜索建议失败: $e\n$stack');
        if (!mounted) return;
        toast.warn(AppLocalizations.of(context)?.mapSearchFailed ?? '搜索失败，请检查网络后重试');
      } finally {
        if (mounted) {
          _isSearching.value = false;
        }
      }
    });
  }


  Future<void> _showSheetOnce() async {
    if (_hasShownSheet) {
      return;
    }
    _hasShownSheet = true;
    await Pop.sheet<void>(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      maxHeight: SheetDimension.fraction(0.4),
      showBarrier: false,
      childBuilder: (dismiss) {
        return ValueListenableBuilder<List<PlaceSuggestion>>(
          valueListenable: _nearbyPlaces,
          builder: (_, places, __) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _isResolvingAddress,
                        builder: (_, resolving, __) {
                          if (resolving) {
                            return Row(
                              children: [
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CommonIndicator(size: 16),
                                ),
                                CommonSpacing.width(8),
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)?.mapResolvingAddress ?? '正在解析位置...',
                                    style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            );
                          }
                          return Text(
                            _currentAddress ?? '',
                            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600),
                          );
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        dismiss();
                        _onConfirmPosition();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        child: Text(
                          widget.arguments.confirmText ?? '确定位置',
                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppTheme.primaryOrange),
                        ),
                      ),
                    ),
                  ],
                ),
                CommonSpacing.small,
                if (places.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Text(
                      AppLocalizations.of(context)?.emptyListText ?? '暂无周边地点',
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 240.h),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemBuilder: (_, index) {
                        final item = places[index];
                        return GestureDetector(
                          onTap: () {
                            _onSuggestionSelected(item);
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 12.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.primaryText,
                                  style: TextStyle(fontSize: 15.sp, color: Colors.black, fontWeight: FontWeight.w500),
                                ),
                                CommonSpacing.small,
                                Text(
                                  item.secondaryText,
                                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[500], fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const Divider(height: 0.5),
                      itemCount: places.length,
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }


  void _clearSuggestions() {
    setState(() {
      _suggestions.clear();
    });
  }

  Future<void> _useMyLocation() async {
    final l10n = AppLocalizations.of(context);
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      toast.warn(l10n?.mapLocationServicesDisabled ?? '定位服务未开启，请先打开设备定位');
      return;
    }

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        if (!mounted) return;
        toast.warn(l10n?.mapLocationPermissionDenied ?? '定位权限被拒绝，请前往系统设置开启权限');
        return;
      }

      final current = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final target = LatLng(current.latitude, current.longitude);
      await _moveCamera(target);
      if (!mounted) return;
      setState(() {
        _currentPosition = target;
      });

      if (widget.arguments.enableReverseGeocode) {
        _isResolvingAddress.value = true;
        try {
          final address = await mapsService.reverseGeocode(target);
          if (mounted) {
            setState(() {
              _currentAddress = address;
            });
          }
        } finally {
          if (mounted) {
            _isResolvingAddress.value = false;
          }
        }
      }
      await _refreshNearbyPlaces();
    } catch (e, stack) {
      Logger.error('MapPickerPage', '定位失败: $e\n$stack');
      if (!mounted) return;
      toast.warn(l10n?.mapLocationFetchFailed ?? '无法获取当前位置，请稍后再试');
    }
  }

  void _onConfirmPosition() {
    Navigator.of(context).pop<MapPickerResult>(
      MapPickerResult(
        position: _currentPosition,
        address: _currentAddress,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final searchHint = widget.arguments.searchHint ?? l10n?.mapSearchHint ?? '搜索地点或地址';
    final myLocationTooltip = l10n?.mapUseMyLocation ?? '使用当前位置';

    // 顶部是搜素框和返回按钮 右侧是 confirm position  底部是搜索结果 用pop.sheet展示 
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          GoogleMap(
            key: _mapViewKey,
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: MapsConfig.defaultZoom,
            ),
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            onMapCreated: (controller) => _mapController = controller,
            onCameraMove: _onCameraMove,
            onCameraIdle: _handleCameraIdle,
            markers: {
              Marker(
                markerId: const MarkerId('selected_location'),
                position: _currentPosition,
                draggable: false,
              ),
            },
          ),
          Positioned(
            left: 16.w,
            right: 16.w,
            top: MediaQuery.of(context).padding.top + 4.h, // 安全区域距离
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(searchHint),
                _buildSuggestionsList(),
              ],
            ),
          ),
          Positioned(
            right: 16.w,
            bottom: 24.h,
            child: _buildMyLocationButton(myLocationTooltip),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String searchHint) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigate.pop(context),
          child: CircleAvatar(
            radius: 18.r,
            backgroundColor: Colors.white,
            child: Center(
              child: Icon(Icons.arrow_back_ios_new, size: 18.w, color: Colors.black),
            ),
          ),
        ),
        Expanded(
          child: _buildSearchField(searchHint), 
        ),
      ],
    );
  }

  Widget _buildSuggestionsList() {
    if (_suggestions.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 240.h),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.symmetric(vertical: 6.h),
          itemBuilder: (_, index) {
            final item = _suggestions[index];
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _onSuggestionSelected(item),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.primaryText,
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.black),
                    ),
                    CommonSpacing.small,
                    Text(
                      item.secondaryText,
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w400, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (_, __) => Divider(height: 1.h, color: Colors.grey[200]),
          itemCount: _suggestions.length,
        ),
      ),
    );
  }

  Widget _buildMyLocationButton(String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 4,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: _useMyLocation,
          child: SizedBox(
            width: 48.w,
            height: 48.w,
            child: Icon(
              Icons.my_location,
              color: AppTheme.primaryOrange,
              size: 24.w,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(String hintText) {
    return Container(
      margin: EdgeInsets.only(left: 8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(48.r),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: _onSearchChanged,
        style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          isDense: true,
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Icon(Icons.search, size: 20.w),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: ValueListenableBuilder<bool>(
            valueListenable: _isSearching,
            builder: (_, value, __) {
              if (value) {
                return Padding(
                  padding: EdgeInsets.all(6.w),
                  child: const SizedBox(
                    width: 16,
                    height: 16,
                    child: CommonIndicator(size: 16),
                  ),
                );
              }
              if (_searchController.text.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _clearSuggestions();
                },
              );
            },
          ),
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[500], fontWeight: FontWeight.w400),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(48.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
        ),
      ),
    );
  }

}

