// lib/utils/logger/log_types.dart

/// 日志等级
enum LogLevel { debug, info, warn, error }

/// 日志事件数据类
/// 封装了日志的所有相关信息，便于在系统内部传递。
class LogEvent {
  final LogLevel level;
  final dynamic message;
  final String? tag;
  final dynamic error;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  LogEvent({
    required this.level,
    required this.message,
    required this.timestamp,
    this.tag,
    this.error,
    this.stackTrace,
  });
}
