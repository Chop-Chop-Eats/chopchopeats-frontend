import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as external_logger;

/// 一个简单的 ConsoleOutput 包装器，用于避免日志在原生平台上被系统截断。
///
/// Android 的 logcat 对单条日志存在约 4KB 的长度限制，超过部分会被直接丢弃。
/// 通过将日志内容拆分成固定长度的片段逐条输出，可以保证完整日志内容被打印出来，
/// 同时不改变原有的日志格式。
class ChunkedConsoleOutput extends external_logger.LogOutput {
  ChunkedConsoleOutput({this.chunkSize = _defaultChunkSize})
    : assert(chunkSize > 0, 'chunkSize 必须大于 0');

  /// 单个日志片段的最大长度。
  ///
  /// 设为 1000 字符可以兼顾可读性与性能，远小于 logcat 的限制，避免被截断。
  final int chunkSize;

  static const int _defaultChunkSize = 1000;

  @override
  void output(external_logger.OutputEvent event) {
    for (final line in event.lines) {
      _emitLine(line);
    }
  }

  void _emitLine(String line) {
    if (line.length <= chunkSize) {
      debugPrint(line);
      return;
    }

    var startIndex = 0;
    final totalLength = line.length;
    while (startIndex < totalLength) {
      final endIndex = math.min(startIndex + chunkSize, totalLength);
      debugPrint(line.substring(startIndex, endIndex));
      startIndex = endIndex;
    }
  }
}
