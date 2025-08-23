import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/local/cache_service.dart';
import '../utils/logger/logger.dart';

/// SharedPreferences Provider
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  Logger.info('CacheProvider', '初始化真实的 SharedPreferences');
  return await SharedPreferences.getInstance();
});

/// 缓存服务 Provider
final cacheServiceProvider = FutureProvider<CacheService>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  Logger.info('CacheProvider', '创建缓存服务');
  return CacheService(storage: SharedPreferencesAdapter(prefs));
});

/// SharedPreferences 适配器
/// 将 SharedPreferences 包装为 CacheStorage 接口
class SharedPreferencesAdapter implements CacheStorage {
  final SharedPreferences _prefs;
  
  SharedPreferencesAdapter(this._prefs);
  
  @override
  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  @override
  Future<bool> setString(String key, String value) async {
    return _prefs.setString(key, value);
  }

  @override
  Future<int?> getInt(String key) async {
    return _prefs.getInt(key);
  }

  @override
  Future<bool> setInt(String key, int value) async {
    return _prefs.setInt(key, value);
  }

  @override
  Future<double?> getDouble(String key) async {
    return _prefs.getDouble(key);
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    return _prefs.setDouble(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    return _prefs.getBool(key);
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    return _prefs.setBool(key, value);
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    return _prefs.getStringList(key);
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    return _prefs.setStringList(key, value);
  }

  @override
  Future<bool> remove(String key) async {
    return _prefs.remove(key);
  }

  @override
  Future<bool> containsKey(String key) async {
    return _prefs.containsKey(key);
  }

  @override
  Future<Set<String>> getKeys() async {
    return _prefs.getKeys();
  }

  @override
  Future<bool> clear() async {
    return _prefs.clear();
  }
}
