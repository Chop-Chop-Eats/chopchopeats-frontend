import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/logger/logger.dart';


/// 本地缓存服务
///
/// 基于 SharedPreferences 封装，提供统一的缓存读写接口。
/// 支持基本类型和可序列化为 JSON 的复杂对象。
class CacheService {
  final SharedPreferences _prefs;

  CacheService({required SharedPreferences prefs}) : _prefs = prefs;

  /// 保存数据
  ///
  /// [key] - 缓存的键
  /// [value] - 要缓存的值。可以是 int, double, bool, String, List<String>，
  ///           也可以是任何可以被 jsonEncode 转换的对象。
  ///
  /// 返回 `true` 如果保存成功，否则 `false`。
  Future<bool> set<T>(String key, T value) async {
    try {
      bool result;
      if (value is String) {
        result = await _prefs.setString(key, value);
      } else if (value is int) {
        result = await _prefs.setInt(key, value);
      } else if (value is double) {
        result = await _prefs.setDouble(key, value);
      } else if (value is bool) {
        result = await _prefs.setBool(key, value);
      } else if (value is List<String>) {
        result = await _prefs.setStringList(key, value);
      } else {
        // 对于复杂对象，将其序列化为 JSON 字符串进行存储
        final jsonString = jsonEncode(value);
        result = await _prefs.setString(key, jsonString);
      }

      // 操作成功后记录日志
      if (result) {
        Logger.info("CacheService", "Set cache for key: '$key' (value: ${value})");
      }
      return result;
    } catch (e, s) {
      Logger.error("CacheService", "Failed to set cache for key: $key", error: e, stackTrace: s);
      return false;
    }
  }

  /// 读取数据
  ///
  /// [key] - 缓存的键
  /// [fromJson] - (可选) 当读取复杂对象时，提供一个从 Map<String, dynamic>
  ///              转换回对象的工厂函数。
  ///
  /// 返回缓存的值，如果键不存在或类型不匹配，则返回 `null`。
  Future<T?> get<T>(String key, {T Function(Map<String, dynamic> json)? fromJson}) async {
    try {
      final dynamic value = _prefs.get(key);

      if (value == null) {
        return null;
      }

      // 如果提供了 fromJson 函数，说明我们期望的是一个复杂对象
      if (fromJson != null) {
        if (value is String) {
          // 解码 JSON 字符串并使用工厂函数转换
          final decoded = jsonDecode(value) as Map<String, dynamic>;
          return fromJson(decoded);
        } else {
          Logger.warn("CacheService", "Value for key '$key' is not a JSON String, but a fromJson factory was provided.");
          return null;
        }
      }

      // 否则，我们期望的是一个基本类型
      if (value is T) {
        return value;
      }

      Logger.warn("CacheService", "Type mismatch for key '$key'. Expected $T but got ${value.runtimeType}.");
      return null;
    } catch (e, s) {
      Logger.error("CacheService", "Failed to get cache for key: $key", error: e, stackTrace: s);
      return null;
    }
  }

  /// 移除指定键的缓存
  Future<bool> remove(String key) async {
    try {
      final result = await _prefs.remove(key);
      // 操作成功后记录日志
      if (result) {
        Logger.info("CacheService", "Removed cache for key: '$key'.");
      }
      return result;
    } catch (e, s) {
      Logger.error("CacheService", "Failed to remove cache for key: $key", error: e, stackTrace: s);
      return false;
    }
  }

  /// 清空所有缓存
  ///
  /// **警告**: 此操作会移除所有通过 SharedPreferences 存储的数据，请谨慎使用。
  Future<bool> clear() async {
    try {
      final result = await _prefs.clear();
      // 操作成功后记录日志
      if (result) {
        Logger.info("CacheService", "All cache cleared successfully.");
      }
      return result;
    } catch (e, s) {
      Logger.error("CacheService", "Failed to clear all cache.", error: e, stackTrace: s);
      return false;
    }
  }
}
