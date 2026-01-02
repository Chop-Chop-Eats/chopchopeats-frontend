import 'dart:io';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../constants/app_constant.dart';
import '../../data/datasources/local/cache_service.dart';
import '../utils/logger/logger.dart';

/// 设备信息管理类
/// 负责管理设备ID、应用版本、平台类型和设备型号等信息
class DeviceInfo {
  /// 设备ID（36位UUID格式）
  final String deviceId;

  /// 应用版本
  final String appVersion;

  /// 平台类型（android 或 ios）
  final String platform;

  /// 设备型号
  final String deviceModel;

  DeviceInfo._({
    required this.deviceId,
    required this.appVersion,
    required this.platform,
    required this.deviceModel,
  });

  /// 初始化设备信息
  /// 从缓存读取或生成设备ID，并获取应用版本、平台和设备型号
  static Future<DeviceInfo> init(CacheService cache) async {
    // 1. 获取或生成设备ID
    String deviceId = await _getOrGenerateDeviceId(cache);

    // 2. 获取应用版本信息
    final packageInfo = await PackageInfo.fromPlatform();
    final appVersion = packageInfo.version;

    // 3. 获取平台类型
    final platform = Platform.operatingSystem;

    // 4. 获取设备型号
    final deviceModel = await _getDeviceModel(platform);

    Logger.info(
      'DeviceInfo',
      '设备信息初始化完成: deviceId=$deviceId, appVersion=$appVersion, platform=$platform, deviceModel=$deviceModel',
    );

    return DeviceInfo._(
      deviceId: deviceId,
      appVersion: appVersion,
      platform: platform,
      deviceModel: deviceModel,
    );
  }

  /// 从缓存获取设备ID，如果不存在则生成新的UUID并保存
  static Future<String> _getOrGenerateDeviceId(CacheService cache) async {
    // 尝试从缓存读取
    final cachedUuid = await cache.get<String>(AppConstants.deviceUuid);
    if (cachedUuid != null && cachedUuid.isNotEmpty) {
      Logger.info('DeviceInfo', '从缓存读取设备ID: $cachedUuid');
      return cachedUuid;
    }

    // 生成新的UUID（36位标准格式：8-4-4-4-12）
    final uuid = _generateUUID();
    Logger.info('DeviceInfo', '生成新设备ID: $uuid');

    // 保存到缓存
    await cache.set<String>(AppConstants.deviceUuid, uuid);
    Logger.info('DeviceInfo', '设备ID已保存到缓存');

    return uuid;
  }

  /// 生成36位标准UUID格式（8-4-4-4-12）
  /// 使用 dart:io 的 Random 生成
  static String _generateUUID() {
    final random = Random.secure();
    final hexChars = '0123456789abcdef';

    String generateHex(int length) {
      return List.generate(
        length,
        (_) => hexChars[random.nextInt(hexChars.length)],
      ).join();
    }

    // 标准UUID格式：xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
    // 其中第13位固定为4，第17位为8、9、a或b之一
    final part1 = generateHex(8);
    final part2 = generateHex(4);
    final part3 = '4${generateHex(3)}'; // 第13位固定为4
    final part4 = '${hexChars[8 + random.nextInt(4)]}${generateHex(3)}'; // 第17位为8、9、a或b
    final part5 = generateHex(12);

    return '$part1-$part2-$part3-$part4-$part5';
  }

  /// 获取设备型号
  /// 使用 device_info_plus 获取真实的设备型号信息
  /// 如果插件未准备好，会重试并最终降级返回平台标识
  static Future<String> _getDeviceModel(String platform) async {
    // 对于非移动平台，直接返回平台标识
    if (platform != 'android' && platform != 'ios') {
      return platform;
    }

    final deviceInfo = DeviceInfoPlugin();
    const maxRetries = 3;
    const retryDelay = Duration(milliseconds: 100);

    // 重试机制：有时插件需要一点时间才能准备好
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        if (platform == 'android') {
          final androidInfo = await deviceInfo.androidInfo;
          // 返回设备型号，例如: "SM-G973F", "Pixel 5" 等
          final model = androidInfo.model.trim();
          if (model.isNotEmpty) {
            Logger.info('DeviceInfo', '成功获取Android设备型号: $model');
            return model;
          }
        } else if (platform == 'ios') {
          final iosInfo = await deviceInfo.iosInfo;
          // 返回设备型号，例如: "iPhone", "iPad" 等
          // 如果需要更详细的型号（如 iPhone 14 Pro），可以使用 iosInfo.utsname.machine
          final model = iosInfo.model.trim();
          if (model.isNotEmpty) {
            Logger.info('DeviceInfo', '成功获取iOS设备型号: $model');
            return model;
          }
        }
        
        // 如果获取成功但model为空，跳出循环使用降级方案
        break;
      } catch (e) {
        final isLastAttempt = attempt == maxRetries;
        if (isLastAttempt) {
          Logger.error(
            'DeviceInfo',
            '获取设备型号失败（已重试 $maxRetries 次）: $e',
          );
          Logger.warn(
            'DeviceInfo',
            '使用降级方案：返回平台标识 "$platform"。请确保已运行 "flutter pub get" 并重新构建应用。',
          );
          return platform;
        } else {
          Logger.warn(
            'DeviceInfo',
            '获取设备型号失败（尝试 $attempt/$maxRetries），${retryDelay.inMilliseconds}ms 后重试: $e',
          );
          await Future.delayed(retryDelay);
        }
      }
    }

    // 降级方案：返回平台标识
    return platform;
  }
}

