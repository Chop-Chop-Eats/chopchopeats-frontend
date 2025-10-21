import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_indicator.dart';
import '../../../core/widgets/common_spacing.dart';
import '../providers/detail_provider.dart';

/// 优惠券列表组件
class CouponList extends ConsumerStatefulWidget {
  final String shopId;

  const CouponList({super.key, required this.shopId});

  @override
  ConsumerState<CouponList> createState() => _CouponListState();
}

class _CouponListState extends ConsumerState<CouponList> {
  @override
  void initState() {
    super.initState();
    // 只在初始化时加载一次，Provider 会缓存数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = ref.read(couponProvider(widget.shopId));
      // 只有当数据为空且未加载时才请求
      if (currentState.couponData == null && !currentState.isLoading) {
        ref.read(couponProvider(widget.shopId).notifier).loadCouponList(widget.shopId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final couponData = ref.watch(couponDataProvider(widget.shopId));
    final isLoading = ref.watch(couponLoadingProvider(widget.shopId));
    final error = ref.watch(couponErrorProvider(widget.shopId));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          l10n.getCoupon,
          style: TextStyle(
            color: Colors.black,
            fontSize: 14.sp,
            fontWeight: FontWeight.normal,
          ),
        ),
        CommonSpacing.width(4),
        // 优惠券列表内容
        Expanded(child: _buildCouponContent(couponData, isLoading, error)),
        IconButton(
          onPressed: () {
            Logger.info("CouponList", "点击查看更多优惠券");
          },
          icon: Icon(Icons.arrow_forward_ios, size: 16.w, color: Colors.black),
        ),
      ],
    );
  }

  /// 构建优惠券内容
  Widget _buildCouponContent(
    dynamic couponData,
    bool isLoading,
    String? error,
  ) {
    if (isLoading) {
      return CommonIndicator(size: 20.w);
    }

    if (error != null) {
      return Text(
        '加载失败',
        style: TextStyle(fontSize: 12.sp, color: Colors.red[500]),
      );
    }

    if (couponData?.list == null || couponData!.list!.isEmpty) {
      return Text(
        '暂无优惠券',
        style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
      );
    }

    // 显示优惠券列表（最多显示3个）
    final coupons = couponData.list!.take(3).toList();
    return Row(
      children:coupons.map<Widget>((coupon) => _buildCouponItem(coupon.couponTitle ?? '')).toList(),
    );
  }

  /// 构建单个优惠券项
  Widget _buildCouponItem(String title) => Container(
    decoration: BoxDecoration(
      color: AppTheme.primaryOrange.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6.r),
      border: Border.all(color: AppTheme.primaryOrange, width: 1.w),
    ),
    margin: EdgeInsets.only(right: 2.w),
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
    child: Text(
      title,
      style: TextStyle(
        color: AppTheme.primaryOrange,
        fontSize: 10.sp,
        fontWeight: FontWeight.normal,
      ),
    ),
  );
}
