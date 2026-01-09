import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chop_user/src/core/utils/logger/logger.dart';
import 'package:chop_user/src/features/comment/models/comment_model.dart';
import 'package:chop_user/src/features/comment/services/comment_service.dart';

class ShopCommentState {
  final List<AppMerchantShopCommentRespVO> list;
  final int total;
  final double averageRate;
  final bool isLoading;
  final int pageNo;
  final bool hasMore;
  final String? error;

  ShopCommentState({
    this.list = const [],
    this.total = 0,
    this.averageRate = 0.0,
    this.isLoading = false,
    this.pageNo = 1,
    this.hasMore = true,
    this.error,
  });

  ShopCommentState copyWith({
    List<AppMerchantShopCommentRespVO>? list,
    int? total,
    double? averageRate,
    bool? isLoading,
    int? pageNo,
    bool? hasMore,
    String? error,
  }) {
    return ShopCommentState(
      list: list ?? this.list,
      total: total ?? this.total,
      averageRate: averageRate ?? this.averageRate,
      isLoading: isLoading ?? this.isLoading,
      pageNo: pageNo ?? this.pageNo,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

class ShopCommentNotifier extends StateNotifier<ShopCommentState> {
  final String shopId;
  static const int _pageSize = 10;

  ShopCommentNotifier(this.shopId) : super(ShopCommentState());

  Future<void> loadComments({bool refresh = false}) async {
    if (state.isLoading) return;
    if (!refresh && !state.hasMore) return;

    final pageNo = refresh ? 1 : state.pageNo + 1;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await CommentService.getShopCommentPage(
        shopId: shopId,
        pageNo: pageNo,
        pageSize: _pageSize,
      );

      final newList = refresh ? result.list : [...state.list, ...result.list];
      final hasMore = result.list.length >= _pageSize;

      state = state.copyWith(
        list: newList,
        total: result.total,
        averageRate: result.averageRate,
        isLoading: false,
        pageNo: pageNo,
        hasMore: hasMore,
      );
    } catch (e) {
      Logger.error('ShopCommentNotifier', 'Failed to load comments: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final shopCommentProvider =
    StateNotifierProvider.family<ShopCommentNotifier, ShopCommentState, String>(
  (ref, shopId) {
    return ShopCommentNotifier(shopId);
  },
);
