// lib/utils/logger/log_output.dart
import 'dart:convert';
import 'log_types.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// 日志输出器抽象类
/// 负责将 LogEvent 格式化并输出到某个目的地。
abstract class LogOutput {
  void init() {}
  void output(LogEvent event);
  void destroy() {}
}

/// 控制台输出器
/// 负责将日志以彩色格式打印到控制台。
class ConsoleOutput extends LogOutput {
  static const Map<LogLevel, String> _levelColors = {
    LogLevel.debug: '\x1B[33m', // Yellow
    LogLevel.info:  '\x1B[32m', // Green
    LogLevel.warn:  '\x1B[34m', // Blue
    LogLevel.error: '\x1B[31m', // Red
  };
  static const String _resetColor = '\x1B[0m';

  // 决定是否使用颜色
  final bool _supportsAnsiColors;

  // 在构造函数中进行判断
  ConsoleOutput() : _supportsAnsiColors = _checkColorSupport();

  static bool _checkColorSupport() {
    if (kIsWeb) {
      return true; // Web 浏览器控制台普遍支持
    }
    // 在移动端，只有 Android 的 Logcat (被 AS 解析时) 支持得比较好
    // iOS 的 os_log 会过滤掉，所以对 iOS 返回 false
    return Platform.isAndroid;
  }


  @override
  void output(LogEvent event) {
    final buffer = StringBuffer();

    // 根据是否支持来决定是否添加颜色代码
    final color = _supportsAnsiColors ? (_levelColors[event.level] ?? '') : '';
    final resetColor = _supportsAnsiColors ? _resetColor : '';

    final timestamp = _formatTimestamp(event.timestamp);
    final level = event.level.toString().split('.').last.toUpperCase();
    final tag = event.tag != null ? "[${event.tag}]" : "";

    buffer.write('$color$timestamp $level $tag: ');
    buffer.write(_formatMessage(event.message));
    buffer.write(resetColor);

    if (event.error != null) {
      buffer.write('\nError: ${event.error}');
    }
    if (event.stackTrace != null) {
      buffer.write('\nStackTrace:\n${event.stackTrace}');
    }

    // ignore: avoid_print
    print(buffer.toString());
  }

  String _formatMessage(dynamic message) {
    if (message is Map || message is List) {
      return const JsonEncoder.withIndent('  ').convert(message);
    } else if (message is String) {
      try {
        final decoded = json.decode(message);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      } catch (e) {
        return message;
      }
    }
    return message.toString();
  }

  String _formatTimestamp(DateTime time) {
    return '${time.year.toString().padLeft(2, '0')}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(3, '0')}';
  }
}
