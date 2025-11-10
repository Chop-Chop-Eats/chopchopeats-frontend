import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../l10n/app_localizations.dart';
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

  GoogleMapController? _mapController;
  late LatLng _currentPosition;
  String? _currentAddress;
  Timer? _debounce;
  bool _isCameraMoving = false;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.arguments.initialPosition;
    _currentAddress = widget.arguments.initialAddress;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _mapController?.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _isSearching.dispose();
    _isResolvingAddress.dispose();
    super.dispose();
  }

  Future<void> _handleCameraIdle() async {
    if (!_isCameraMoving || !widget.arguments.enableReverseGeocode) {
      return;
    }
    _isCameraMoving = false;
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
      _searchController.text = suggestion.description;
      _clearSuggestions();
      _searchFocusNode.unfocus();
    } catch (e, stack) {
      Logger.error('MapPickerPage', '获取地点详情失败: $e\n$stack');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.mapPlaceDetailFailed ?? '解析地点失败，请稍后重试',
          ),
        ),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.mapSearchFailed ?? '搜索失败，请检查网络后重试',
            ),
          ),
        );
      } finally {
        if (mounted) {
          _isSearching.value = false;
        }
      }
    });
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.mapLocationServicesDisabled ?? '定位服务未开启，请先打开设备定位',
          ),
        ),
      );
      return;
    }

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.mapLocationPermissionDenied ?? '定位权限被拒绝，请前往系统设置开启权限',
            ),
          ),
        );
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
    } catch (e, stack) {
      Logger.error('MapPickerPage', '定位失败: $e\n$stack');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.mapLocationFetchFailed ?? '无法获取当前位置，请稍后再试',
          ),
        ),
      );
    }
  }

  void _onConfirm() {
    Navigator.of(context).pop<MapPickerResult>(
      MapPickerResult(
        position: _currentPosition,
        address: _currentAddress,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final resolvedTitle = widget.arguments.title ?? l10n?.mapSelectLocationTitle ?? '选择位置';
    final confirmText = widget.arguments.confirmText ?? l10n?.mapConfirmLocation ?? '确定位置';
    final searchHint = widget.arguments.searchHint ?? l10n?.mapSearchHint ?? '搜索地点或地址';
    final myLocationTooltip = l10n?.mapUseMyLocation ?? '使用当前位置';
    return Scaffold(
      appBar: AppBar(
        title: Text(resolvedTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_outlined),
            onPressed: _useMyLocation,
            tooltip: myLocationTooltip,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
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
            top: 16.h,
            child: _buildSearchField(theme, searchHint),
          ),
          _buildSuggestionList(theme),
          Positioned(
            left: 16.w,
            right: 16.w,
            bottom: 32.h,
            child: _buildAddressCard(theme, l10n),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _onConfirm,
            child: Text(confirmText),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme, String hintText) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12.r),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          suffixIcon: ValueListenableBuilder<bool>(
            valueListenable: _isSearching,
            builder: (_, value, __) {
              if (value) {
                return Padding(
                  padding: EdgeInsets.all(12.w),
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
      ),
    );
  }

  Widget _buildSuggestionList(ThemeData theme) {
    if (_suggestions.isEmpty) return const SizedBox.shrink();
    return Positioned(
      left: 16.w,
      right: 16.w,
      top: 76.h,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12.r),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 260.h,
          ),
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemBuilder: (_, index) {
              final item = _suggestions[index];
              return ListTile(
                leading: const Icon(Icons.place_outlined),
                title: Text(
                  item.primaryText,
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: item.secondaryText.isEmpty ? null : Text(item.secondaryText),
                onTap: () => _onSuggestionSelected(item),
              );
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: _suggestions.length,
          ),
        ),
      ),
    );
  }

  Widget _buildAddressCard(ThemeData theme, AppLocalizations? l10n) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16.r),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.mapSelectedLocationLabel ?? '选定位置',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            CommonSpacing.small,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined),
                CommonSpacing.width(8.w),
                Expanded(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _isResolvingAddress,
                    builder: (_, value, __) {
                      if (value) {
                        return Row(
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CommonIndicator(size: 16),
                            ),
                            CommonSpacing.width(8.w),
                            Text(l10n?.mapResolvingAddress ?? '正在解析地址...'),
                          ],
                        );
                      }
                      final address = _currentAddress;
                      if (address == null || address.isEmpty) {
                        return Text(l10n?.mapNoAddress ?? '未找到准确地址，请调整图钉位置');
                      }
                      return Text(address);
                    },
                  ),
                ),
              ],
            ),
            CommonSpacing.small,
            Text(
              l10n?.mapCoordinateLabel(
                    _currentPosition.latitude,
                    _currentPosition.longitude,
                  ) ??
                  '纬度: ${_currentPosition.latitude.toStringAsFixed(6)}\n经度: ${_currentPosition.longitude.toStringAsFixed(6)}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

