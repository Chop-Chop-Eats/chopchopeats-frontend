import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wallet_models.dart';
import '../services/wallet_services.dart';
import '../../../core/utils/logger/logger.dart';

/// 钱包信息数据状态
class WalletInfoState {
  final MyWalletInfo? walletInfo;
  final List<RecentWalletHistoryItem> recentHistory;
  final bool isLoading;
  final bool hasLoaded;
  final String? error;

  WalletInfoState({
    this.walletInfo,
    this.recentHistory = const [],
    this.isLoading = false,
    this.error,
    this.hasLoaded = false,
  });

  WalletInfoState copyWith({
    MyWalletInfo? walletInfo,
    List<RecentWalletHistoryItem>? recentHistory,
    bool? isLoading,
    String? error,
    bool? hasLoaded,
  }) {
    return WalletInfoState(
      walletInfo: walletInfo ?? this.walletInfo,
      recentHistory: recentHistory ?? this.recentHistory,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }
}

/// 钱包信息数据状态管理
class WalletInfoNotifier extends StateNotifier<WalletInfoState> {
  WalletInfoNotifier() : super(WalletInfoState());

  /// 加载钱包信息
  Future<void> loadWalletInfo() async {
    Logger.info('WalletInfoNotifier', '开始加载钱包信息...');
    state = state.copyWith(isLoading: true, error: null);
    try {
      final walletInfo = await WalletServices.getMyWalletInfo();
      final recentHistory = await WalletServices.getRecentWalletHistory();
      state = state.copyWith(
        walletInfo: walletInfo,
        recentHistory: recentHistory,
        isLoading: false,
        hasLoaded: true,
      );
      Logger.info(
        'WalletInfoNotifier',
        '钱包信息加载成功: balance=\$${walletInfo.balance.toStringAsFixed(2)}, historyCount=${recentHistory.length}, userId=${walletInfo.userId}',
      );
    } catch (e) {
      Logger.error('WalletInfoNotifier', '钱包信息加载失败: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 刷新钱包信息
  Future<void> refresh() async {
    await loadWalletInfo();
  }
}

/// 钱包信息数据 Provider
final walletInfoProvider =
    StateNotifierProvider<WalletInfoNotifier, WalletInfoState>((ref) {
      return WalletInfoNotifier();
    });

/// 钱包信息数据选择器 - 只返回钱包信息
final walletInfoDataProvider = Provider<MyWalletInfo?>((ref) {
  return ref.watch(walletInfoProvider).walletInfo;
});

/// 最近交易记录数据选择器
final recentWalletHistoryProvider = Provider<List<RecentWalletHistoryItem>>((
  ref,
) {
  return ref.watch(walletInfoProvider).recentHistory;
});

/// 钱包信息加载状态选择器
final walletInfoLoadingProvider = Provider<bool>((ref) {
  return ref.watch(walletInfoProvider).isLoading;
});

/// 钱包信息错误状态选择器
final walletInfoErrorProvider = Provider<String?>((ref) {
  return ref.watch(walletInfoProvider).error;
});

/// 充值卡列表数据状态
class RechargeCardListState {
  final List<RechargeCardItem> cards;
  final bool isLoading;
  final String? error;
  final bool hasLoaded;

  RechargeCardListState({
    this.cards = const [],
    this.isLoading = false,
    this.error,
    this.hasLoaded = false,
  });

  RechargeCardListState copyWith({
    List<RechargeCardItem>? cards,
    bool? isLoading,
    String? error,
    bool? hasLoaded,
  }) {
    return RechargeCardListState(
      cards: cards ?? this.cards,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }
}

/// 充值卡列表数据状态管理
class RechargeCardListNotifier extends StateNotifier<RechargeCardListState> {
  RechargeCardListNotifier() : super(RechargeCardListState());

  /// 加载充值卡列表
  Future<void> loadRechargeCardList() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final cards = await WalletServices.getRechargeCardList();
      state = state.copyWith(cards: cards, isLoading: false, hasLoaded: true);
      Logger.info(
        'RechargeCardListNotifier',
        '充值卡列表加载成功: count=${cards.length}',
      );
    } catch (e) {
      Logger.error('RechargeCardListNotifier', '充值卡列表加载失败: $e');
      state = state.copyWith(isLoading: false, error: e.toString(), hasLoaded: true);
    }
  }

  /// 刷新充值卡列表
  Future<void> refresh() async {
    await loadRechargeCardList();
  }
}

/// 充值卡列表数据 Provider
final rechargeCardListProvider =
    StateNotifierProvider<RechargeCardListNotifier, RechargeCardListState>((
      ref,
    ) {
      return RechargeCardListNotifier();
    });

/// 充值卡列表数据选择器
final rechargeCardListDataProvider = Provider<List<RechargeCardItem>>((ref) {
  return ref.watch(rechargeCardListProvider).cards;
});

/// 充值卡列表加载状态选择器
final rechargeCardListLoadingProvider = Provider<bool>((ref) {
  return ref.watch(rechargeCardListProvider).isLoading;
});

/// 充值卡列表错误状态选择器
final rechargeCardListErrorProvider = Provider<String?>((ref) {
  return ref.watch(rechargeCardListProvider).error;
});

/// 全部钱包交易记录数据状态
class WalletHistoryState {
  final List<AllWalletHistoryItem> history;
  final bool isLoading;
  final String? error;
  final bool hasLoaded;

  WalletHistoryState({
    this.history = const [],
    this.isLoading = false,
    this.error,
    this.hasLoaded = false,
  });

  WalletHistoryState copyWith({
    List<AllWalletHistoryItem>? history,
    bool? isLoading,
    String? error,
    bool? hasLoaded,
  }) {
    return WalletHistoryState(
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }
}

/// 全部钱包交易记录数据状态管理
class WalletHistoryNotifier extends StateNotifier<WalletHistoryState> {
  WalletHistoryNotifier() : super(WalletHistoryState());

  /// 加载全部钱包交易记录
  Future<void> loadWalletHistory() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final history = await WalletServices.getAllWalletHistory();
      state = state.copyWith(history: history, isLoading: false, hasLoaded: true);
      Logger.info(
        'WalletHistoryNotifier',
        '全部钱包交易记录加载成功: count=${history.length}',
      );
    } catch (e) {
      Logger.error('WalletHistoryNotifier', '全部钱包交易记录加载失败: $e');
      state = state.copyWith(isLoading: false, error: e.toString(), hasLoaded: true);
    }
  }

  /// 刷新全部钱包交易记录
  Future<void> refresh() async {
    await loadWalletHistory();
  }
}

/// 全部钱包交易记录数据 Provider
final walletHistoryProvider =
    StateNotifierProvider<WalletHistoryNotifier, WalletHistoryState>((ref) {
      return WalletHistoryNotifier();
    });

/// 全部钱包交易记录数据选择器
final walletHistoryDataProvider = Provider<List<AllWalletHistoryItem>>((ref) {
  return ref.watch(walletHistoryProvider).history;
});

/// 全部钱包交易记录加载状态选择器
final walletHistoryLoadingProvider = Provider<bool>((ref) {
  return ref.watch(walletHistoryProvider).isLoading;
});

/// 全部钱包交易记录错误状态选择器
final walletHistoryErrorProvider = Provider<String?>((ref) {
  return ref.watch(walletHistoryProvider).error;
});

/// 充值页面状态
class RechargePageState {
  final int? selectedCardIndex;
  final String inputAmount;

  RechargePageState({this.selectedCardIndex, this.inputAmount = ''});

  RechargePageState copyWith({
    int? selectedCardIndex,
    String? inputAmount,
    bool clearSelectedCardIndex = false,
  }) {
    return RechargePageState(
      selectedCardIndex: clearSelectedCardIndex
          ? null
          : (selectedCardIndex ?? this.selectedCardIndex),
      inputAmount: inputAmount ?? this.inputAmount,
    );
  }
}

/// 充值页面状态管理
class RechargePageNotifier extends StateNotifier<RechargePageState> {
  final Ref ref;

  RechargePageNotifier(this.ref) : super(RechargePageState());

  /// 选中充值卡（不影响输入框）
  void selectCard(int index) {
    state = state.copyWith(
      selectedCardIndex: index,
      inputAmount: '', // 清空输入框
    );
  }

  /// 更新输入金额（有值时取消选中状态）
  void updateInputAmount(String amount) {
    if (amount.isNotEmpty) {
      // 有输入值时，清空选择状态
      state = state.copyWith(clearSelectedCardIndex: true, inputAmount: amount);
    } else {
      // 输入框为空时，只更新 inputAmount
      state = state.copyWith(inputAmount: '');
    }
  }

  /// 清空选中状态
  void clearSelection() {
    state = RechargePageState();
  }

  /// 获取显示金额（用于UI展示）
  String? getDisplayAmount() {
    if (state.selectedCardIndex != null) {
      final cards = ref.read(rechargeCardListProvider).cards;
      if (state.selectedCardIndex! < cards.length) {
        final card = cards[state.selectedCardIndex!];
        // 格式：充值金额+赠送金额
        return '\$${card.rechargeAmount.toStringAsFixed(0)}+${card.bonusAmount.toStringAsFixed(0)}';
      }
    }
    if (state.inputAmount.isNotEmpty) {
      final amount = double.tryParse(state.inputAmount);
      if (amount != null) {
        return '\$${amount.toStringAsFixed(2)}';
      }
    }
    return null;
  }

  /// 获取当前金额（用于业务逻辑）
  /// 优先使用输入框的值，如果输入框为空才使用选中卡片的金额
  double? getCurrentAmount() {
    // 优先检查输入框的值
    if (state.inputAmount.isNotEmpty) {
      return double.tryParse(state.inputAmount);
    }
    // 如果输入框为空，才使用选中卡片的金额
    if (state.selectedCardIndex != null) {
      final cards = ref.read(rechargeCardListProvider).cards;
      if (state.selectedCardIndex! < cards.length) {
        return cards[state.selectedCardIndex!].rechargeAmount;
      }
    }
    return null;
  }

  /// 获取充值信息（金额 + 赠送）
  /// 返回: (amount: 充值金额, bonus: 赠送金额, cardId: 充值卡ID)
  ({double amount, double bonus, String cardId})? getRechargeInfo() {
    // 选中卡片 -> 返回卡片金额+赠送
    if (state.selectedCardIndex != null) {
      final cards = ref.read(rechargeCardListProvider).cards;
      if (state.selectedCardIndex! < cards.length) {
        final card = cards[state.selectedCardIndex!];
        return (
          amount: card.rechargeAmount,
          bonus: card.bonusAmount,
          cardId: card.id.toString(),
        );
      }
    }

    // 自定义输入 -> 返回输入金额+0赠送
    if (state.inputAmount.isNotEmpty) {
      final amount = double.tryParse(state.inputAmount);
      if (amount != null && amount > 0) {
        return (
          amount: amount,
          bonus: 0.0,
          cardId: "0",
        );
      }
    }

    return null;
  }
}

/// 充值页面状态 Provider
final rechargePageStateProvider =
    StateNotifierProvider<RechargePageNotifier, RechargePageState>((ref) {
      return RechargePageNotifier(ref);
    });

/// 充值页面显示金额选择器（实时更新）
/// 使用 select 优化依赖关系，只监听需要的状态字段，减少不必要的重建
final rechargeDisplayAmountProvider = Provider<String?>((ref) {
  // 使用 select 只监听需要的字段，减少重建
  final selectedCardIndex = ref.watch(
    rechargePageStateProvider.select((state) => state.selectedCardIndex),
  );
  final inputAmount = ref.watch(
    rechargePageStateProvider.select((state) => state.inputAmount),
  );
  final cards = ref.watch(
    rechargeCardListProvider.select((state) => state.cards),
  );

  // 优先检查输入框的值
  if (inputAmount.isNotEmpty) {
    final amount = double.tryParse(inputAmount);
    if (amount != null) {
      return '\$${amount.toStringAsFixed(2)}';
    }
  }
  // 如果输入框为空，才使用选中卡片的金额
  if (selectedCardIndex != null) {
    if (selectedCardIndex < cards.length) {
      final card = cards[selectedCardIndex];
      // 格式：充值金额+赠送金额 ${card.bonusAmount.toStringAsFixed(0)}
      return '\$${card.rechargeAmount.toStringAsFixed(0)}';
    }
  }
  return null;
});
