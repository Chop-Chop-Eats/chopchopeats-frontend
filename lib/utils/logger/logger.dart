// lib/utils/logger/logger.dart
import 'package:flutter/foundation.dart';
import 'log_types.dart';
import 'log_filter.dart';
import 'log_output.dart';

/// 核心 Logger 类
/// 负责接收日志请求，并通过过滤器和输出器进行处理。
class Logger {
  final LogFilter _filter;
  final List<LogOutput> _outputs;

  /// 私有构造函数，用于创建可配置的 Logger 实例
  Logger._({
    required LogFilter filter,
    required List<LogOutput> outputs,
  })  : _filter = filter,
        _outputs = outputs;

  // ------------------------------------------------------------------
  //  核心配置区域: 在这里切换不同场景下的日志行为
  // ------------------------------------------------------------------
  static final Logger I = Logger._(

    // 使用 DynamicFilter，通过修改参数来控制日志行为
    filter: _getEffectiveFilter(),

    outputs: [ConsoleOutput()],
  );

  /// 根据不同场景返回最合适的过滤器配置
  static LogFilter _getEffectiveFilter() {
    // 场景1: 最终上架的 Release 包，完全禁止日志
    if (kReleaseMode) {
      // 在 Release 模式下，默认返回一个永远返回 false 的过滤器
      return DynamicFilter(minLevel: LogLevel.error, allowedTags: {'NEVER_MATCH'}); // 一个永远不会匹配的配置
    }

    // 场景2: 日常开发或内部测试，按需配置
    // 在这里修改配置，即可动态改变日志输出，无需创建新类
    return DynamicFilter(
      // --- 按需修改下面的配置来进行调试 ---

      // 例 A: 查看所有日志 (默认行为)
      minLevel: LogLevel.debug,

      // 例 B: 只看 'home' 模块的日志
      // allowedTags: {'StartupTime'},

      // 例 C: 只看 'home' 和 'detail' 模块的日志
      // allowedTags: {'home', 'detail'},

      // 例 D: 只看 'warn' 和 'error' 级别的日志
      // minLevel: LogLevel.warn,

      // 例 E: 只看 'API' 模块的 'error' 日志
      // minLevel: LogLevel.error,
      // allowedTags: {'API'},

      // 例 F: 查找所有内容包含 "failed" 的日志
      // messageContains: 'failed',
    );
  }


  /// 初始化全局错误监听器，将 Flutter 和平台错误重定向到本 Logger。
  ///
  /// 应该在应用启动的早期阶段调用，例如在 AppBootstrap.run() 中。
  ///
  /// [catchFlutterErrors] 控制是否监听 Flutter 框架错误 (FlutterError.onError)。
  /// [catchPlatformErrors] 控制是否监听 Isolate 平台错误 (PlatformDispatcher.instance.onError)。
  static void initializeGlobalErrorHandlers({
    bool catchFlutterErrors = true,
    bool catchPlatformErrors = true,
  }) {
    if (catchFlutterErrors) {
      FlutterError.onError = (details) {
        Logger.error(
          "Flutter Error",
          "Framework error caught.",
          error: details.exception,
          stackTrace: details.stack,
        );
      };
    }

    if (catchPlatformErrors) {
      PlatformDispatcher.instance.onError = (error, stack) {
        Logger.error(
          "Platform Error",
          "Isolate error caught.",
          error: error,
          stackTrace: stack,
        );
        return true; // 表示错误已被处理
      };
    }
  }

  /// 专门用于记录来自 runZonedGuarded 的未捕获错误。
  ///
  /// 在 runZonedGuarded 的 onError 回调中调用此方法。
  static void logZonedError(Object error, StackTrace stack) {
    Logger.error(
      "Zoned Error",
      "Unhandled error caught by Zone.",
      error: error,
      stackTrace: stack,
    );
  }

  /// 核心日志分发方法
  void log({
    required LogLevel level,
    required dynamic message,
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    final event = LogEvent(
      level: level,
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
    );

    if (_filter.shouldLog(event)) {
      for (final output in _outputs) {
        output.output(event);
      }
    }
  }

  /// 静态便捷方法，代理到单例实例
  static void debug(String? tag, dynamic message) {
    I.log(level: LogLevel.debug, message: message, tag: tag);
  }

  static void info(String? tag, dynamic message) {
    I.log(level: LogLevel.info, message: message, tag: tag);
  }

  static void warn(String? tag, dynamic message) {
    I.log(level: LogLevel.warn, message: message, tag: tag);
  }

  static void error(String? tag, dynamic message, {dynamic error, StackTrace? stackTrace}) {
    I.log(
      level: LogLevel.error,
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
