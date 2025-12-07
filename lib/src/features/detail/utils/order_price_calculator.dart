import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_notifier.dart';
import '../providers/detail_provider.dart';
import '../providers/confirm_order_provider.dart';

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
    
    // 优惠券折扣
    final couponDiscount = selectedCoupon?.discountAmount ?? 0.0;
    
    // 订单总价：餐品小记 + 配送费 + 税费&服务费 - 优惠券折扣
    final orderTotal = mealSubtotal + deliveryFee + taxAndServiceFee - couponDiscount;
    
    // 小费：订单总价 * 小费比例
    // 优先使用自定义小费比例，否则使用预设比例
    final customTipRate = ref.read(customTipRateProvider(shopId));
    final selectedTipRate = customTipRate != null 
        ? (customTipRate / 100.0) 
        : (ref.read(selectedTipRateProvider(shopId)) ?? 0.10);
    final tipAmount = orderTotal * selectedTipRate;
    
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
