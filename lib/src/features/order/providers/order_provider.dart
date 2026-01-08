import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chop_user/src/features/order/models/order_model.dart';
import 'package:chop_user/src/features/order/services/order_service.dart';
import 'package:chop_user/src/core/utils/logger/logger.dart';

final orderServiceProvider = Provider((ref) => OrderService());

class OrderListState {
  final bool isLoading;
  final List<AppTradeOrderPageRespVO> list;
  final int total;
  final int pageNo;
  final int pageSize;
  final bool hasMore;

  OrderListState({
    this.isLoading = false,
    this.list = const [],
    this.total = 0,
    this.pageNo = 1,
    this.pageSize = 10,
    this.hasMore = true,
  });

  OrderListState copyWith({
    bool? isLoading,
    List<AppTradeOrderPageRespVO>? list,
    int? total,
    int? pageNo,
    int? pageSize,
    bool? hasMore,
  }) {
    return OrderListState(
      isLoading: isLoading ?? this.isLoading,
      list: list ?? this.list,
      total: total ?? this.total,
      pageNo: pageNo ?? this.pageNo,
      pageSize: pageSize ?? this.pageSize,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class OrderListNotifier extends StateNotifier<OrderListState> {
  final OrderService _service;
  final int? _statusGroup;

  OrderListNotifier(this._service, this._statusGroup) : super(OrderListState());

  Future<void> refresh() async {
    Logger.info('OrderListNotifier', '刷新订单列表 statusGroup=$_statusGroup');
    state = state.copyWith(isLoading: true, pageNo: 1, list: [], hasMore: true);
    await _loadData();
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true, pageNo: state.pageNo + 1);
    await _loadData();
  }

  Future<void> _loadData() async {
    try {
      Logger.info(
        'OrderListNotifier',
        '加载订单数据 pageNo=${state.pageNo}, statusGroup=$_statusGroup',
      );
      final result = await _service.getOrderPage(
        pageNo: state.pageNo,
        pageSize: state.pageSize,
        statusGroup: _statusGroup,
      );

      final newList = [...state.list];
      if (state.pageNo == 1) {
        newList.clear();
      }
      newList.addAll(result.list);

      Logger.info(
        'OrderListNotifier',
        '加载成功，共 ${result.total} 条，本次 ${result.list.length} 条',
      );

      state = state.copyWith(
        isLoading: false,
        list: newList,
        total: result.total,
        hasMore: newList.length < result.total,
      );
    } catch (e) {
      Logger.error('OrderListNotifier', '加载订单失败: $e');
      state = state.copyWith(isLoading: false);
      // Handle error?
    }
  }
}

final orderListProvider =
    StateNotifierProvider.family<OrderListNotifier, OrderListState, int?>((
      ref,
      statusGroup,
    ) {
      return OrderListNotifier(ref.watch(orderServiceProvider), statusGroup);
    });

final orderDetailProvider =
    FutureProvider.family<AppTradeOrderDetailRespVO, String>((
      ref,
      orderNo,
    ) async {
      final service = ref.watch(orderServiceProvider);
      return service.getOrderDetail(orderNo);
    });

/// 刷新所有订单列表（用于支付成功后）
void refreshAllOrderLists(WidgetRef ref) {
  // 刷新所有相关的订单列表
  ref.read(orderListProvider(null).notifier).refresh(); // 全部
  ref.read(orderListProvider(1).notifier).refresh(); // 待支付
  ref.read(orderListProvider(2).notifier).refresh(); // 进行中
  ref.read(orderListProvider(3).notifier).refresh(); // 已完成
  ref.read(orderListProvider(4).notifier).refresh(); // 取消/退款
}
