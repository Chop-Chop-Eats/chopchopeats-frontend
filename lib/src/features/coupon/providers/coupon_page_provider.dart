import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/logger/logger.dart';
import '../models/coupon_models.dart';
import '../services/coupon_servers.dart';

/// 我的优惠券列表状态
class MyCouponListState {
  final CouponListModel? couponData;
  final bool isLoading;
  final String? error;

  MyCouponListState({
    this.couponData,
    this.isLoading = false,
    this.error,
  });

  MyCouponListState copyWith({
    CouponListModel? couponData,
    bool? isLoading,
    String? error,
  }) {
    return MyCouponListState(
      couponData: couponData ?? this.couponData,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// 我的优惠券列表状态管理
class MyCouponListNotifier extends StateNotifier<MyCouponListState> {
  MyCouponListNotifier() : super(MyCouponListState());

  /// 加载我的优惠券列表
  Future<void> loadMyCouponList({
    int pageNo = 1,
    int pageSize = 10,
    int? status,
    String? shopId,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final query = CouponListQuery(
        pageNo: pageNo,
        pageSize: pageSize,
        status: status,
        shopId: shopId,
      );
      final couponData = await CouponServers.getMyCouponList(query);
      
      state = state.copyWith(
        couponData: couponData,
        isLoading: false,
      );

      Logger.info('MyCouponListNotifier', '我的优惠券列表加载成功: 共${couponData.list.length}组');
    } catch (e) {
      Logger.error('MyCouponListNotifier', '我的优惠券列表加载失败: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 刷新我的优惠券列表
  Future<void> refresh({
    int pageNo = 1,
    int pageSize = 10,
    int? status,
    String? shopId,
  }) async {
    await loadMyCouponList(
      pageNo: pageNo,
      pageSize: pageSize,
      status: status,
      shopId: shopId,
    );
  }

  /// 清除错误状态
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 我的优惠券列表 Provider
final myCouponListProvider = StateNotifierProvider<MyCouponListNotifier, MyCouponListState>((ref) {
  return MyCouponListNotifier();
});

/// 我的优惠券列表数据选择器
final myCouponListDataProvider = Provider<CouponListModel?>((ref) {
  return ref.watch(myCouponListProvider).couponData;
});

/// 我的优惠券列表加载状态选择器
final myCouponListLoadingProvider = Provider<bool>((ref) {
  return ref.watch(myCouponListProvider).isLoading;
});

/// 我的优惠券列表错误状态选择器
final myCouponListErrorProvider = Provider<String?>((ref) {
  return ref.watch(myCouponListProvider).error;
});

