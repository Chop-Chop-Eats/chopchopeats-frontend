import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app_services.dart';
import '../../../core/config/environment_config.dart';
import '../../../core/constants/app_constant.dart';
import '../../../core/enums/auth_enums.dart';
import '../../../core/utils/logger/logger.dart';
import '../models/auth_models.dart';
import '../services/auth_services.dart';

/// 认证状态
class AuthState {
  final bool isLoading;
  final bool isAuthenticated; // 是否已登录
  final AppAuthLoginResponse? user;
  final String? error;
  final bool isSendingSms; // 是否正在发送验证码

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
    this.isSendingSms = false,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    AppAuthLoginResponse? user,
    String? error,
    bool? isSendingSms,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error ?? this.error,
      isSendingSms: isSendingSms ?? this.isSendingSms,
    );
  }
}

/// 认证状态管理器
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthServices _authServices;
  bool _isInitialized = false;

  AuthNotifier(this._authServices) : super(const AuthState()) {
    Logger.info('AuthNotifier', '认证状态管理器已初始化');
    // 延迟初始化，避免在构造函数中立即执行异步操作
    _initializeLater();
  }

  /// 延迟初始化，避免阻塞构造函数
  void _initializeLater() {
    // 使用更轻量的方式延迟初始化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _checkAuthStatus();
      }
    });
  }

  /// 检查认证状态
  Future<void> _checkAuthStatus() async {
    if (_isInitialized) return; // 防止重复初始化
    
    try {
      _isInitialized = true;
      Logger.debug('AuthNotifier', '检查认证状态');
      final isLoggedIn = await _authServices.isLoggedIn();
      
      if (isLoggedIn) {
        // 从缓存中获取用户信息
        final accessToken = await AppServices.cache.get<String>(AppConstants.accessToken);
        final refreshToken = await AppServices.cache.get<String>(AppConstants.refreshToken);
        
        if (accessToken != null && refreshToken != null) {
          // 构造用户信息（这里可以根据需要从缓存或API获取更多用户信息）
          final user = AppAuthLoginResponse(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresTime: DateTime.now().add(const Duration(days: 7)), // 临时设置过期时间
            userId: "", // 可以从缓存中获取实际用户ID
          );
          
          state = state.copyWith(
            isAuthenticated: true,
            user: user,
          );
          Logger.info('AuthNotifier', '用户已登录');
        }
      } else {
        Logger.debug('AuthNotifier', '用户未登录');
      }
    } catch (e) {
      Logger.error('AuthNotifier', '检查认证状态异常', error: e);
      state = state.copyWith(error: '检查认证状态失败');
    }
  }

  /// 发送验证码
  Future<bool> sendVerificationCode(String mobile, SmsSceneEnum scene) async {
    if (state.isSendingSms) return false; // 防止重复发送
    
    Logger.info('AuthNotifier', '开始发送验证码: mobile=$mobile, scene=${scene.name}');
    
    state = state.copyWith(isSendingSms: true, error: null);
    
    try {
      final params = AppAuthSmsSendParams(
        mobile: mobile,
        scene: scene,
        userPlatformType: UserPlatformTypeEnum.normal, // 默认普通用户
      );
      
      await _authServices.sendSms(params);
      
      state = state.copyWith(isSendingSms: false, error: null);
      Logger.info('AuthNotifier', '验证码发送成功');
      return true;
    } catch (e) {
      Logger.error('AuthNotifier', '发送验证码异常', error: e);
      state = state.copyWith(
        isSendingSms: false,
        error: '验证码发送失败: ${e.toString()}',
      );
      return false;
    }
  }

  /// 手机验证码登录
  Future<bool> loginWithSmsCode(String mobile, String code, String? email) async {
    if (state.isLoading) return false; // 防止重复登录
    
    Logger.info('AuthNotifier', '开始手机验证码登录: mobile=$mobile');
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final params = AppAuthLoginParams(
        mobile: mobile,
        code: EnvironmentConfig.isDevelopment? "123456" : code,
        email: email,
        userPlatformType: UserPlatformTypeEnum.normal, // 默认普通用户
      );
      
      final loginResponse = await _authServices.login(params);
      
      // 保存登录信息到缓存
      await AppServices.cache.set(AppConstants.accessToken, loginResponse.accessToken);
      await AppServices.cache.set(AppConstants.refreshToken, loginResponse.refreshToken);
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: loginResponse,
        error: null,
      );
      
      Logger.info('AuthNotifier', '手机验证码登录成功: userId=${loginResponse.userId}');
      return true;
    } catch (e) {
      Logger.error('AuthNotifier', '手机验证码登录异常', error: e);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        error: '登录失败: ${e.toString()}',
      );
      return false;
    }
  }

  /// 用户登录（兼容旧接口，现在调用手机验证码登录）
  Future<bool> login(String username, String password) async {
    // 这个方法保留以兼容现有代码，但现在推荐使用 loginWithSmsCode
    Logger.warn('AuthNotifier', 'login(username, password) 方法已废弃，请使用 loginWithSmsCode');
    return false;
  }

  /// 用户登出
  Future<void> logout() async {
    if (state.isLoading) return; // 防止重复登出
    
    Logger.info('AuthNotifier', '开始登出流程');
    
    state = state.copyWith(isLoading: true);
    
    try {
      await _authServices.logout();
      
      // 清除本地缓存
      await AppServices.cache.remove(AppConstants.accessToken);
      await AppServices.cache.remove(AppConstants.refreshToken);
      
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
      await AppServices.cache.remove(AppConstants.accessToken);
      await AppServices.cache.remove(AppConstants.refreshToken);
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        error: null,
      );
    }
  }

  /// 刷新 Token（暂时不实现，后续可以添加）
  Future<bool> refreshToken() async {
    Logger.debug('AuthNotifier', 'Token 刷新功能暂未实现');
    return false;
  }

  /// 清除错误信息
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider 定义
final authServicesProvider = Provider<AuthServices>((ref) {
  return AuthServices();
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authServices = ref.watch(authServicesProvider);
  return AuthNotifier(authServices);
});
