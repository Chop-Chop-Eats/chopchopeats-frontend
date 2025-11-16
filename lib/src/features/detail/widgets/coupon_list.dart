import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:unified_popups/unified_popups.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_indicator.dart';
import '../../../core/widgets/common_spacing.dart';
import '../models/detail_model.dart';
import '../providers/detail_provider.dart';
import '../services/detail_services.dart';

/// 优惠券列表组件
class CouponList extends ConsumerStatefulWidget {
  final String shopId;

  const CouponList({super.key, required this.shopId});

  @override
  ConsumerState<CouponList> createState() => _CouponListState();
}

class _CouponListState extends ConsumerState<CouponList> {
  // 在弹出的 sheet 中使用的“正在领取中”的券ID集合（可响应监听）
  final ValueNotifier<Set<String>> _claimingIds = ValueNotifier<Set<String>>(<String>{});

  @override
  void dispose() {
    _claimingIds.dispose();
    super.dispose();
  }

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

    return GestureDetector(
      onTap: () {
        Logger.info("CouponList", "点击查看更多优惠券");
        if (couponData == null || couponData.list == null || couponData.list!.isEmpty) {
          Pop.toast(l10n.noCoupon, toastType: ToastType.none);
          return;
        }
        final filteredList = couponData.list!
            .where((item) => (item.status ?? 0) == 1)
            .toList();
        if (filteredList.isEmpty) {
          Pop.toast(l10n.noCoupon, toastType: ToastType.none);
          return;
        }
        _showCouponSheet(
          l10n: l10n,
          couponList: filteredList,
          isLoading: isLoading,
        );
      },
      child: Row(
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
          CommonSpacing.width(8.w),
          // 优惠券列表内容
          Expanded(child: _buildCouponContent(couponData, isLoading, error)),
          Icon(
            Icons.arrow_forward_ios, size: 16.w, color: Colors.black,
          ),
        ],
      ),
    );
  }

  /// 构建优惠券内容
  Widget _buildCouponContent(
    AvailableCouponModel? couponData,
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

    final filteredList = couponData?.list
            ?.where((item) => (item.status ?? 0) == 1)
            .toList() ??
        [];

    if (filteredList.isEmpty) {
      return Text(
        '暂无优惠券',
        style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(), // 弹性滚动
      child: Row(
        children: filteredList
            .map<Widget>((coupon) => _buildCouponItem(coupon.couponTitle ?? ''))
            .toList(),
      ),
    );
  }

  /// 构建单个优惠券项
  Widget _buildCouponItem(String title) => Container(
    decoration: BoxDecoration(
      color: AppTheme.primaryOrange.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6.r),
      border: Border.all(color: AppTheme.primaryOrange, width: 1.w),
    ),
    margin: EdgeInsets.only(right: 10.w),
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


  Widget _buildSheetItem(
    AppLocalizations l10n,
    AvailableCouponItem coupon,
  ) {
    final discount = _formatAmount(coupon.discountAmount);
    final minSpend = _formatAmount(coupon.minSpendAmount);
    final dateRange = _formatDateRange(coupon.validFrom, coupon.validUntil);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Color(0xFFFFF6F1), // #FFF6F1,
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
                        coupon.couponTitle ?? '--',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                if (coupon.remark?.isNotEmpty == true) ...[
                  CommonSpacing.small,
                  Text(
                    coupon.remark!,
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
          
           ValueListenableBuilder<Set<String>>(
             valueListenable: _claimingIds,
             builder: (_, ids, __) {
               final isClaiming = coupon.id != null && ids.contains(coupon.id);
               return GestureDetector(
                 onTap: () async {
                   if (coupon.id == null) return;
                   // 校验领取上限（仅提示，不禁用）
                   final reachedLimit = (coupon.userLimit != null &&
                       coupon.userClaimedCount != null &&
                       coupon.userClaimedCount! >= coupon.userLimit!);
                   if (reachedLimit) {
                     Pop.toast(l10n.couponClaimLimitReached, toastType: ToastType.none);
                     return;
                   }
                   Logger.info("CouponList", "点击领取优惠券 ${coupon.id}");
                   // 标记该券处于领取中
                   _claimingIds.value = {...ids, coupon.id!};
                   try {
                     await DetailServices().claimCoupon(coupon.id!); // 领取优惠券
                     await ref.read(couponProvider(widget.shopId).notifier).loadCouponList(widget.shopId);
                     Pop.toast(l10n.claimCouponSuccess, toastType: ToastType.success);
                   } catch (e) {
                     Pop.toast(l10n.claimCouponFailed, toastType: ToastType.error);
                   } finally {
                     final next = {..._claimingIds.value};
                     next.remove(coupon.id!);
                     _claimingIds.value = next;
                   }
                 },
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
           ),
        ],
      ),
    );
  }


  Future<void> _showCouponSheet({
    required AppLocalizations l10n,
    required List<AvailableCouponItem> couponList,
    required bool isLoading,
  }) async {
    await Pop.sheet<void>(
      title: l10n.coupons,
      showCloseButton: true,
      maxHeight: SheetDimension.fraction(0.5),
      childBuilder: (dismiss) => isLoading
          ? const CommonIndicator()
          : ListView.builder(
              itemBuilder: (context, index) => _buildSheetItem(l10n, couponList[index]),
              itemCount: couponList.length,
            ),
    );
  }

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
}
