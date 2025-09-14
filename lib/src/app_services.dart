import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/api_client.dart';
import 'data/datasources/local/cache_service.dart';
import 'core/config/app_setting.dart';

/// 服务定位器，用于管理应用范围内的共享实例。
class AppServices {
  /// 私有构造函数，防止外部实例化。
  AppServices._();

  // 全局唯一的存储设备标识符
  static late final String uuid;

  /// 全局唯一的 Navigator Key 静态 final 变量，确保只被创建一次
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// 全局唯一的网络请求客户端
  static late final ApiClient apiClient;

  /// 全局唯一的本地缓存服务
  static late final CacheService cache;

  // 全局唯一的 AppSettings 实例
  static late final AppSettings appSettings;


  /// 初始化基础服务，缓存和app设置
  static Future<void> initCacheService() async {
    final prefs = await SharedPreferences.getInstance();
    cache = CacheService(prefs: prefs);
    appSettings = await AppSettings.init();
  }

  ///  初始化依赖于配置的服务
  /// 这个方法应该在 EnvironmentConfig 初始化之后被调用。
  static Future<void> initApiService() async {
    // ApiClient 依赖于 EnvironmentConfig 所以必须在这里初始化
    apiClient = ApiClient();
  }
}
