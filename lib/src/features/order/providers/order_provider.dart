import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chop_user/src/features/order/models/order_model.dart';
import 'package:chop_user/src/features/order/services/order_service.dart';

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

      state = state.copyWith(
        isLoading: false,
        list: newList,
        total: result.total,
        hasMore: newList.length < result.total,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Handle error?
    }
  }
}

final orderListProvider = StateNotifierProvider.family<OrderListNotifier, OrderListState, int?>((ref, statusGroup) {
  return OrderListNotifier(ref.watch(orderServiceProvider), statusGroup);
});

final orderDetailProvider = FutureProvider.family<AppTradeOrderDetailRespVO, String>((ref, orderNo) async {
  final service = ref.watch(orderServiceProvider);
  return service.getOrderDetail(orderNo);
});
