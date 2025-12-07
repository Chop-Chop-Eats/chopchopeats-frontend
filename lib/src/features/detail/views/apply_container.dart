import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_button.dart';
import '../widgets/bottom_arc_container.dart';
import '../utils/order_price_calculator.dart';
import '../providers/confirm_order_provider.dart';
import '../providers/cart_notifier.dart';

/// 底部结算容器组件
class ApplyContainer extends ConsumerWidget {
  const ApplyContainer({
    super.key,
    required this.shopId,
    required this.onSettlement,
  });

  final String shopId;
  final VoidCallback onSettlement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    // 监听小费相关 provider，确保价格计算响应状态变化
    ref.watch(selectedTipRateProvider(shopId));
    ref.watch(customTipRateProvider(shopId));
    ref.watch(selectedCouponProvider(shopId));
    ref.watch(cartStateProvider(shopId));
    
    final prices = OrderPriceCalculator.calculate(ref: ref, shopId: shopId);
    final pricesMap = prices.toMap();

    // 现价（包含小费，减了优惠券）
    final finalPrice = pricesMap['orderTotal']! + pricesMap['tipAmount']!;

    // 原价（包含小费，不算优惠券的原价）
    final originalPrice = (pricesMap['mealSubtotal']! +
            pricesMap['deliveryFee']! +
            pricesMap['taxAndServiceFee']!) *
        (1 + pricesMap['tipRate']!);

    return BottomArcContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 价格区域
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    // 现价（包含小费） 减了优惠券
                    TextSpan(
                      text: "\$${finalPrice.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryOrange,
                      ),
                    ),
                    if (pricesMap['couponDiscount']! > 0) ...[
                      TextSpan(text: "  "),
                      // 原价（包含小费）不算优惠券的原价
                      TextSpan(
                        text: "\$${originalPrice.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF86909C),
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Color(0xFF86909C),
                          decorationThickness: 1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // 小费 总价*小费比例
              Text(
                l10n.confirmOrderSettlementTip(
                  "\$${pricesMap['tipAmount']!.toStringAsFixed(2)}",
                ),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Color(0xFF86909C),
                ),
              ),
            ],
          ),
          // 按钮区域 点击时 组装 CreateOrderParams 数据 有多少组装多少
          CommonButton(
            text: l10n.confirmOrderSettlement,
            padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 12.h),
            onPressed: onSettlement,
          ),
        ],
      ),
    );
  }
}
