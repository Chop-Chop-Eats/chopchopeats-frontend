import 'dart:convert';
import '../../../core/config/app_services.dart';
import '../../../core/utils/logger/logger.dart';
import '../providers/cart_state.dart';

class CartStorage {
  static const _prefix = 'cart_';
  static const _version = 1;

  String _key(String shopId) => '$_prefix$shopId';

  /// 读取完整的购物车状态（包括待同步操作）
  /// 从 Hive 读取（使用 TypeAdapter）
  Future<CartState?> readFullState(String shopId) async {
    final key = _key(shopId);
    
    // 从 Hive 读取（使用 TypeAdapter）
    final state = await AppServices.cache.getObject<CartState>(key);
    if (state != null) {
      Logger.info(
        'CartStorage',
        '从 Hive 读取完整状态成功: shopId=$shopId, items=${state.items.length}, '
        'pendingOps=${state.pendingOperations.length}',
      );
      return state;
    }
    
    // 如果 Hive 中没有，尝试从 JSON 字符串读取（兼容旧数据格式）
    try {
      final jsonString = await AppServices.cache.get<String>(key);
      
      if (jsonString == null) {
        return null;
      }
      
      // 解析 JSON
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final version = jsonData['version'] as int? ?? 0;
      if (version != _version) {
        await AppServices.cache.remove(key);
        Logger.warn('CartStorage', '版本不匹配，清理缓存: shopId=$shopId');
        return null;
      }
      
      final state = CartState.fromStorageJson(shopId, jsonData);
      Logger.info(
        'CartStorage',
        '从 JSON 读取完整状态成功: shopId=$shopId, items=${state.items.length}, '
        'pendingOps=${state.pendingOperations.length}',
      );
      
      // 迁移到 Hive TypeAdapter
      await write(state);
      
      return state;
    } catch (e) {
      Logger.error('CartStorage', '解析完整状态失败，移除本地缓存: $e');
      await AppServices.cache.remove(key);
      return null;
    }
  }

  /// 写入购物车状态（使用 Hive TypeAdapter）
  Future<void> write(CartState state) async {
    final key = _key(state.shopId);
    
    // 使用 Hive TypeAdapter 存储
    final success = await AppServices.cache.setObject<CartState>(key, state);
    
    if (success) {
      Logger.info(
        'CartStorage',
        '写入缓存（Hive）: shopId=${state.shopId}, items=${state.items.length}, '
        'pendingOps=${state.pendingOperations.length}',
      );
    } else {
      Logger.warn('CartStorage', '写入 Hive 失败，尝试使用 JSON 存储');
      // 如果 Hive 写入失败，回退到 JSON 存储
      final payload = {
        'version': _version,
        ...state.toStorageJson(savedAt: DateTime.now()),
      };
      await AppServices.cache.set(key, payload);
    }
  }

  /// 移除购物车缓存
  Future<void> remove(String shopId) async {
    final key = _key(shopId);
    await AppServices.cache.remove(key);
    Logger.info('CartStorage', '移除缓存: shopId=$shopId');
  }
}
