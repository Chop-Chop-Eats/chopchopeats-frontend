import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_spacing.dart';
import '../models/detail_model.dart';
import '../providers/detail_provider.dart';
import 'daily_menu.dart';
import 'product_list.dart';
import 'shop_info_card.dart';

class ProductDetail extends ConsumerStatefulWidget {
  final ShopModel shop;
  final double logoHeight;

  const ProductDetail({
    super.key,
    required this.shop,
    required this.logoHeight,
  });

  @override
  ConsumerState<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends ConsumerState<ProductDetail> {
  // 1. 只保留 _previousWeekday 作为内部状态，用于动画方向判断
  late int _previousWeekday;

  @override
  void initState() {
    super.initState();
    // 2. 初始化时，从 provider 读取初始值
    _previousWeekday = ref.read(selectedWeekdayProvider);
  }

  /// 处理日期变化 (这个方法保持不变)
  void _onDateChanged(int weekday, DailyMenuItem item) {
    ref.read(selectedWeekdayProvider.notifier).state = weekday;
    Logger.info("ProductDetail", "切换每日菜单 - 日期: ${item.dateTime}, 星期: $weekday");
  }

  @override
  Widget build(BuildContext context) {
    // 3. 使用 ref.listen 监听 provider 的变化。
    //    它的作用是：当 provider 的值从 A 变为 B 时，它会触发回调，
    //    并且回调参数中会同时包含旧值(A)和新值(B)。
    //    我们在这里更新 _previousWeekday。
    ref.listen<int>(selectedWeekdayProvider, (previous, next) {
      // 当日期变化时，用上一个值更新我们的内部状态
      if (mounted) {
        setState(() {
          _previousWeekday = previous ?? DateTime.now().weekday;
        });
      }
    });

    // 4. 使用 ref.watch 获取最新的星期值，这会触发UI重建
    final currentWeekday = ref.watch(selectedWeekdayProvider);

    // 5. 现在我们同时拥有了新旧两个值，可以安全地判断动画方向
    final isForward = currentWeekday > _previousWeekday;

    return SingleChildScrollView(
      child: Column(
        children: [
          // 店铺信息卡片
          ShopInfoCard(shop: widget.shop, logoHeight: widget.logoHeight),

          // 每日菜单
          DailyMenu(onDateChanged: _onDateChanged),

          CommonSpacing.medium,

          // 商品列表
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              final offset =
                  isForward ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0);

              return SlideTransition(
                position: Tween<Offset>(
                  begin: offset,
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: ProductList(
              key: ValueKey('product_list_$currentWeekday'),
              shopId: widget.shop.id,
              saleWeekDay: currentWeekday,
            ),
          ),

          // 底部留出购物车的空间，避免内容被遮挡
          SizedBox(height: 80.h),
        ],
      ),
    );
  }
}
