import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:unified_popups/unified_popups.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/routing/navigate.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_indicator.dart';
import '../../../core/widgets/common_spacing.dart';
import '../models/coupon_models.dart';
import '../../detail/services/detail_services.dart';
import '../../detail/providers/detail_provider.dart';

/// 优惠券项组件
/// 支持两种模式：
/// 1. 可领取模式（showClaimButton = true）：显示"领取"按钮
/// 2. 已领取模式（ showClaimButton = false）：仅展示信息
class CoupoonItem extends ConsumerStatefulWidget {
  /// 优惠券显示数据
  final CouponDisplayModel coupon;

  /// 是否显示领取按钮（默认 true，用于可领取优惠券）
  final bool showClaimButton;

  /// 店铺ID（用于领取成功后刷新列表）
  final String? shopId;

  /// 领取成功回调
  final VoidCallback? onClaimSuccess;

  /// 领取状态监听器（用于管理多个优惠券的领取状态）
  final ValueNotifier<Set<String>>? claimingIds;

  const CoupoonItem({
    super.key,
    required this.coupon,
    this.showClaimButton = true,
    this.shopId,
    this.onClaimSuccess,
    this.claimingIds,
  });

  @override
  ConsumerState<CoupoonItem> createState() => _CoupoonItemState();
}

class _CoupoonItemState extends ConsumerState<CoupoonItem> {
  String _formatAmount(double? value) {
    if (value == null) return '--';
    final hasFraction = (value * 100) % 100 != 0;
    return hasFraction ? value.toStringAsFixed(2) : value.toStringAsFixed(0);
  }

  String _formatDateRange(DateTime? from, DateTime? to) {
    final formatter = DateFormat('yyyy/MM/dd');
    final start = from != null ? formatter.format(from) : null;
    final end = to != null ? formatter.format(to) : null;
    if (start == null && end == null) return '';
    if (start != null && end != null) {
      return '$start - $end';
    }
    return start ?? end ?? '';
  }

  Future<void> _handleClaim() async {
    if (widget.coupon.id == null) return;

    final l10n = AppLocalizations.of(context)!;
    final claimingIds = widget.claimingIds;

    // 校验领取上限（仅提示，不禁用）
    final reachedLimit = (widget.coupon.userLimit != null &&
        widget.coupon.userClaimedCount != null &&
        widget.coupon.userClaimedCount! >= widget.coupon.userLimit!);
    if (reachedLimit) {
      Pop.toast(l10n.couponClaimLimitReached, toastType: ToastType.none);
      return;
    }

    Logger.info("CoupoonItem", "点击领取优惠券 ${widget.coupon.id}");

    // 标记该券处于领取中
    if (claimingIds != null) {
      claimingIds.value = {...claimingIds.value, widget.coupon.id!};
    }

    try {
      await DetailServices().claimCoupon(widget.coupon.id!);
      
      // 如果提供了 shopId，刷新该店铺的优惠券列表
      if (widget.shopId != null) {
        await ref.read(couponProvider(widget.shopId!).notifier).loadCouponList(widget.shopId!);
      }
      
      Pop.toast(l10n.claimCouponSuccess, toastType: ToastType.success);
      
      // 调用成功回调
      widget.onClaimSuccess?.call();
    } catch (e) {
      Logger.error("CoupoonItem", "领取优惠券失败: $e");
      Pop.toast(l10n.claimCouponFailed, toastType: ToastType.error);
    } finally {
      // 移除领取中状态
      if (claimingIds != null) {
        final next = {...claimingIds.value};
        next.remove(widget.coupon.id!);
        claimingIds.value = next;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final discount = _formatAmount(widget.coupon.discountAmount);
    final minSpend = _formatAmount(widget.coupon.minSpendAmount);
    final dateRange = _formatDateRange(widget.coupon.validFrom, widget.coupon.validUntil);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Color(0xFFFFF6F1), // #FFF6F1
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppTheme.primaryOrange.withValues(alpha: 0.5),
          width: 0.5.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '\$$discount',
                      style: TextStyle(
                        color: AppTheme.primaryOrange,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    CommonSpacing.width(12.w),
                    Expanded(
                      child: Text(
                        widget.coupon.couponTitle ?? '--',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.coupon.remark?.isNotEmpty == true) ...[
                  CommonSpacing.small,
                  Text(
                    widget.coupon.remark!,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ],
                CommonSpacing.small,
                Text(
                  '${l10n.minSpend} \$$minSpend',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                ),
                if (dateRange.isNotEmpty) ...[
                  CommonSpacing.small,
                  Text(
                    dateRange,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                  ),
                ],
              ],
            ),
          ),
          // 显示按钮：可领取模式显示"领取"按钮，已领取模式根据status显示不同按钮
          _buildActionButton(l10n),
        ],
      ),
    );
  }

  /// 构建操作按钮（根据模式显示不同的按钮）
  Widget _buildActionButton(AppLocalizations l10n) {
    // 可领取模式：显示"领取"按钮
    if (widget.showClaimButton) {
      return _buildClaimButton(l10n);
    }

    // 已领取模式：根据 status 显示不同按钮
    final status = widget.coupon.status;
    
    // status = 0：显示"去使用"按钮，点击跳转到详情页
    if (status == 0) {
      return GestureDetector(
        onTap: () {
          if (widget.shopId != null) {
            Logger.info("CoupoonItem", "点击去使用优惠券，跳转到店铺详情页: ${widget.shopId}");
            Navigate.push(
              context,
              Routes.detail,
              arguments: {
                'id': widget.shopId!,
              },
            );
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppTheme.primaryOrange,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            '去使用',
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      );
    }

    // status = 1：显示"已使用"按钮，置灰
    if (status == 1) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          '已使用',
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.grey[600]),
        ),
      );
    }

    // status = 2：显示"已过期"按钮，置灰
    if (status == 2) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          '已过期',
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.grey[600]),
        ),
      );
    }

    // 默认情况：不显示按钮
    return const SizedBox.shrink();
  }

  /// 构建领取按钮（可领取模式）
  Widget _buildClaimButton(AppLocalizations l10n) {
    final claimingIds = widget.claimingIds;
    
    // 如果没有提供 claimingIds，创建一个本地的 ValueNotifier
    if (claimingIds == null) {
      return GestureDetector(
        onTap: _handleClaim,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppTheme.primaryOrange,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            l10n.getCoupon,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      );
    }

    // 使用提供的 claimingIds 来管理领取状态
    return ValueListenableBuilder<Set<String>>(
      valueListenable: claimingIds,
      builder: (_, ids, __) {
        final isClaiming = widget.coupon.id != null && ids.contains(widget.coupon.id);
        return GestureDetector(
          onTap: isClaiming ? null : _handleClaim,
          child: isClaiming
              ? const CommonIndicator(size: 16)
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    l10n.getCoupon,
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
        );
      },
    );
  }
}
