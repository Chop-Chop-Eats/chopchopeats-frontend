import 'dart:async';

import 'package:chop_user/src/core/utils/pop/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:unified_popups/unified_popups.dart';

import '../../l10n/app_localizations.dart';
import '../../routing/navigate.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_indicator.dart';
import '../../widgets/common_spacing.dart';
import '../../utils/logger/logger.dart';
import '../maps_config.dart';
import '../services/maps_service.dart';
import '../providers/map_providers.dart';
import '../widgets/map_nearby_sheet.dart';

class MapPickerArguments {
  MapPickerArguments({
    required this.initialPosition,
    this.initialAddress,
    this.enableReverseGeocode = true,
  });

  final LatLng initialPosition;
  final String? initialAddress;
  final bool enableReverseGeocode;
}

class MapPickerResult {
  MapPickerResult({
    required this.position,
    this.address,
    this.label,
    this.primaryText,
    this.secondaryText,
  });

  final LatLng position;
  final String? address;
  final String? label;
  final String? primaryText;
  final String? secondaryText;
}

class MapPickerPage extends ConsumerStatefulWidget {
  const MapPickerPage({super.key, required this.arguments});
  
  final MapPickerArguments arguments;

  @override
  ConsumerState<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends ConsumerState<MapPickerPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late final UniqueKey _mapViewKey;

  GoogleMapController? _mapController;
  Timer? _debounce;
  bool _isCameraMoving = false;
  bool _isNavigatingBack = false;
  bool _isKeyboardVisible = false; // 键盘状态标志

  @override
  void initState() {
    super.initState();
    _mapViewKey = UniqueKey();
    
    // 监听焦点变化（键盘显示/隐藏）
    _searchFocusNode.addListener(_onFocusChange);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(mapPickerProvider.notifier);
      Logger.info('MapPickerPage', 'initialAddress: ${widget.arguments.initialAddress}');
      notifier.reset();
      notifier.initialize(
        position: widget.arguments.initialPosition,
        address: widget.arguments.initialAddress,
      );
      _showSheetOnce();
    });
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onFocusChange); // 移除监听器
    _debounce?.cancel();
    // 页面销毁时，确保关闭所有打开的sheet
    if (PopupManager.hasNonToastPopup) {
      PopupManager.hideLastNonToast();
    }
    _mapController?.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// 监听焦点变化（键盘显示/隐藏）
  void _onFocusChange() {
    if (!mounted) return;
    
    final hasFocus = _searchFocusNode.hasFocus;
    
    // 键盘显示：关闭 sheet
    if (hasFocus && !_isKeyboardVisible) {
      _isKeyboardVisible = true;
      Logger.info('MapPickerPage', '键盘显示，关闭 sheet');
      if (PopupManager.hasNonToastPopup) {
        PopupManager.hideLastNonToast();
      }
    }
    // 键盘隐藏：显示 sheet
    else if (!hasFocus && _isKeyboardVisible) {
      _isKeyboardVisible = false;
      Logger.info('MapPickerPage', '键盘隐藏，显示 sheet');
      // 延迟一下，确保键盘完全收起后再显示 sheet
      Future.delayed(const Duration(milliseconds: 100), () {
        // 严格检查：确保页面仍然挂载且没有导航返回，且焦点仍然不在搜索框
        if (mounted && !_isNavigatingBack && !_searchFocusNode.hasFocus) {
          _showSheetOnce();
        }
      });
    }
  }

  Future<void> _handleCameraIdle() async {
    if (_isNavigatingBack || !_isCameraMoving) {
      return;
    }
    _isCameraMoving = false;

    final notifier = ref.read(mapPickerProvider.notifier);
    final mapState = ref.read(mapPickerProvider);
    final position = mapState.currentPosition;
    if (position == null) {
      return;
    }

    // 如果已经有 lastKnownPlace，且不是坐标格式的 secondaryText，说明已经有有效地址，不需要 reverseGeocode
    // 或者如果 currentLabel 包含 " · "，说明是从首页传入的有效地址格式，也不需要 reverseGeocode
    final hasValidLastKnownPlace = mapState.lastKnownPlace != null && (
        mapState.lastKnownPlace!.secondaryText != '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}' ||
        (mapState.currentLabel != null && mapState.currentLabel!.contains(' · '))
    );

    if (widget.arguments.enableReverseGeocode && !hasValidLastKnownPlace) {
      await notifier.resolveAddress(position);
    }

    await notifier.loadNearbyPlaces(position);
  }

  void _onCameraMove(CameraPosition position) {
    if (_isNavigatingBack) {
      return;
    }
    _isCameraMoving = true;
    ref.read(mapPickerProvider.notifier).updatePosition(position.target);
    _showSheetOnce();
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

  Future<void> _onSuggestionSelected(
    PlaceSuggestion suggestion, {
    bool closePicker = false,
  }) async {
    final notifier = ref.read(mapPickerProvider.notifier);
    final activeSuggestion = notifier.cacheSuggestion(suggestion);
    LatLng? targetPosition;
    String targetAddress = activeSuggestion.description;
    String targetLabel = activeSuggestion.description;
    Logger.info('MapPickerPage', 'onSuggestionSelected: ${activeSuggestion.description}, closePicker: $closePicker');
    if (notifier.isCurrentPositionSuggestion(activeSuggestion)) {
      final mapState = ref.read(mapPickerProvider);
      targetPosition = mapState.currentPosition;
      targetAddress = (mapState.currentAddress ?? activeSuggestion.primaryText).trim();
      final currentLabel = mapState.currentLabel?.trim();
      if (currentLabel != null && currentLabel.isNotEmpty) {
        targetLabel = currentLabel;
      } else if (targetLabel.trim().isEmpty && targetAddress.isNotEmpty) {
        targetLabel = targetAddress;
      }
      if (targetAddress.isEmpty) {
        targetAddress = targetLabel;
      }
      notifier.setSelectedPlace(
        suggestion: activeSuggestion,
        position: targetPosition,
        address: targetAddress,
        label: targetLabel,
        street: null,
      );
      if (targetPosition == null) {
        toast.warn(AppLocalizations.of(context)?.mapNoAddress ?? '暂无可用位置');
        return;
      }
      Logger.info('MapPickerPage', 'targetPosition: $targetPosition, targetAddress: $targetAddress');
      if (closePicker) {
        _isNavigatingBack = true;
        // 直接使用原始suggestion的primaryText和secondaryText
        Navigator.of(context).pop<MapPickerResult>(
          MapPickerResult(
            position: targetPosition,
            address: targetAddress,
            label: targetLabel,
            primaryText: activeSuggestion.primaryText,
            secondaryText: activeSuggestion.secondaryText,
          ),
        );
      } else {
        _searchController.text = targetLabel.isNotEmpty ? targetLabel : targetAddress;
        // 点击搜索结果后，清除搜索建议列表
        _clearSuggestions();
      }
      return;
    }

    try {
      final enrichedSuggestion = await notifier.ensureSuggestionDetails(activeSuggestion);
      targetPosition = enrichedSuggestion.position;
      if (targetPosition == null) {
        toast.warn(AppLocalizations.of(context)?.mapNoAddress ?? '暂无可用位置');
        return;
      }
      await _moveCamera(targetPosition);
      targetAddress = (enrichedSuggestion.address ?? suggestion.description).trim();
      if (targetAddress.isEmpty) {
        targetAddress = suggestion.description;
      }
      if (targetLabel.trim().isEmpty && targetAddress.isNotEmpty) {
        targetLabel = targetAddress;
      }
      notifier.updatePosition(targetPosition);
      notifier.setSelectedPlace(
        suggestion: enrichedSuggestion,
        position: targetPosition,
        address: targetAddress,
        label: targetLabel,
        street: enrichedSuggestion.street,
      );
      _searchController.text = targetLabel.isNotEmpty ? targetLabel : targetAddress;
      _searchFocusNode.unfocus();
      // 点击搜索结果后，清除搜索建议列表
      _clearSuggestions();
      if (closePicker) {
        if (!mounted) return;
        _isNavigatingBack = true;
        Navigator.of(context).pop<MapPickerResult>(
          MapPickerResult(
            position: targetPosition,
            address: targetAddress,
            label: targetLabel,
            primaryText: enrichedSuggestion.primaryText,
            secondaryText: enrichedSuggestion.secondaryText,
          ),
        );
      }
    } catch (e, stack) {
      Logger.error('MapPickerPage', '获取地点详情失败: $e\n$stack');
      if (!mounted) return;
      toast.warn(AppLocalizations.of(context)?.mapPlaceDetailFailed ?? '解析地点失败，请稍后重试');
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
      try {
        final position = ref.read(mapPickerProvider).currentPosition;
        await ref.read(mapPickerProvider.notifier).searchSuggestions(keyword, bias: position);
      } catch (e, stack) {
        Logger.error('MapPickerPage', '搜索建议失败: $e\n$stack');
        if (!mounted) return;
        toast.warn(AppLocalizations.of(context)?.mapSearchFailed ?? '搜索失败，请检查网络后重试');
      }
    });
  }


  Future<void> _showSheetOnce() async {
    // 严格检查：确保页面仍然挂载且没有导航返回
    if (!mounted || _isNavigatingBack) {
      return;
    }
    if (PopupManager.hasNonToastPopup) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    await Pop.sheet<void>(
      height: SheetDimension.fraction(0.48),
      maxHeight: SheetDimension.fraction(0.48),
      title: l10n.mapSelectLocationTitle ,
      showBarrier: false,
      childBuilder: (dismiss) => MapNearbySheet(
        dismiss: dismiss,
        onSelectPlace: (suggestion) => _onSuggestionSelected(suggestion, closePicker: true),
      ),
    );
  }


  void _clearSuggestions() {
    ref.read(mapPickerProvider.notifier).clearSuggestions();
  }

  Future<void> _useMyLocation() async {
    final l10n = AppLocalizations.of(context)!;
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      toast.warn(l10n.mapLocationServicesDisabled);
      return;
    }

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        if (!mounted) return;
        toast.warn(l10n.mapLocationPermissionDenied);
        return;
      }

      final current = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final target = LatLng(current.latitude, current.longitude);
      await _moveCamera(target);
      if (!mounted) return;
      final notifier = ref.read(mapPickerProvider.notifier);
      notifier.updatePosition(target);

      if (widget.arguments.enableReverseGeocode) {
        await notifier.resolveAddress(target);
      }
      await notifier.loadNearbyPlaces(target);
    } catch (e, stack) {
      Logger.error('MapPickerPage', '定位失败: $e\n$stack');
      if (!mounted) return;
      toast.warn(l10n.mapLocationFetchFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapPickerProvider);
    final l10n = AppLocalizations.of(context)!;
    final searchHint = l10n.mapSearchHint;
    final myLocationTooltip = l10n.mapUseMyLocation;
    // 始终使用传入的初始位置，确保地图显示的是应用的当前位置
    final currentPosition = widget.arguments.initialPosition;
    
    // 计算地图padding：底部44%（让地图显示为56%高度，更美观）
    final screenHeight = MediaQuery.of(context).size.height;
    final mapBottomPadding = screenHeight * 0.44;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        // 页面返回时，确保关闭所有打开的sheet
        if (didPop && PopupManager.hasNonToastPopup) {
          PopupManager.hideLastNonToast();
        }
      },
      child: Scaffold(
        appBar: null,
        body: Stack(
        children: [
          GoogleMap(
            key: _mapViewKey,
            initialCameraPosition: CameraPosition(
              target: currentPosition,
              zoom: MapsConfig.defaultZoom,
            ),
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            padding: EdgeInsets.only(
              bottom: mapBottomPadding,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onCameraMove: _onCameraMove,
            onCameraIdle: _handleCameraIdle,
            markers: {
              Marker(
                markerId: const MarkerId('selected_location'),
                position: mapState.currentPosition ?? currentPosition,
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
                _buildHeader(searchHint, mapState),
                _buildSuggestionsList(mapState),
              ],
            ),
          ),
          if (!_isKeyboardVisible)
            Positioned(
              right: 16.w,
              bottom: MediaQuery.of(context).size.height * 0.48  + 24.h,
              child: _buildMyLocationButton(myLocationTooltip),
            ),
        ],
      ),
      ),
    );
  }

  Widget _buildHeader(String searchHint, MapPickerState state) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            // 检查是否有
            Logger.info('MapPickerPage', '检查是否有非Toast弹窗: ${PopupManager.hasNonToastPopup}');
            if (PopupManager.hasNonToastPopup) {
              PopupManager.hideLastNonToast();
            }
            _isNavigatingBack = true;
            Navigate.pop(context);
          },
          child: CircleAvatar(
            radius: 18.r,
            backgroundColor: Colors.white,
            child: Center(
              child: Icon(Icons.arrow_back_ios_new, size: 18.w, color: Colors.black),
            ),
          ),
        ),
        Expanded(
          child: _buildSearchField(searchHint, state), 
        ),
      ],
    );
  }

  Widget _buildSuggestionsList(MapPickerState state) {
    final suggestions = state.suggestions;
    if (suggestions.isEmpty) {
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
            final item = suggestions[index];
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
          itemCount: suggestions.length,
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

  Widget _buildSearchField(String hintText, MapPickerState state) {
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
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder: (_, value, __) {
              if (state.isSearching) {
                return Padding(
                  padding: EdgeInsets.all(6.w),
                  child: const SizedBox(
                    width: 16,
                    height: 16,
                    child: CommonIndicator(size: 16),
                  ),
                );
              }
              if (value.text.isEmpty) {
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