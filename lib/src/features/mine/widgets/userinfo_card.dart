import 'package:chop_user/src/core/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/routing/navigate.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_image.dart';
import '../../../core/widgets/common_spacing.dart';
import '../../../core/widgets/common_indicator.dart';
import '../../../core/l10n/app_localizations.dart';
import '../providers/mine_provider.dart';

class UserinfoCard extends ConsumerStatefulWidget {
  const UserinfoCard({super.key});

  @override
  ConsumerState<UserinfoCard> createState() => _UserinfoCardState();
}

class _UserinfoCardState extends ConsumerState<UserinfoCard> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userInfo = ref.watch(userInfoDataProvider);
    final isLoading = ref.watch(userInfoLoadingProvider);
    final error = ref.watch(userInfoErrorProvider);

    // 显示加载状态
    if (isLoading && userInfo == null) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2.w),
          borderRadius: BorderRadius.circular(24.w),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 2.w,
              offset: Offset(0, 1.w),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: const CommonIndicator(color: Colors.white),
        ),
      );
    }

    // 显示错误状态
    if (error != null && userInfo == null) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2.w),
          borderRadius: BorderRadius.circular(24.w),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              blurRadius: 2.w,
              offset: Offset(0, 1.w),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48.w, color: Colors.red),
              SizedBox(height: 16.h),
              Text(
                '加载失败',
                style: TextStyle(fontSize: 16.sp, color: Colors.red),
              ),
              SizedBox(height: 8.h),
              Text(
                error,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2.w),
        borderRadius: BorderRadius.circular(24.w),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            blurRadius: 2.w,
            offset: Offset(0, 1.w),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              Navigate.push(context, Routes.profile);
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.w),
                  topRight: Radius.circular(24.w),
                ),
                image: DecorationImage(
                  image: AssetImage("assets/images/appbar_bg.png"),
                  fit: BoxFit.cover,
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CommonSpacing.medium,
                  // 字段 avatar  若为空 则展示一个兜底
                  CommonImage(
                    imagePath:
                        userInfo?.avatar?.isNotEmpty == true
                            ? userInfo!.avatar!
                            : "assets/images/avatar.png",
                    width: 64.w,
                    height: 64.h,
                    borderRadius: 32.w,
                  ),
                  CommonSpacing.medium,
                  // 字段 id
                  Text(
                    userInfo?.id ?? "",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  CommonSpacing.small,
                  // 字段 email
                  Text(
                    userInfo?.email ?? "",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24.w),
                bottomRight: Radius.circular(24.w),
              ),
              gradient: LinearGradient(
                colors: [Color(0xFFEAEFF5), Color(0xFFFBFDFF)],
              ),
            ),
            padding: EdgeInsets.all(6.w),
            child: Row(
              children: [
                Expanded(
                  child: _buildItem(
                    title: l10n.wallet,
                    value:
                        userInfo?.walletBalance != null
                            ? "\$${userInfo!.walletBalance!.toStringAsFixed(2)}"
                            : "\$0.00",
                    tip: l10n.recharge,
                    onTap: () {
                      Logger.info("UserinfoCard", "点击充值");
                    },
                  ),
                ),
                Container(
                  width: 1.w,
                  height: 48.h,
                  color: Colors.grey.shade400,
                ),
                // 字段 availableCouponCount
                Expanded(
                  child: _buildItem(
                    title: l10n.coupons,
                    value:
                        userInfo?.availableCouponCount != null
                            ? "${userInfo!.availableCouponCount} ${l10n.coupons}"
                            : "0",
                    onTap: () {
                      Navigate.push(context, Routes.coupon);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required String title,
    required String value,
    String? tip,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24.w)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.normal,
                color: Colors.grey.shade700,
              ),
              
            ),
            CommonSpacing.small,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                // 长度溢出 
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (tip != null) ...[
                      CommonSpacing.width(4.w),
                      Text(
                        tip,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    CommonSpacing.width(4.w),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
