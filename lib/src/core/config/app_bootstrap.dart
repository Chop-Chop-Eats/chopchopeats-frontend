import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:unified_popups/unified_popups.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../push/push_service.dart';
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

      // 初始化 Firebase（优雅处理配置文件缺失的情况）
      try {
        await Firebase.initializeApp(); // 初始化 Firebase
        _logMilestone(stopwatch, "Firebase 初始化完成");
        
        // 注册后台消息处理器（必须在 runApp() 之前）
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
        
        // 初始化推送服务
        await PushService().init();
        _logMilestone(stopwatch, "推送服务初始化完成");
      } catch (e, stack) {
        Logger.error("Bootstrap", "Firebase 初始化失败（可能缺少配置文件）: $e");
        Logger.warn("Bootstrap", "应用将在没有推送通知功能的情况下继续运行");
        // 不阻止应用启动，继续运行
      }

      //  初始化需要在第一帧绘制后执行的服务
      _initializePostFrameServices(stopwatch);

      //  运行应用
      _logMilestone(stopwatch, "调用 runApp(), 开始构建 Widget 树");
      Logger.info("Bootstrap", "Running in ${environment.name}.Base API URL: ${EnvironmentConfig.config.baseApi}");
      Logger.info("Bootstrap", "当前语言: ${AppServices.appSettings.locale?.languageCode}; 当前主题: ${AppServices.appSettings.themeMode.name}");
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