import 'dart:convert';

/// JSON数据转换工具类
///
/// 提供通用的JSON数据类型转换方法，避免类型转换错误
class JsonUtils {
  JsonUtils._();

  /// 将JSON中的List转换为指定类型的List
  /// 
  /// 参数:
  /// - [json]: 原始JSON对象
  /// - [key]: 要提取的字段名
  /// - [fromJson]: 将Map转换为目标类型的函数
  /// 
  /// 返回:
  /// - 转换后的List，如果字段不存在或为null则返回null
  /// 
  /// 使用示例:
  /// ```dart
  /// final tags = JsonUtils.parseList<TagInfo>(
  ///   json, 
  ///   'chineseTagList', 
  ///   (e) => TagInfo.fromJson(e)
  /// );
  /// ```
  static List<T>? parseList<T>(
    Map<String, dynamic> json,
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final value = json[key];
    if (value == null) return null;

    dynamic listValue = value;
    if (value is String) {
      if (value.isEmpty) return null;
      try {
        // 兼容后端把列表以 JSON 字符串返回的情况
        listValue = jsonDecode(value);
      } catch (e) {
        return null;
      }
    }

    if (listValue is! List) return null;
    
    try {
      final result = <T>[];
      for (var i = 0; i < listValue.length; i++) {
        final e = listValue[i];
        if (e == null) {
          // 跳过 null 元素
          continue;
        }
        try {
          Map<String, dynamic>? itemMap;
          if (e is Map) {
            itemMap = Map<String, dynamic>.from(e);
          } else if (e is String) {
            final decoded = jsonDecode(e);
            if (decoded is Map) {
              itemMap = Map<String, dynamic>.from(decoded);
            }
          }

          if (itemMap == null) {
            // 跳过非 Map 元素
            continue;
          }

          final item = fromJson(itemMap);
          result.add(item);
        } catch (itemError) {
          // 记录单个元素的解析错误，但继续处理其他元素
          print('⚠️ parseList: 跳过第 $i 个元素（解析失败）: $itemError');
          continue;
        }
      }
      return result;
    } catch (e, stack) {
      // 如果转换失败，打印错误并返回null
      print('🔥 parseList: 整体解析失败: $e');
      print('🔥 Stack: $stack');
      return null;
    }
  }

  /// 将JSON中的时间戳转换为DateTime对象
  /// 
  /// 参数:
  /// - [json]: 原始JSON对象
  /// - [key]: 要提取的字段名
  /// 
  /// 返回:
  /// - DateTime对象，如果字段不存在或为null则返回null
  /// 
  /// 使用示例:
  /// ```dart
  /// final approveTime = JsonUtils.parseDateTime(json, 'approveTime');
  /// ```
  static DateTime? parseDateTime(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    
    try {
      return DateTime.fromMillisecondsSinceEpoch(value as int);
    } catch (e) {
      return null;
    }
  }

  /// 将JSON中的值转换为double类型
  /// 
  /// 参数:
  /// - [json]: 原始JSON对象
  /// - [key]: 要提取的字段名
  /// 
  /// 返回:
  /// - double值，如果字段不存在或为null则返回null
  /// 
  /// 使用示例:
  /// ```dart
  /// final distance = JsonUtils.parseDouble(json, 'distance');
  /// ```
  static double? parseDouble(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    
    try {
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        return double.tryParse(value);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 将JSON中的值转换为int类型
  /// 
  /// 参数:
  /// - [json]: 原始JSON对象
  /// - [key]: 要提取的字段名
  /// 
  /// 返回:
  /// - int值，如果字段不存在或为null则返回null
  /// 
  /// 使用示例:
  /// ```dart
  /// final count = JsonUtils.parseInt(json, 'commentCount');
  /// ```
  static int? parseInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    
    try {
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      if (value is String) {
        return int.tryParse(value);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 将JSON中的值转换为bool类型
  /// 
  /// 参数:
  /// - [json]: 原始JSON对象
  /// - [key]: 要提取的字段名
  /// 
  /// 返回:
  /// - bool值，如果字段不存在或为null则返回null
  /// 
  /// 使用示例:
  /// ```dart
  /// final isFavorite = JsonUtils.parseBool(json, 'favorite');
  /// ```
  static bool? parseBool(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    
    try {
      if (value is bool) {
        return value;
      }
      if (value is int) {
        return value == 1;
      }
      if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 将JSON中的值转换为String类型
  /// 
  /// 参数:
  /// - [json]: 原始JSON对象
  /// - [key]: 要提取的字段名
  /// 
  /// 返回:
  /// - String值，如果字段不存在或为null则返回null
  /// 
  /// 使用示例:
  /// ```dart
  /// final name = JsonUtils.parseString(json, 'shopName');
  /// ```
  static String? parseString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    
    try {
      return value.toString();
    } catch (e) {
      return null;
    }
  }
}
