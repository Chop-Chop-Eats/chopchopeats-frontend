import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/logger/logger.dart';
import '../providers/cart_notifier.dart';
import '../providers/detail_provider.dart';
import '../providers/confirm_order_provider.dart';
import '../models/order_model.dart';
import '../../coupon/providers/coupon_page_provider.dart';
import '../../coupon/models/coupon_models.dart';

/// 订单价格计算结果
class OrderPriceResult {
  final double mealSubtotal;
  final double deliveryFee;
  final double taxAmount;
  final double serviceFee;
  final double taxAndServiceFee;
  final double couponDiscount;
  final double orderTotal;
  final double tipAmount;
  final double tipRate;

  OrderPriceResult({
    required this.mealSubtotal,
    required this.deliveryFee,
    required this.taxAmount,
    required this.serviceFee,
    required this.taxAndServiceFee,
    required this.couponDiscount,
    required this.orderTotal,
    required this.tipAmount,
    required this.tipRate,
  });

  Map<String, double> toMap() {
    return {
      'mealSubtotal': mealSubtotal,
      'deliveryFee': deliveryFee,
      'taxAmount': taxAmount,
      'serviceFee': serviceFee,
      'taxAndServiceFee': taxAndServiceFee,
      'couponDiscount': couponDiscount,
      'orderTotal': orderTotal,
      'tipAmount': tipAmount,
      'tipRate': tipRate,
    };
  }
}

/// 订单价格计算工具类
class OrderPriceCalculator {
  /// 验证优惠券是否满足使用条件
  /// 返回 true 表示满足条件，false 表示不满足
  static bool validateCoupon({
    required WidgetRef ref,
    required String shopId,
    required CouponSelectionResult coupon,
  }) {
    // 获取我的优惠券列表（使用用户已领取的优惠券）
    final myCouponData = ref.read(myCouponListDataProvider);
    if (myCouponData == null || myCouponData.list.isEmpty) return false;

    // 查找对应的优惠券详情（按用户优惠券记录ID查找）
    CouponItem? couponDetail;
    for (final group in myCouponData.list) {
      if (group.shopId == shopId && group.couponList != null) {
        try {
          couponDetail = group.couponList!.firstWhere(
            (item) => item.id == coupon.couponId,
          );
          break;
        } catch (e) {
          // 继续查找下一个组
        }
      }
    }

    // 如果找不到优惠券详情，则认为不可用
    if (couponDetail == null) return false;

    final minSpendAmount = couponDetail.minSpendAmount ?? 0;

    // 计算当前订单金额（不包括优惠券折扣）
    final cartState = ref.read(cartStateProvider(shopId));
    final shop = ref.read(shopDetailProvider(shopId));
    final mealSubtotal = cartState.totals.subtotal;
    final deliveryFee = cartState.totals.deliveryFee;
    final taxRate = shop?.taxRate ?? 0.0;
    final serviceFeeRate = shop?.platformCommissionRate ?? 0.0;
    final taxAmount = mealSubtotal * taxRate;
    final serviceFee = mealSubtotal * serviceFeeRate;
    final currentOrderAmount =
        mealSubtotal + deliveryFee + taxAmount + serviceFee;

    Logger.info(
      'OrderPriceCalculator',
      '验证优惠券: 当前订单金额=\$${currentOrderAmount.toStringAsFixed(2)}, '
          '优惠券门槛=\$${minSpendAmount.toStringAsFixed(2)}',
    );

    return currentOrderAmount >= minSpendAmount;
  }

  /// 计算订单价格
  static OrderPriceResult calculate({
    required WidgetRef ref,
    required String shopId,
  }) {
    final cartState = ref.read(cartStateProvider(shopId));
    final shop = ref.read(shopDetailProvider(shopId));
    final selectedCoupon = ref.read(selectedCouponProvider(shopId));

    // 餐品小记
    final mealSubtotal = cartState.totals.subtotal;

    // 配送费
    final deliveryFee = cartState.totals.deliveryFee;

    // 税费&服务费：餐品小记 * taxRate + 餐品小记 * platformCommissionRate
    final taxRate = shop?.taxRate ?? 0.0;
    final serviceFeeRate = shop?.platformCommissionRate ?? 0.0;
    final taxAmount = mealSubtotal * taxRate;
    final serviceFee = mealSubtotal * serviceFeeRate;
    final taxAndServiceFee = taxAmount + serviceFee;

    // 优惠券折扣：需要验证优惠券是否满足使用条件
    double couponDiscount = 0.0;
    if (selectedCoupon != null) {
      // 验证优惠券是否满足条件
      final isValid = validateCoupon(
        ref: ref,
        shopId: shopId,
        coupon: selectedCoupon,
      );

      if (isValid) {
        couponDiscount = selectedCoupon.discountAmount;
      } else {
        // 如果不满足条件，自动移除优惠券
        Logger.info('OrderPriceCalculator', '优惠券未达到使用门槛，自动移除');
        // 在下一帧移除优惠券，避免在 build 过程中修改状态
        Future.microtask(() {
          ref.read(selectedCouponProvider(shopId).notifier).state = null;
        });
      }
    }

    // 订单总价：餐品小记 + 配送费 + 税费&服务费 - 优惠券折扣
    final orderTotal =
        mealSubtotal + deliveryFee + taxAndServiceFee - couponDiscount;

    // 小费：餐品小记 * 小费比例
    // 优先使用自定义小费比例，否则使用预设比例
    final customTipRate = ref.read(customTipRateProvider(shopId));
    final selectedTipRate =
        customTipRate != null
            ? (customTipRate / 100.0)
            : (ref.read(selectedTipRateProvider(shopId)) ?? 0.10);
    final tipAmount = mealSubtotal * selectedTipRate;

    return OrderPriceResult(
      mealSubtotal: mealSubtotal,
      deliveryFee: deliveryFee,
      taxAmount: taxAmount,
      serviceFee: serviceFee,
      taxAndServiceFee: taxAndServiceFee,
      couponDiscount: couponDiscount,
      orderTotal: orderTotal,
      tipAmount: tipAmount,
      tipRate: selectedTipRate,
    );
  }
}
