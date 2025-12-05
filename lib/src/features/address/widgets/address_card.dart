import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_image.dart';
import '../../../core/widgets/common_spacing.dart';
import '../models/address_models.dart';

/// 地址格式化工具函数
String formatAddress(AddressItem address) {
  final parts = [
    address.address,
    if (address.detailAddress?.isNotEmpty ?? false) address.detailAddress!,
    address.state,
  ].where((element) => element.isNotEmpty).toList();
  return parts.join(' · ');
}

/// 地址卡片组件
/// 支持两种使用模式：
/// 1. 选择模式：直接使用，支持onTap回调（用于sheet选择）
/// 2. 列表模式：包裹在AddressListItem中，支持滑动操作（用于地址列表页面）
class AddressCard extends StatelessWidget {
  const AddressCard({
    super.key,
    required this.address,
    this.onTap,
    this.showDefaultBadge = true,
  });

  final AddressItem address;
  final VoidCallback? onTap;
  final bool showDefaultBadge;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final addressText = formatAddress(address);

    final content = Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 255, 250, 250),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 2.r,
            offset: Offset(1.h, 2.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CommonImage(
            imagePath: 'assets/images/location_b.png',
            width: 24.w,
            height: 24.w,
            fit: BoxFit.contain,
          ),
          CommonSpacing.width(6.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          address.name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        if (showDefaultBadge && address.defaultStatus) ...[
                          CommonSpacing.width(6.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              l10n.defaultAddress,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppTheme.primaryOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ]
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 6.w),
                      child: Text(
                        address.mobile,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              
                CommonSpacing.small,
                Text(
                  addressText,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // 如果有onTap回调，包裹GestureDetector（选择模式）
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    // 否则直接返回内容（列表模式，由AddressListItem包裹）
    return content;
  }
}
