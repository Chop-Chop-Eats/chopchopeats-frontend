import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/datasources/remote/auth_api_service.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/providers/cache_provider.dart' as cache_provider;
import '../../../../core/utils/logger/logger.dart';
import '../../../../data/datasources/local/cache_service.dart';

/// 认证状态
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final Map<String, dynamic>? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    Map<String, dynamic>? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

/// 认证状态管理器
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState()) {
    Logger.info('AuthNotifier', '认证状态管理器已初始化');
    // 延迟检查认证状态，确保缓存服务已初始化
    Future.microtask(() => _checkAuthStatus());
  }

  /// 检查认证状态
  Future<void> _checkAuthStatus() async {
    try {
      Logger.debug('AuthNotifier', '检查认证状态');
      final isLoggedIn = await _authRepository.isLoggedIn();
      
      if (isLoggedIn) {
        final user = await _authRepository.getCurrentUser();
        state = state.copyWith(
          isAuthenticated: true,
          user: user,
        );
        Logger.info('AuthNotifier', '用户已登录: ${user?['username']}');
      } else {
        Logger.debug('AuthNotifier', '用户未登录');
      }
    } catch (e) {
      Logger.error('AuthNotifier', '检查认证状态异常', error: e);
      state = state.copyWith(error: '检查认证状态失败');
    }
  }

  /// 用户登录
  Future<bool> login(String username, String password) async {
    Logger.info('AuthNotifier', '开始登录流程: username=$username');
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _authRepository.login(username, password);
      
      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final user = data['user'] as Map<String, dynamic>;
        
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
        );
        
        Logger.info('AuthNotifier', '登录成功: ${user['username']}');
        return true;
      } else {
        final error = response['message'] as String;
        state = state.copyWith(
          isLoading: false,
          error: error,
        );
        
        Logger.warn('AuthNotifier', '登录失败: $error');
        return false;
      }
    } catch (e) {
      Logger.error('AuthNotifier', '登录异常', error: e);
      state = state.copyWith(
        isLoading: false,
        error: '登录失败: ${e.toString()}',
      );
      return false;
    }
  }

  /// 用户登出
  Future<void> logout() async {
    Logger.info('AuthNotifier', '开始登出流程');
    
    state = state.copyWith(isLoading: true);
    
    try {
      await _authRepository.logout();
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        error: null,
      );
      
      Logger.info('AuthNotifier', '登出成功');
    } catch (e) {
      Logger.error('AuthNotifier', '登出异常', error: e);
      // 即使登出失败，也要清除本地状态
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        error: null,
      );
    }
  }

  /// 刷新 Token
  Future<bool> refreshToken() async {
    Logger.debug('AuthNotifier', '开始刷新 Token');
    
    try {
      final response = await _authRepository.refreshToken();
      
      if (response['success'] == true) {
        Logger.info('AuthNotifier', 'Token 刷新成功');
        return true;
      } else {
        Logger.warn('AuthNotifier', 'Token 刷新失败: ${response['message']}');
        return false;
      }
    } catch (e) {
      Logger.error('AuthNotifier', 'Token 刷新异常', error: e);
      return false;
    }
  }

  /// 清除错误信息
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider 定义

/// ApiClient Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// AuthApiService Provider
final authApiServiceProvider = Provider<AuthApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthApiService(apiClient);
});

/// AuthRepository Provider
final authRepositoryProvider = FutureProvider<AuthRepository>((ref) async {
  final authApiService = ref.watch(authApiServiceProvider);
  final cacheService = await ref.watch(cache_provider.cacheServiceProvider.future);
  return AuthRepository(
    authApiService: authApiService,
    cacheService: cacheService,
  );
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  // 这个 Notifier 依赖于 AuthRepository
  // 我们 watch authRepositoryProvider，当它准备好时，它的值 (data) 会被用来创建 AuthNotifier
  final authRepository = ref.watch(authRepositoryProvider);

  // authRepositoryProvider 是一个 FutureProvider，在它加载完成前，我们需要一个优雅的处理
  // .when() 是处理 FutureProvider/StreamProvider 状态的最佳方式
  return authRepository.when(
    // 当 Future 成功完成时，我们用返回的 repository 创建 AuthNotifier
    data: (repository) => AuthNotifier(repository),
    // 在加载期间，我们可以提供一个临时的、不能执行任何操作的 Notifier
    // 这里我们简单地抛出异常，因为理论上在访问需要登录的页面时，这个 Provider 应该已经加载完毕了
    loading: () => throw Exception("AuthRepository is not yet available."),
    // 处理错误情况
    error: (err, stack) => throw Exception("Failed to initialize AuthRepository: $err"),
  );
});
