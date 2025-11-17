import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unified_popups/unified_popups.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_indicator.dart';
import '../../../core/widgets/common_spacing.dart';
import '../models/detail_model.dart';
import '../providers/detail_provider.dart';
import '../../coupon/widgets/coupoon_item.dart';

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
              itemBuilder: (context, index) {
                final coupon = couponList[index];
                return CoupoonItem(
                  coupon: coupon.toDisplayModel(),
                  showClaimButton: true,
                  shopId: widget.shopId,
                  claimingIds: _claimingIds,
                  onClaimSuccess: () {
                    // 领取成功后刷新列表
                    ref.read(couponProvider(widget.shopId).notifier).loadCouponList(widget.shopId);
                  },
                );
              },
              itemCount: couponList.length,
            ),
    );
  }
}
