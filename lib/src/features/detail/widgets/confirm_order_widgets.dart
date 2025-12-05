import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unified_popups/unified_popups.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/routing/navigate.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_button.dart';
import '../../../core/widgets/common_image.dart';
import '../../../core/widgets/common_indicator.dart';
import '../../../core/widgets/common_spacing.dart';
import '../../address/models/address_models.dart';
import '../../address/providers/address_provider.dart';
import '../../address/widgets/address_card.dart';
import '../../coupon/widgets/coupoon_item.dart';
import '../models/detail_model.dart';
import '../models/order_model.dart';

/// 胶囊按钮组件
class CapsuleButton extends StatelessWidget {
  const CapsuleButton({
    super.key,
    required this.title,
    required this.onTap,
    required this.imagePath,
  });

  final String title;
  final VoidCallback onTap;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  CommonImage(imagePath: imagePath, width: 24.w, height: 24.h),
                  CommonSpacing.width(8.w),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16.w, color: Colors.black),
          ],
        ),
      ),
    );
  }
}

/// 可选择的胶囊项组件（用于小费比例、配送时间选择）
class SelectableCapsuleItem extends StatelessWidget {
  const SelectableCapsuleItem({
    super.key,
    required this.title,
    required this.isSelected,
    this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryOrange : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        padding: EdgeInsets.symmetric(vertical: 6.h),
        alignment: Alignment.center,
        margin: EdgeInsets.only(right: 4.h),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

/// 优惠券选择Sheet
class CouponSelectionSheet {
  /// 显示选择优惠券的sheet
  static Future<CouponSelectionResult?> show({
    required BuildContext context,
    required WidgetRef ref,
    required String shopId,
    required List<AvailableCouponItem> couponList,
    required bool isLoading,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    return await Pop.sheet<CouponSelectionResult>(
      title: l10n.coupons,
      titleStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
      showCloseButton: true,
      maxHeight: SheetDimension.fraction(0.5),
      childBuilder: (dismiss) => isLoading
          ? const CommonIndicator()
          : ListView.builder(
              itemBuilder: (context, index) {
                final coupon = couponList[index];
                return CoupoonItem(
                  coupon: coupon.toDisplayModel(),
                  showClaimButton: false,
                  showUseButton: true,
                  onUse: () {
                    if (coupon.id != null && coupon.discountAmount != null) {
                      dismiss(CouponSelectionResult(
                        couponId: coupon.id!,
                        discountAmount: coupon.discountAmount!,
                      ));
                    }
                  },
                );
              },
              itemCount: couponList.length,
            ),
    );
  }
}

/// 地址选择Sheet
class AddressSelectionSheet {
  /// 显示地址选择sheet
  static Future<AddressItem?> show({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    
    // 确保在打开sheet时加载地址数据
    final addressState = ref.read(addressListProvider);
    if (addressState.addresses.isEmpty && !addressState.isLoading) {
      await ref.read(addressListProvider.notifier).loadAddresses();
    }
    
    return await Pop.sheet<AddressItem>(
      title: l10n.address,
      titleStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
      showCloseButton: true,
      maxHeight: SheetDimension.fraction(0.6),
      childBuilder: (dismiss) {
        // 使用Consumer确保响应状态变化
        return Consumer(
          builder: (context, ref, child) {
            final currentState = ref.watch(addressListProvider);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (currentState.isLoading && currentState.addresses.isEmpty)
                  const Expanded(child: Center(child: CommonIndicator()))
                else if (currentState.addresses.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.emptyListText,
                            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                          ),
                          CommonSpacing.medium,
                          CommonButton(
                            text: l10n.addAddress,
                            onPressed: () async {
                              final result = await Navigate.push(context, Routes.addAddress);
                              if (result == true) {
                                await ref.read(addressListProvider.notifier).loadAddresses();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: currentState.addresses.length,
                      itemBuilder: (context, index) {
                        final address = currentState.addresses[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: AddressCard(
                            address: address,
                            onTap: () => dismiss(address),
                          ),
                        );
                      },
                    ),
                  ),
                // 底部添加地址按钮
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: CommonButton(
                    padding: EdgeInsets.symmetric(horizontal: 80.w, vertical: 12.h),
                    text: l10n.addAddress,
                    onPressed: () async {
                      final result = await Navigate.push(context, Routes.addAddress);
                      if (result == true) {
                        await ref.read(addressListProvider.notifier).loadAddresses();
                      }
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}


