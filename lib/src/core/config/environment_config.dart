import '../constants/app_constant.dart';
import '../utils/logger/logger.dart';
import '../../app_services.dart';
import 'app_config.dart';
import 'app_environment.dart';

/// 环境配置管理中心 (服务定位器模式)
class EnvironmentConfig {
  /// 私有构造函数，防止外部实例化
  EnvironmentConfig._();

  /// 当前环境的配置实例
  static late final AppConfig _config;

  /// 存储当前环境的枚举值
  static late final AppEnvironment _environment;

  /// 初始化方法，必须在应用启动时调用
  ///
  /// 它根据传入的 [AppEnvironment] 来设置对应的 [AppConfig]。
  static Future<void> initialize(AppEnvironment environment)  async {
    _environment = environment;
    switch (environment) {
      case AppEnvironment.development:
        _config = AppConfig(
          baseApi: AppConfig.devApi,
        );
        break;
      case AppEnvironment.production:
        _config =  AppConfig(
          baseApi: AppConfig.proApi,
        );
        break;
    }
  }

  /// 提供一个公共的 getter 来访问配置
  static AppConfig get config => _config;

  /// 提供布尔类型的 getter，用于快速判断环境
  static bool get isDevelopment => _environment == AppEnvironment.development;

  /// 同上，用于判断生产环境
  static bool get isProduction => _environment == AppEnvironment.production;

}