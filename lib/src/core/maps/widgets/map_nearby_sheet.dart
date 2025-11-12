import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
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

    final List<PlaceSuggestion> displayPlaces = [
      if (state.lastKnownPlace != null) state.lastKnownPlace!,
      ...state.nearbyPlaces.where((item) => item.placeId != 'current_position'),
    ];

    final isLoading = state.isNearbyLoading && displayPlaces.isEmpty;
    final isUpdating = state.isNearbyUpdating && displayPlaces.isNotEmpty;
    final selectedId = state.selectedPlaceId;

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

    return Flexible(
  
      child: Stack(
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
                onTap: () {
                  dismiss();
                  unawaited(onSelectPlace(item));
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
      ),
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
    final l10n = AppLocalizations.of(context);
    final isCurrent = suggestion.placeId == 'current_position';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: isSelected
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
                    suggestion.primaryText,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check, size: 18.sp, color: AppTheme.primaryOrange),
                if (!isSelected && isCurrent)
                  Container(
                    margin: EdgeInsets.only(left: 8.w),
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      l10n?.mapSelectedLocationLabel ?? '当前位置',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppTheme.primaryOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            CommonSpacing.small,
            Text(
              suggestion.secondaryText,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey[500],
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


