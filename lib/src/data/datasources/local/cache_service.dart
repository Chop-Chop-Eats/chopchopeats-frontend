import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/logger/logger.dart';

/// 缓存存储接口
/// 抽象化存储实现，便于测试和模拟
abstract class CacheStorage {
  Future<String?> getString(String key);
  Future<bool> setString(String key, String value);
  Future<int?> getInt(String key);
  Future<bool> setInt(String key, int value);
  Future<double?> getDouble(String key);
  Future<bool> setDouble(String key, double value);
  Future<bool?> getBool(String key);
  Future<bool> setBool(String key, bool value);
  Future<List<String>?> getStringList(String key);
  Future<bool> setStringList(String key, List<String> value);
  Future<bool> remove(String key);
  Future<bool> clear();
  Future<bool> containsKey(String key);
  Future<Set<String>> getKeys();
}

/// SharedPreferences 的适配器实现
class SharedPreferencesAdapter implements CacheStorage {
  final SharedPreferences _prefs;
  
  SharedPreferencesAdapter(this._prefs);
  
  @override
  Future<String?> getString(String key) => Future.value(_prefs.getString(key));
  
  @override
  Future<bool> setString(String key, String value) => _prefs.setString(key, value);
  
  @override
  Future<int?> getInt(String key) => Future.value(_prefs.getInt(key));
  
  @override
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);
  
  @override
  Future<double?> getDouble(String key) => Future.value(_prefs.getDouble(key));
  
  @override
  Future<bool> setDouble(String key, double value) => _prefs.setDouble(key, value);
  
  @override
  Future<bool?> getBool(String key) => Future.value(_prefs.getBool(key));
  
  @override
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
  
  @override
  Future<List<String>?> getStringList(String key) => Future.value(_prefs.getStringList(key));
  
  @override
  Future<bool> setStringList(String key, List<String> value) => _prefs.setStringList(key, value);
  
  @override
  Future<bool> remove(String key) => _prefs.remove(key);
  
  @override
  Future<bool> clear() => _prefs.clear();
  
  @override
  Future<bool> containsKey(String key) => Future.value(_prefs.containsKey(key));
  
  @override
  Future<Set<String>> getKeys() => Future.value(_prefs.getKeys());
}

/// 本地缓存服务
///
/// 基于抽象存储接口封装，提供统一的缓存读写接口。
/// 支持基本类型和可序列化为 JSON 的复杂对象。
class CacheService {
  final CacheStorage _storage;

  CacheService({required CacheStorage storage}) : _storage = storage;

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
        result = await _storage.setString(key, value);
      } else if (value is int) {
        result = await _storage.setInt(key, value);
      } else if (value is double) {
        result = await _storage.setDouble(key, value);
      } else if (value is bool) {
        result = await _storage.setBool(key, value);
      } else if (value is List<String>) {
        result = await _storage.setStringList(key, value);
      } else {
        // 对于复杂对象，将其序列化为 JSON 字符串进行存储
        final jsonString = jsonEncode(value);
        result = await _storage.setString(key, jsonString);
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
      // 根据泛型类型 T 来决定如何读取数据
      if (T == String) {
        final value = await _storage.getString(key);
        return value as T?;
      } else if (T == int) {
        final value = await _storage.getInt(key);
        return value as T?;
      } else if (T == double) {
        final value = await _storage.getDouble(key);
        return value as T?;
      } else if (T == bool) {
        final value = await _storage.getBool(key);
        return value as T?;
      } else if (T == List<String>) {
        final value = await _storage.getStringList(key);
        return value as T?;
      } else if (T == Map<String, dynamic>) {
        // 对于 Map 类型，尝试从字符串中读取 JSON
        final jsonString = await _storage.getString(key);
        if (jsonString != null) {
          try {
            final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
            return decoded as T?;
          } catch (e) {
            Logger.warn("CacheService", "Failed to decode JSON for key '$key': $e");
            return null;
          }
        }
        return null;
      } else {
        // 对于其他类型，尝试使用 fromJson 工厂函数
        if (fromJson != null) {
          final jsonString = await _storage.getString(key);
          if (jsonString != null) {
            try {
              final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
              return fromJson(decoded);
            } catch (e) {
              Logger.warn("CacheService", "Failed to decode JSON for key '$key': $e");
              return null;
            }
          }
        }
        return null;
      }
    } catch (e, s) {
      Logger.error("CacheService", "Failed to get cache for key: $key", error: e, stackTrace: s);
      return null;
    }
  }

  /// 移除指定键的缓存
  Future<bool> remove(String key) async {
    try {
      final result = await _storage.remove(key);
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
  /// **警告**: 此操作会移除所有通过存储接口存储的数据，请谨慎使用。
  Future<bool> clear() async {
    try {
      final result = await _storage.clear();
      // 操作成功后记录日志
      if (result) {
        Logger.info("CacheService", "Cleared all cache data.");
      }
      return result;
    } catch (e, s) {
      Logger.error("CacheService", "Failed to clear cache", error: e, stackTrace: s);
      return false;
    }
  }

  /// 检查指定键是否存在
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key);
    } catch (e, s) {
      Logger.error("CacheService", "Failed to check if key exists: $key", error: e, stackTrace: s);
      return false;
    }
  }

  /// 获取所有缓存的键
  Future<Set<String>> getKeys() async {
    try {
      return await _storage.getKeys();
    } catch (e, s) {
      Logger.error("CacheService", "Failed to get all keys", error: e, stackTrace: s);
      return <String>{};
    }
  }
}
