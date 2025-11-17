import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_indicator.dart';
import '../../../core/widgets/common_spacing.dart';
import '../models/coupon_models.dart';
import '../providers/coupon_page_provider.dart';
import '../widgets/coupoon_item.dart';

class CouponPage extends ConsumerStatefulWidget {
  const CouponPage({super.key});

  @override
  ConsumerState<CouponPage> createState() => _CouponPageState();
}

class _CouponPageState extends ConsumerState<CouponPage> {
  @override
  void initState() {
    super.initState();
    // 只在初始化时加载一次，Provider 会缓存数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = ref.read(myCouponListProvider);
      // 只有当数据为空且未加载时才请求
      if (currentState.couponData == null && !currentState.isLoading) {
        ref.read(myCouponListProvider.notifier).loadMyCouponList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final couponData = ref.watch(myCouponListDataProvider);
    final isLoading = ref.watch(myCouponListLoadingProvider);
    final error = ref.watch(myCouponListErrorProvider);

    return Scaffold(
      appBar: CommonAppBar(title: l10n.coupons),
      body: _buildBody(couponData, isLoading, error),
    );
  }

  Widget _buildBody(CouponListModel? couponData, bool isLoading, String? error) {
    if (isLoading && couponData == null) {
      return const Center(
        child: CommonIndicator(),
      );
    }

    if (error != null && couponData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '加载失败',
              style: TextStyle(fontSize: 16.sp, color: Colors.red[500]),
            ),
            CommonSpacing.medium,
            ElevatedButton(
              onPressed: () {
                ref.read(myCouponListProvider.notifier).loadMyCouponList();
              },
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (couponData == null || couponData.list.isEmpty) {
      return Center(
        child: Text(
          '暂无优惠券',
          style: TextStyle(fontSize: 16.sp, color: Colors.grey[500]),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(myCouponListProvider.notifier).refresh();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: couponData.list.length,
        itemBuilder: (context, index) {
          final group = couponData.list[index];
          return _buildCouponGroup(group);
        },
      ),
    );
  }

  /// 构建优惠券分组（按店铺）
  Widget _buildCouponGroup(CouponGroupItem group) {
    final couponList = group.couponList ?? [];
    
    if (couponList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 店铺名称标题
        Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Text(
            group.shopName ?? '未知店铺',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        // 该店铺的优惠券列表
        ...couponList.map((coupon) => CoupoonItem(
              coupon: coupon.toDisplayModel(),
              showClaimButton: false, // 已领取模式，不显示领取按钮
              shopId: group.shopId, // 传递店铺ID，用于跳转到详情页
            )),
        // 分组之间的间距
        CommonSpacing.large,
      ],
    );
  }
}
