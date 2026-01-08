import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_services.dart';
import '../../../core/config/environment_config.dart';
import '../../../core/constants/app_constant.dart';
import '../../../core/enums/auth_enums.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/push/push_service.dart';
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
        final userId = await AppServices.cache.get<String>(AppConstants.userId);
        final shopId = await AppServices.cache.get<String>(AppConstants.shopId);
        final openid = await AppServices.cache.get<String>(AppConstants.openid);
        Logger.info('AuthNotifier', '从缓存中获取状态信息： accessToken: $accessToken; refreshToken: $refreshToken; userId: $userId; shopId: $shopId; openid: $openid');
        if (accessToken != null && refreshToken != null && userId != null) {
          final user = AppAuthLoginResponse(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresTime: DateTime.now().add(const Duration(days: 7)), // 临时设置过期时间
            userId: userId , // 可以从缓存中获取实际用户ID
            shopId: shopId,
            openid: openid
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
      await AppServices.cache.set(AppConstants.userId, loginResponse.userId);
      if (loginResponse.shopId != null) {
        await AppServices.cache.set(AppConstants.shopId, loginResponse.shopId!);
      }
      if(loginResponse.openid != null) {
        await AppServices.cache.set(AppConstants.openid, loginResponse.openid!);
      }

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: loginResponse,
        error: null,
      );
      
      Logger.info('AuthNotifier', '手机验证码登录成功: userId=${loginResponse.userId}；token=${loginResponse.accessToken};过期时间=${loginResponse.expiresTime}');

      // 登录成功后上报 FCM Token
      PushService().uploadTokenWhenLoggedIn().catchError((e) {
        Logger.warn('AuthNotifier', '上报 FCM Token 失败: $e');
      });

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

  /// 设置新密码
  Future<bool> setNewPassword(String code, String password , String mobile) async {
    if (state.isLoading) return false; // 防止重复设置新密码
    Logger.info('AuthNotifier', '开始设置新密码: code=$code');
    state = state.copyWith(isLoading: true, error: null);
    try {
      final params = AppAuthResetPasswordParams(
        code: code,
        password: password, 
        mobile: mobile,
        userPlatformType: UserPlatformTypeEnum.normal,
      );
      await _authServices.resetPassword(params);
      state = state.copyWith(isLoading: false, error: null);
      return true;
    } catch (e) {
      Logger.error('AuthNotifier', '设置新密码异常', error: e);
      if(e is ApiException) {
        state = state.copyWith(isLoading: false, error: e.message);
        return false;
      } else {
        state = state.copyWith(isLoading: false, error: '设置新密码失败: ${e.toString()}');
        return false;
      }
    }
  }


  /// 手机号密码登录
  Future<bool> loginWithPhoneAndPassword(String mobile, String password) async {
    if (state.isLoading) return false; // 防止重复登录
    
    Logger.info('AuthNotifier', '开始手机号密码登录: mobile=$mobile password=$password');
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final params = AppAuthPlatformLoginParams(
        mobile: mobile,
        password: password,
        userPlatformType: UserPlatformTypeEnum.normal, // 默认普通用户
      );
      
      final loginResponse = await _authServices.loginByPhoneAndPassword(params);
      
      // 保存登录信息到缓存
      await AppServices.cache.set(AppConstants.accessToken, loginResponse.accessToken);
      await AppServices.cache.set(AppConstants.refreshToken, loginResponse.refreshToken);
      await AppServices.cache.set(AppConstants.userId, loginResponse.userId);
      if (loginResponse.shopId != null) {
        await AppServices.cache.set(AppConstants.shopId, loginResponse.shopId!);
      }
      if (loginResponse.openid != null) {
        await AppServices.cache.set(AppConstants.openid, loginResponse.openid!);
      }

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: loginResponse,
        error: null,
      );
      
      Logger.info('AuthNotifier', '手机号密码登录成功: userId=${loginResponse.userId}；token=${loginResponse.accessToken};过期时间=${loginResponse.expiresTime}');

      // 登录成功后上报 FCM Token
      PushService().uploadTokenWhenLoggedIn().catchError((e) {
        Logger.warn('AuthNotifier', '上报 FCM Token 失败: $e');
      });

      return true;
    } catch (e) {
      Logger.error('AuthNotifier', '手机号密码登录异常', error: e);
      if(e is ApiException) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          user: null,
          error: e.message,
        );
        return false;
      } else {  
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          user: null,
          error: '登录失败: ${e.toString()}',
        );
        return false;
      }
    }
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
      await AppServices.cache.remove(AppConstants.userId);
      await AppServices.cache.remove(AppConstants.shopId);
      await AppServices.cache.remove(AppConstants.openid);

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
      await AppServices.cache.remove(AppConstants.userId);
      await AppServices.cache.remove(AppConstants.shopId);
      await AppServices.cache.remove(AppConstants.openid);

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
