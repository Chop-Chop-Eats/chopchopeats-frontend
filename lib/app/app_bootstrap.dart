import 'dart:async';
import 'package:flutter/material.dart';
import 'package:unified_popups/unified_popups.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/logger/logger.dart';
import 'app.dart';
import 'app_services.dart';
import 'app_environment.dart';
import 'environment_config.dart';

class AppBootstrap {
  const AppBootstrap._();

  static void _logMilestone(Stopwatch stopwatch, String milestone) {
    Logger.warn("StartupTime", "$milestone - 耗时: ${stopwatch.elapsedMilliseconds}ms");
  }

  static Future<void> run({
    required AppEnvironment environment,
    required Stopwatch stopwatch,
    bool listenToGlobalErrors = true,
  }) async {
    // 使用 runZonedGuarded 来捕获所有顶层错误
    runZonedGuarded<Future<void>>(() async {
      _logMilestone(stopwatch, "启动流程开始 (runZonedGuarded)");

      //  确保 Flutter 核心服务已初始化
      WidgetsFlutterBinding.ensureInitialized();
      _logMilestone(stopwatch, "Flutter 核心绑定 (ensureInitialized) 完成");

      await AppServices.initCacheService();
      _logMilestone(stopwatch, "基础服务 (CacheService) 初始化完成");

      await EnvironmentConfig.initialize(environment);
      _logMilestone(stopwatch, "环境配置 (EnvironmentConfig) 初始化完成");

      await AppServices.initApiService();
      _logMilestone(stopwatch, "应用服务 (AppServices.init) 异步初始化完成");

      //  初始化日志系统的全局错误监听器 (如果开启)
      if (listenToGlobalErrors) {
        Logger.initializeGlobalErrorHandlers();
      }

      //  初始化需要在第一帧绘制后执行的服务
      _initializePostFrameServices(stopwatch);

      //  运行应用
      _logMilestone(stopwatch, "调用 runApp(), 开始构建 Widget 树");
      Logger.info("Bootstrap", "Running in ${environment.name}.Base API URL: ${EnvironmentConfig.config.baseApi} ; suffix: ${EnvironmentConfig.config.apiSuffix}");
      runApp(
        ProviderScope(
          child:App(navigatorKey: AppServices.navigatorKey)
        )
      );
      }, (error, stack) => Logger.logZonedError(error, stack),
    );
  }

  /// 初始化依赖于 Widget 树的服务
  static void _initializePostFrameServices(Stopwatch stopwatch) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logMilestone(stopwatch, "✅ 首帧渲染完成");
      stopwatch.stop(); // 停止计时
      // 从服务注册表中获取 navigatorKey
      PopupManager.initialize(navigatorKey: AppServices.navigatorKey);
      Logger.info("Bootstrap", "PopupManager initialized successfully.");
    });
  }

}