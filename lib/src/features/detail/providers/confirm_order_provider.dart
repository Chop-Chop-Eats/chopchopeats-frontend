import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/models/home_models.dart';
import '../../address/models/address_models.dart';
import '../models/order_model.dart';

/// 选中的配送时间 Provider
final selectedDeliveryTimeProvider = StateProvider.family<OperatingHour?, String>((ref, shopId) {
  return null;
});

/// 选中的优惠券 Provider
final selectedCouponProvider = StateProvider.family<CouponSelectionResult?, String>((ref, shopId) {
  return null;
});

/// 选中的小费比例 Provider（例如：0.10 表示 10%）
final selectedTipRateProvider = StateProvider.family<double?, String>((ref, shopId) {
  return 0.10; // 默认 10%
});

/// 自定义小费比例 Provider（例如：15 表示 15%，null 表示使用预设比例）
final customTipRateProvider = StateProvider.family<int?, String>((ref, shopId) {
  return null;
});

/// 是否正在编辑自定义小费 Provider
final isEditingCustomTipProvider = StateProvider.family<bool, String>((ref, shopId) {
  return false;
});

/// 选中的地址 Provider
final selectedAddressProvider = StateProvider.family<AddressItem?, String>((ref, shopId) {
  return null;
});

/// 可配送时间列表 Provider
final availableDeliveryTimesProvider = StateProvider.family<List<OperatingHour>?, String>((ref, shopId) {
  return null;
});

/// 配送时间加载状态 Provider
final deliveryTimesLoadingProvider = StateProvider.family<bool, String>((ref, shopId) {
  return false;
});

/// 选中的用餐日期 Provider（格式：YYYY-MM-DD）
final selectedDiningDateProvider = StateProvider.family<String?, String>((ref, shopId) {
  return null;
});
