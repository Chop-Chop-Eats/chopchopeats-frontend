// lib/utils/logger/logger.dart
import 'package:flutter/foundation.dart';
import 'log_types.dart';

/// 核心 Logger 类
/// 使用 print 输出日志，确保在 Flutter 控制台中可见
class Logger {
  Logger._();

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

  /// Debug 级别日志
  static void debug(String? tag, dynamic message) {
    _log(LogLevel.debug, tag, message);
  }

  /// Info 级别日志
  static void info(String? tag, dynamic message) {
    _log(LogLevel.info, tag, message);
  }

  /// Warn 级别日志
  static void warn(String? tag, dynamic message) {
    _log(LogLevel.warn, tag, message);
  }

  /// Error 级别日志
  static void error(String? tag, dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.error, tag, message, error: error, stackTrace: stackTrace);
  }

  /// 内部日志方法
  static void _log(LogLevel level, String? tag, dynamic message, {dynamic error, StackTrace? stackTrace}) {
    final tagStr = tag != null ? "[$tag]" : "";
    final levelStr = level.toString().split('.').last.toUpperCase();
    
    // 构建日志消息
    final logMessage = "$tagStr $levelStr: $message";
    
    // 使用 print 输出，确保在 Flutter 控制台中可见
    print(logMessage);
    
    // 如果有错误或堆栈信息，额外输出
    if (error != null) {
      print("$tagStr ERROR Details: $error");
    }
    if (stackTrace != null) {
      print("$tagStr STACK TRACE:\n$stackTrace");
    }
  }
}
