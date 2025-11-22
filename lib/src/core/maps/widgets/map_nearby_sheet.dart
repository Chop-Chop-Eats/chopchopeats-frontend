import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../utils/logger/logger.dart';
import '../../widgets/common_image.dart';
import '../../widgets/common_indicator.dart';
import '../../widgets/common_spacing.dart';
import '../providers/map_providers.dart';
import '../services/maps_service.dart';

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
    final notifier = ref.read(mapPickerProvider.notifier);
    final l10n = AppLocalizations.of(context);

    // 构建显示列表：lastKnownPlace作为第一项，然后过滤掉重复的item
    final List<PlaceSuggestion> displayPlaces = [];
    if (state.lastKnownPlace != null) {
      displayPlaces.add(state.lastKnownPlace!);
    }
    // 注意：如果内容相同但placeId不同，我们允许显示，但会在UI中获取更多信息来区分
    final lastKnownPlace = state.lastKnownPlace;
    final lastKnownKey =
        lastKnownPlace != null ? notifier.suggestionKey(lastKnownPlace) : null;
    final selectedKey = state.selectedPlaceId ?? lastKnownKey;
    displayPlaces.addAll(
      state.nearbyPlaces.where(
        (item) {
          final itemKey = notifier.suggestionKey(item);
          if (notifier.isCurrentPositionSuggestion(item)) return false;
          if (itemKey == lastKnownKey || itemKey == selectedKey) return false;
          return true;
        },
      ),
    );

    final isLoading = state.isNearbyLoading && displayPlaces.isEmpty;
    final showOverlayLoading = state.isNearbyLoading && displayPlaces.isNotEmpty;
    final isUpdating = state.isNearbyUpdating && displayPlaces.isNotEmpty;
    final nearbyError = state.nearbyError;
    final hasRetryableError = nearbyError != null && state.nearbyRetryCount >= 3;
    final selectedId = selectedKey;

    Logger.info('MapNearbySheet', 'displayPlaces: ${displayPlaces.map((item) => '${item.placeId} ${item.primaryText} ${item.secondaryText} ${item.street}').toList()}');
    if (isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: const Center(child: CommonIndicator(size: 24)),
      );
    }

    if (hasRetryableError && displayPlaces.isEmpty) {
      return _NearbyErrorView(
        message: nearbyError,
        retryLabel: l10n?.tryAgainText ?? '重试',
        onRetry: notifier.retryLoadNearbyPlaces,
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

    final listBottomPadding = hasRetryableError ? 100.h : 12.h;

    return Stack(
      children: [
        ListView.builder(
          padding: EdgeInsets.only(
            top: 6.h,
            bottom: listBottomPadding,
          ),
          physics: const ClampingScrollPhysics(),
          itemCount: displayPlaces.length,
          itemBuilder: (_, index) {
            final item = displayPlaces[index];
            final itemKey = notifier.suggestionKey(item);
            final isSelected = itemKey == selectedId;
            return _NearbyItem(
              suggestion: item,
              isSelected: isSelected,
              onTap: () async {
                await onSelectPlace(item);
                dismiss();
              },
            );
          },
        ),
        if (hasRetryableError && displayPlaces.isNotEmpty)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _NearbyRetryFooter(
              message: nearbyError,
              retryLabel: l10n?.tryAgainText ?? '重试',
              onRetry: notifier.retryLoadNearbyPlaces,
            ),
          ),
        if (showOverlayLoading || isUpdating)
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

class _NearbyItem extends StatelessWidget {
  const _NearbyItem({
    required this.suggestion,
    required this.isSelected,
    required this.onTap,
  });

  final PlaceSuggestion suggestion;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final streetToShow =
        suggestion.street ?? suggestion.address ?? suggestion.secondaryText;
    final borderColor = isSelected
        ? AppTheme.primaryOrange
        : Colors.grey.withValues(alpha: 0.2);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: CommonImage(
                    imagePath: 'assets/images/location.png',
                    width: 24.w,
                    height: 24.w,
                    fit: BoxFit.contain,
                  ),
                ),
                CommonSpacing.width(12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion.primaryText,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      CommonSpacing.height(4.h),
                      if (streetToShow.isNotEmpty)
                        Text(
                          streetToShow,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    size: 20.sp,
                    color: AppTheme.primaryOrange,
                  ),
              ],
            ),
            if (suggestion.secondaryText.isNotEmpty &&
                streetToShow.toLowerCase() !=
                    suggestion.secondaryText.toLowerCase()) ...[
              CommonSpacing.height(6.h),
              Text(
                suggestion.secondaryText,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[500],
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

class _NearbyErrorView extends StatelessWidget {
  const _NearbyErrorView({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          CommonSpacing.medium,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                retryLabel,
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NearbyRetryFooter extends StatelessWidget {
  const _NearbyRetryFooter({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
          ),
          CommonSpacing.small,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                retryLabel,
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


