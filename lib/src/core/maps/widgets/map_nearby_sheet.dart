import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../utils/logger/logger.dart';
import '../../widgets/common_indicator.dart';
import '../../widgets/common_spacing.dart';
import '../map_providers.dart';
import '../maps_service.dart';

class MapNearbySheet extends ConsumerWidget {
  const MapNearbySheet({
    super.key,
    required this.dismiss,
    required this.onSelectPlace,
  });

  final VoidCallback dismiss;
  final Future<void> Function(PlaceSuggestion suggestion) onSelectPlace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mapPickerProvider);
    final l10n = AppLocalizations.of(context);

    // 构建显示列表：lastKnownPlace作为第一项，然后过滤掉重复的item
    final List<PlaceSuggestion> displayPlaces = [];
    if (state.lastKnownPlace != null) {
      displayPlaces.add(state.lastKnownPlace!);
    }
    // 过滤掉current_position、已经在lastKnownPlace中的item（通过placeId比较），以及当前选中的item
    // 注意：如果内容相同但placeId不同，我们允许显示，但会在UI中获取更多信息来区分
    final lastKnownPlace = state.lastKnownPlace;
    final lastKnownPlaceId = lastKnownPlace?.placeId;
    final selectedPlaceId = state.selectedPlaceId;
    displayPlaces.addAll(
      state.nearbyPlaces.where(
        (item) {
          // 过滤掉current_position
          if (item.placeId == 'current_position') return false;
          // 过滤掉placeId相同的item
          if (item.placeId == lastKnownPlaceId || item.placeId == selectedPlaceId) return false;
          // 允许内容相同但placeId不同的item通过，我们会在UI中获取更多信息来区分
          return true;
        },
      ),
    );

    final isLoading = state.isNearbyLoading && displayPlaces.isEmpty;
    final isUpdating = state.isNearbyUpdating && displayPlaces.isNotEmpty;
    final selectedId = state.selectedPlaceId;

    Logger.info('MapNearbySheet', 'displayPlaces: ${displayPlaces.map((item) => '${item.placeId} ${item.primaryText} ${item.secondaryText} ${item.street}').toList()}');
    if (isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: const Center(child: CommonIndicator(size: 24)),
      );
    }

    if (displayPlaces.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Text(
          l10n?.emptyListText ?? '暂无周边地点',
          style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          physics: const ClampingScrollPhysics(),
          itemCount: displayPlaces.length,
          itemBuilder: (_, index) {
            final item = displayPlaces[index];
            final isSelected = item.placeId == selectedId;
            return _NearbyItem(
              suggestion: item,
              isSelected: isSelected,
              lastKnownPlace: lastKnownPlace,
              onTap: () async {
                await onSelectPlace(item);
                dismiss();
              },
            );
          },
        ),
        if (isUpdating)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Container(
                color: Colors.white.withValues(alpha: 0.6),
                alignment: Alignment.center,
                child: const CommonIndicator(size: 20),
              ),
            ),
          ),
      ],
    );
  }
}

class _NearbyItem extends StatefulWidget {
  const _NearbyItem({
    required this.suggestion,
    required this.isSelected,
    required this.onTap,
    this.lastKnownPlace,
  });

  final PlaceSuggestion suggestion;
  final bool isSelected;
  final VoidCallback onTap;
  final PlaceSuggestion? lastKnownPlace;

  @override
  State<_NearbyItem> createState() => _NearbyItemState();
}

class _NearbyItemState extends State<_NearbyItem> {
  String? _additionalInfo;
  bool _isLoadingDetails = false;

  @override
  void initState() {
    super.initState();
    // 如果内容相同但placeId不同，尝试获取详细信息来区分
    _loadAdditionalInfoIfNeeded();
  }

  Future<void> _loadAdditionalInfoIfNeeded() async {
    // 如果已经有街道信息，不需要加载
    if (widget.suggestion.street != null && widget.suggestion.street!.isNotEmpty) {
      return;
    }

    // 为所有没有街道信息的item获取详细信息
    if (widget.suggestion.placeId.isNotEmpty && widget.suggestion.placeId != 'current_position') {
      setState(() {
        _isLoadingDetails = true;
      });

      try {
        final details = await mapsService.fetchPlaceDetails(widget.suggestion.placeId);
        if (details != null && details.formattedAddress != null) {
          final street = MapsService.extractStreetFromAddress(details.formattedAddress);
          if (street.isNotEmpty && mounted) {
            setState(() {
              _additionalInfo = street;
              _isLoadingDetails = false;
            });
          } else if (mounted) {
            setState(() {
              _isLoadingDetails = false;
            });
          }
        } else if (mounted) {
          setState(() {
            _isLoadingDetails = false;
          });
        }
      } catch (e) {
        Logger.error('MapNearbySheet', '获取地点详情失败: $e');
        if (mounted) {
          setState(() {
            _isLoadingDetails = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 确定要显示的街道信息：优先使用suggestion.street，如果没有则使用_additionalInfo
    final streetToShow = widget.suggestion.street ?? _additionalInfo;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? AppTheme.primaryOrange.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.suggestion.primaryText,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (widget.isSelected)
                  Icon(Icons.check, size: 18.sp, color: AppTheme.primaryOrange),
              ],
            ),
            CommonSpacing.height(4.h),

            Text(
              widget.suggestion.secondaryText,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[500],
                fontWeight: FontWeight.w400,
              ),
            ),
            if (_isLoadingDetails) ...[
              CommonSpacing.height(2.h),
              SizedBox(
                height: 12.h,
                width: 12.w,
                child: CommonIndicator(size: 12),
              ),
            ] else if (streetToShow != null && streetToShow.isNotEmpty) ...[
              CommonSpacing.height(2.h),
              Text(
                streetToShow,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
              
            
          ],
        ),
      ),
    );
  }
}


