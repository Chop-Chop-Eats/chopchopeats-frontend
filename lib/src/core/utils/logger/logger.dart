// lib/utils/logger/logger.dart
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as external_logger;
import 'chunked_console_output.dart';
import 'log_types.dart';
import 'simple_log_printer.dart';

class Logger {
  Logger._();

  // 创建全局日志实例
  static final external_logger.Logger _logger = external_logger.Logger(
    printer: SimpleLogPrinter(),
    level:
        kDebugMode
            ? external_logger.Level.debug
            : external_logger.Level.warning,
    output: ChunkedConsoleOutput(), // 输出到控制台且不会被系统截断
  );

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
  static void error(
    String? tag,
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.error, tag, message, error: error, stackTrace: stackTrace);
  }

  /// 内部日志方法
  static void _log(
    LogLevel level,
    String? tag,
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    // 保持原有的 Tag 拼接逻辑，这样最灵活
    final tagStr = tag != null ? "[$tag]" : "";
    final logMessage = "$tagStr $message";

    // 根据日志级别调用对应的logger方法
    // 注意：我们将 LogLevel 映射到 external_logger.Level
    switch (level) {
      case LogLevel.debug:
        _logger.d(logMessage, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.info:
        _logger.i(logMessage, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.warn:
        _logger.w(logMessage, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.error:
        _logger.e(logMessage, error: error, stackTrace: stackTrace);
        break;
    }
  }
}
