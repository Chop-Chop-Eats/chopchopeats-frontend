import 'package:flutter/material.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_spacing.dart';
import '../models/detail_model.dart';
import 'daily_menu.dart';
import 'product_list.dart';
import 'shop_info_card.dart';

class ProductDetail extends StatefulWidget {
  final ShopModel shop;
  final double logoHeight;
  
  const ProductDetail({
    super.key,
    required this.shop,
    required this.logoHeight,
  });

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  late int _currentWeekday; // 当前选中的星期
  int _previousWeekday = 0; // 上一个选中的星期，用于判断切换方向

  @override
  void initState() {
    super.initState();
    // 默认选中今天
    _currentWeekday = DateTime.now().weekday;
    _previousWeekday = _currentWeekday;
  }

  /// 处理日期变化
  void _onDateChanged(int weekday, DailyMenuItem item) {
    setState(() {
      _previousWeekday = _currentWeekday;
      _currentWeekday = weekday;
    });
    
    Logger.info("ProductDetail", "切换每日菜单 - 日期: ${item.dateTime}, 星期: $weekday (1-7代表周一到周日)");
  }

  /// 判断切换方向：true = 向右（前进），false = 向左（后退）
  bool get _isForward => _currentWeekday > _previousWeekday;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 店铺信息卡片
        ShopInfoCard(
          shop: widget.shop,
          logoHeight: widget.logoHeight,
        ),
        
        // 每日菜单
        DailyMenu(
          onDateChanged: _onDateChanged,
        ),

        CommonSpacing.medium,
        
        // 使用 AnimatedSwitcher 提供平滑左右切换动画
        // 懒加载：只加载用户选中的星期，Provider 会缓存已加载的数据
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (Widget child, Animation<double> animation) {
            // 根据切换方向决定滑动方向
            // 向右（前进）：新内容从右侧滑入，旧内容向左侧滑出
            // 向左（后退）：新内容从左侧滑入，旧内容向右侧滑出
            final offset = _isForward 
                ? const Offset(1.0, 0.0)  // 从右侧滑入
                : const Offset(-1.0, 0.0); // 从左侧滑入
            
            return SlideTransition(
              position: Tween<Offset>(
                begin: offset,
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: ProductList(
            key: ValueKey('product_list_$_currentWeekday'),
            shopId: widget.shop.id,
            saleWeekDay: _currentWeekday,
          ),
        ),
      ],
    );
  }
}