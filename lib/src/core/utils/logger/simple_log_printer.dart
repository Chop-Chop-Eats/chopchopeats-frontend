import 'package:logger/logger.dart' as external_logger;

/// 自定义日志打印机，提供简洁的纯文本输出格式。
///
/// 此版本完全移除了 ANSI 颜色代码，以确保在所有平台和终端上都能正确显示，
/// 不会产生乱码。日志通过 Emoji 和结构来区分。
class SimpleLogPrinter extends external_logger.LogPrinter {
  // Emoji 依然保留，用于直观地区分日志级别
  static final _levelEmojis = {
    external_logger.Level.debug: '🐛',
    external_logger.Level.info: '💡',
    external_logger.Level.warning: '⚠️',
    external_logger.Level.error: '🔥',
    external_logger.Level.fatal: '💀',
    external_logger.Level.trace: '🔍',
    external_logger.Level.off: '',
  };

  // --- 移除了颜色相关的代码 ---
  // 1. 移除了 _levelColors 映射
  // 2. 移除了 colors 标志

  final bool printTime;

  // 3. 构造函数中不再需要 colors 参数
  SimpleLogPrinter({this.printTime = true});

  @override
  List<String> log(external_logger.LogEvent event) {
    final timeStr =
        printTime
            ? '${DateTime.now().toIso8601String().substring(11, 23)} '
            : '';
    final emoji = _levelEmojis[event.level] ?? '🤔';

    // 直接组合成最终的字符串，不进行任何颜色处理
    final messageStr = '$emoji $timeStr- ${event.message}';

    final output = [messageStr];

    if (event.error != null) {
      // 直接添加错误字符串
      final errorStr = '  ERROR: ${event.error}';
      output.add(errorStr);
    }

    if (event.stackTrace != null) {
      // 直接添加堆栈信息字符串
      final stackTraceLines = event.stackTrace.toString().split('\n');
      for (final line in stackTraceLines) {
        if (line.trim().isNotEmpty) {
          final stackTraceLineStr = '  $line';
          output.add(stackTraceLineStr);
        }
      }
    }

    return output;
  }
}
