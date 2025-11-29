import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../core/utils/logger/logger.dart';

/// 本地缓存服务
///
/// 基于 Hive 封装，提供统一的缓存读写接口。
/// 支持基本类型和可序列化为 JSON 的复杂对象。
class CacheService {
  // Hive Boxes
  Box<String>? _stringsBox;
  Box<int>? _intsBox;
  Box<double>? _doublesBox;
  Box<bool>? _boolsBox;

  CacheService();
  
  /// 初始化 Hive Boxes
  Future<void> init() async {
    try {
      // 打开 Boxes
      _stringsBox = await Hive.openBox<String>('strings');
      _intsBox = await Hive.openBox<int>('ints');
      _doublesBox = await Hive.openBox<double>('doubles');
      _boolsBox = await Hive.openBox<bool>('bools');
      
      Logger.info('CacheService', 'Hive Boxes 初始化成功');
    } catch (e, s) {
      Logger.error('CacheService', '初始化 Hive Boxes 失败', error: e, stackTrace: s);
      rethrow; // 如果 Hive 初始化失败，抛出异常
    }
  }

  /// 保存数据
  ///
  /// [key] - 缓存的键
  /// [value] - 要缓存的值。可以是 int, double, bool, String, List<String>，
  ///           也可以是任何可以被 jsonEncode 转换的对象。
  ///
  /// 返回 `true` 如果保存成功，否则 `false`。
  Future<bool> set<T>(String key, T value) async {
    try {
      // 确保 Hive Boxes 已初始化
      if (_stringsBox == null || _intsBox == null || _doublesBox == null || _boolsBox == null) {
        Logger.error("CacheService", "Hive Boxes 未初始化，无法保存数据");
        return false;
      }
      
      if (value is String) {
        await _stringsBox!.put(key, value);
      } else if (value is int) {
        await _intsBox!.put(key, value);
      } else if (value is double) {
        await _doublesBox!.put(key, value);
      } else if (value is bool) {
        await _boolsBox!.put(key, value);
      } else if (value is List<String>) {
        // List<String> 存储为 JSON 字符串
        final jsonString = jsonEncode(value);
        await _stringsBox!.put(key, jsonString);
      } else {
        // 对于复杂对象，将其序列化为 JSON 字符串进行存储
        final jsonString = jsonEncode(value);
        await _stringsBox!.put(key, jsonString);
      }

      Logger.info("CacheService", "Set cache for key: '$key'");
      return true;
    } catch (e, s) {
      Logger.error("CacheService", "Failed to set cache for key: $key", error: e, stackTrace: s);
      return false;
    }
  }
  
  /// 保存复杂对象（序列化为 JSON 存储）
  /// 
  /// [key] - 缓存的键
  /// [value] - 要缓存的对象（会被序列化为 JSON）
  Future<bool> setObject<T>(String key, T value) async {
    // 回退到 JSON 存储
    return await set(key, value);
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
      // 确保 Hive Boxes 已初始化
      if (_stringsBox == null || _intsBox == null || _doublesBox == null || _boolsBox == null) {
        Logger.error("CacheService", "Hive Boxes 未初始化，无法读取数据");
        return null;
      }
      
      dynamic value;
      
      if (T == String) {
        value = _stringsBox!.get(key);
      } else if (T == int) {
        value = _intsBox!.get(key);
      } else if (T == double) {
        value = _doublesBox!.get(key);
      } else if (T == bool) {
        value = _boolsBox!.get(key);
      } else if (T == List<String>) {
        final jsonString = _stringsBox!.get(key);
        if (jsonString != null) {
          value = List<String>.from(jsonDecode(jsonString) as List);
        }
      }
      
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
  
  /// 读取复杂对象（从 JSON 反序列化）
  /// 
  /// [key] - 缓存的键
  /// [fromJson] - 从 Map<String, dynamic> 转换回对象的工厂函数
  /// 返回缓存的对象，如果不存在则返回 null
  Future<T?> getObject<T>(String key, {required T Function(Map<String, dynamic> json) fromJson}) async {
    return await get<T>(key, fromJson: fromJson);
  }

  /// 移除指定键的缓存
  Future<bool> remove(String key) async {
    try {
      // 确保 Hive Boxes 已初始化
      if (_stringsBox == null) {
        Logger.error("CacheService", "Hive Boxes 未初始化，无法移除数据");
        return false;
      }
      
      // 从所有 Hive Boxes 移除
      await _stringsBox!.delete(key);
      await _intsBox?.delete(key);
      await _doublesBox?.delete(key);
      await _boolsBox?.delete(key);
      
      Logger.info("CacheService", "Removed cache for key: '$key'.");
      return true;
    } catch (e, s) {
      Logger.error("CacheService", "Failed to remove cache for key: $key", error: e, stackTrace: s);
      return false;
    }
  }

  /// 清空所有缓存
  ///
  /// **警告**: 此操作会清空所有 Hive Boxes 中的数据，请谨慎使用。
  Future<bool> clear() async {
    try {
      if (_stringsBox == null) {
        Logger.error("CacheService", "Hive Boxes 未初始化，无法清空数据");
        return false;
      }
      
      await _stringsBox!.clear();
      await _intsBox?.clear();
      await _doublesBox?.clear();
      await _boolsBox?.clear();
      
      Logger.info("CacheService", "All cache cleared successfully.");
      return true;
    } catch (e, s) {
      Logger.error("CacheService", "Failed to clear all cache.", error: e, stackTrace: s);
      return false;
    }
  }
}
