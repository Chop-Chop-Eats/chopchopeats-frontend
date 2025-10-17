import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 收藏操作状态
class FavoriteState {
  /// 正在处理中的店铺ID集合
  final Set<String> processingShopIds;

  FavoriteState({
    this.processingShopIds = const {},
  });

  FavoriteState copyWith({
    Set<String>? processingShopIds,
  }) {
    return FavoriteState(
      processingShopIds: processingShopIds ?? this.processingShopIds,
    );
  }

  /// 检查某个店铺是否正在处理中
  bool isProcessing(String shopId) {
    return processingShopIds.contains(shopId);
  }

  /// 是否有任何店铺正在处理中
  bool get hasProcessing => processingShopIds.isNotEmpty;
}

/// 收藏状态管理
class FavoriteNotifier extends StateNotifier<FavoriteState> {
  FavoriteNotifier() : super(FavoriteState());

  /// 开始处理收藏操作
  void startProcessing(String shopId) {
    final newSet = Set<String>.from(state.processingShopIds)..add(shopId);
    state = state.copyWith(processingShopIds: newSet);
  }

  /// 结束处理收藏操作
  void endProcessing(String shopId) {
    final newSet = Set<String>.from(state.processingShopIds)..remove(shopId);
    state = state.copyWith(processingShopIds: newSet);
  }

  /// 清空所有处理状态
  void clearAll() {
    state = FavoriteState();
  }
}

/// 收藏状态 Provider
final favoriteStateProvider = StateNotifierProvider<FavoriteNotifier, FavoriteState>((ref) {
  return FavoriteNotifier();
});

/// 检查是否有收藏操作正在进行（用于全局禁用）
final hasFavoriteProcessingProvider = Provider<bool>((ref) {
  return ref.watch(favoriteStateProvider).hasProcessing;
});

/// 检查特定店铺是否正在处理
final isShopProcessingProvider = Provider.family<bool, String>((ref, shopId) {
  return ref.watch(favoriteStateProvider).isProcessing(shopId);
});

