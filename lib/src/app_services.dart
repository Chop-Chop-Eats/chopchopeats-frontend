// lib/services/app_services.dart
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

  // 全局唯一的加密服务
  // static late final CryptoService cryptoService;

  /// 步骤 1: 初始化基础服务，缓存和app设置
  static Future<void> initCacheService() async {
    final prefs = await SharedPreferences.getInstance();
    cache = CacheService(storage: SharedPreferencesAdapter(prefs));
    appSettings = await AppSettings.init();

    // 初始化并持久化 UUID
    // await _initializeUUID();
  }

  /// 步骤 2: 初始化依赖于配置的服务
  /// 这个方法应该在 EnvironmentConfig 初始化之后被调用。
  static Future<void> initApiService() async {
    // ApiClient 依赖于 EnvironmentConfig 所以必须在这里初始化
    apiClient = ApiClient();
    // 初始化加密服务
    // cryptoService = CryptoService.fromAppConstants();
  }


  /// 初始化设备唯一标识符 (UUID)
  /// 优先从缓存读取，如果不存在则生成新的并存入缓存。
  // static Future<void> _initializeUUID() async {
  //   const uuidKey = AppConstants.deviceUuid;
  //   String? storedUuid = await cache.get<String>(uuidKey);
  //   String rawId; // 用于存放原始ID
  //   if (storedUuid == null || storedUuid.isEmpty) {
  //     final deviceInfoPlugin = DeviceInfoPlugin();
  //     try {
  //       Logger.info("kIsWeb", kIsWeb);
  //       if (kIsWeb) {
  //         // Web 平台 UUID 生成逻辑
  //         final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  //         final randomSuffix = Random().nextInt(999).toString().padLeft(3, '0');
  //         rawId = '$timestamp$randomSuffix';
  //       }else{
  //         // // 原生平台逻辑 (Android, iOS 等)
  //         if (Platform.isAndroid) {
  //           final androidInfo = await deviceInfoPlugin.androidInfo;
  //           rawId = androidInfo.id;
  //         } else if (Platform.isIOS) {
  //           final iosInfo = await deviceInfoPlugin.iosInfo;
  //           rawId = iosInfo.identifierForVendor ?? 'ios_device_unknown';
  //         } else {
  //           rawId = 'unknown_platform';
  //         }
  //       }
  //
  //     } catch (e) {
  //       rawId = 'fallback_uuid'; // 提供一个备用值以防失败
  //     }
  //     uuid = rawId.replaceAll('-', '');
  //     await cache.set<String>(uuidKey, uuid);
  //     Logger.info("uuid", "uuid:$uuid");
  //   } else {
  //     uuid = storedUuid;
  //     Logger.info("UUID"  , "UUID load cache: $storedUuid");
  //   }
  // }

}
