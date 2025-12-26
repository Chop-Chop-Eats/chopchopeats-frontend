import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/logger/logger.dart';
import '../models/mine_model.dart';
import '../services/mine_services.dart';

/// 用户信息数据状态
class UserInfoState {
  final UserInfoModel? userInfo;
  final bool isLoading;
  final String? error;

  UserInfoState({
    this.userInfo,
    this.isLoading = false,
    this.error,
  });

  UserInfoState copyWith({
    UserInfoModel? userInfo,
    bool? isLoading,
    String? error,
  }) {
    return UserInfoState(
      userInfo: userInfo ?? this.userInfo,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// 用户信息数据状态管理
class UserInfoNotifier extends StateNotifier<UserInfoState> {
  UserInfoNotifier() : super(UserInfoState());

  /// 加载用户信息
  Future<void> loadUserInfo() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userInfo = await MineServices().getUserInfo();
      state = state.copyWith(
        userInfo: userInfo,
        isLoading: false,
      );
      Logger.info(
        'UserInfoNotifier',
        '用户信息加载成功: walletBalance=\$${userInfo.walletBalance?.toStringAsFixed(2) ?? "null"}, userId=${userInfo.id}',
      );
    } catch (e) {
      Logger.error('UserInfoNotifier', '用户信息加载失败: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 刷新用户信息
  Future<void> refresh() async {
    await loadUserInfo();
  }
}

/// 用户信息数据 Provider
final userInfoProvider = StateNotifierProvider<UserInfoNotifier, UserInfoState>((ref) {
  return UserInfoNotifier();
});

/// 用户信息数据选择器 - 只返回用户信息
final userInfoDataProvider = Provider<UserInfoModel?>((ref) {
  return ref.watch(userInfoProvider).userInfo;
});

/// 用户信息加载状态选择器
final userInfoLoadingProvider = Provider<bool>((ref) {
  return ref.watch(userInfoProvider).isLoading;
});

/// 用户信息错误状态选择器
final userInfoErrorProvider = Provider<String?>((ref) {
  return ref.watch(userInfoProvider).error;
});
