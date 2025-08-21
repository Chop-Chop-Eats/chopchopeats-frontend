// lib/utils/logger/log_filter.dart
import 'log_types.dart';

/// 日志过滤器抽象类
abstract class LogFilter {
  bool shouldLog(LogEvent event);
}

/// 动态可配置的通用过滤器
class DynamicFilter extends LogFilter {
  /// 允许的日志等级，只有高于或等于此等级的日志才会输出。
  /// 如果为 null，则不按等级过滤。
  final LogLevel? minLevel;

  /// 只显示包含这些标签的日志。
  /// 如果为 null 或空，则不按标签过滤。
  final Set<String>? allowedTags;

  /// 日志消息必须包含此字符串。
  /// 如果为 null 或空，则不按消息内容过滤。
  final String? messageContains;

  /// 构造函数，用于设置过滤规则
  DynamicFilter({
    this.minLevel,
    this.allowedTags,
    this.messageContains,
  });

  @override
  bool shouldLog(LogEvent event) {
    // 规则1: 按最低等级过滤
    // LogLevel.index 的值是 0(debug), 1(info), 2(warn), 3(error)
    // event.level.index 必须大于等于 minLevel.index
    if (minLevel != null && event.level.index < minLevel!.index) {
      return false;
    }

    // 规则2: 按标签过滤
    // 如果设置了 allowedTags，并且它不为空，那么日志的 tag 必须在其中
    if (allowedTags != null && allowedTags!.isNotEmpty && !allowedTags!.contains(event.tag)) {
      return false;
    }


    // 规则3: 按消息内容过滤 (已升级为大小写不敏感)
    if (messageContains != null && messageContains!.isNotEmpty) {
      // 将日志消息和搜索词都转为小写再进行比较
      final messageString = event.message.toString().toLowerCase();
      final searchTerm = messageContains!.toLowerCase();
      if (!messageString.contains(searchTerm)) {
        return false;
      }
    }

    // 如果通过了以上所有规则，则允许日志输出
    return true;
  }
}
