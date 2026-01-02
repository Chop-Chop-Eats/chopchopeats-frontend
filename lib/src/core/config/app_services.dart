import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../network/api_client.dart';
import '../../data/datasources/local/cache_service.dart';
import 'app_setting.dart';
import 'device_info.dart';

/// 服务定位器，用于管理应用范围内的共享实例。
class AppServices {
  /// 私有构造函数，防止外部实例化。
  AppServices._();

  /// 全局唯一的设备信息实例
  static late final DeviceInfo deviceInfo;

  /// 全局唯一的存储设备标识符（向后兼容，通过 deviceInfo.deviceId 访问）
  static String get uuid => deviceInfo.deviceId;

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
    // 初始化 Hive
    await Hive.initFlutter();
    
    // 初始化 CacheService（内部会初始化 Hive Boxes）
    cache = CacheService();
    await cache.init();
    
    // 初始化设备信息（需要在 cache 初始化之后）
    deviceInfo = await DeviceInfo.init(cache);
    
    appSettings = await AppSettings.init();
  }

  ///  初始化依赖于配置的服务
  /// 这个方法应该在 EnvironmentConfig 初始化之后被调用。
  static Future<void> initApiService() async {
    // ApiClient 依赖于 EnvironmentConfig 所以必须在这里初始化
    apiClient = ApiClient();
  }
}
