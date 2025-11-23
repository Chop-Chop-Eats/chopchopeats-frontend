import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/logger/logger.dart';
import '../models/order_model.dart';
import '../providers/cart_state.dart';

class CartStorageEntry {
  CartStorageEntry({
    required this.shopId,
    required this.diningDate,
    required this.items,
    required this.totals,
    required this.savedAt,
  });

  final String shopId;
  final String? diningDate; // 格式: YYYY-MM-DD
  final List<CartItemModel> items;
  final CartTotals totals;
  final DateTime savedAt;

  Map<String, dynamic> toMap() {
    return {
      'shopId': shopId,
      'diningDate': diningDate,
      'items': items.map((e) => e.toJson()).toList(),
      'totals': totals.toJson(),
      'savedAt': savedAt.toIso8601String(),
    };
  }

  factory CartStorageEntry.fromMap(Map<String, dynamic> map) {
    final rawItems =
        (map['items'] as List<dynamic>? ?? [])
            .map(
              (e) =>
                  CartItemModel.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
    return CartStorageEntry(
      shopId: map['shopId'] as String? ?? '',
      diningDate: map['diningDate'] as String?,
      items: rawItems,
      totals: CartTotals.fromJson(map['totals'] as Map<String, dynamic>?),
      savedAt:
          DateTime.tryParse(map['savedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class CartStorage {
  static const _prefix = 'cart_';
  static const _version = 1;

  String _key(String shopId) => '$_prefix$shopId';

  Future<CartStorageEntry?> read(String shopId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(shopId));
    if (raw == null) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final version = decoded['version'] as int? ?? 0;
      if (version != _version) {
        await prefs.remove(_key(shopId));
        Logger.warn('CartStorage', '版本不匹配，清理缓存: shopId=$shopId');
        return null;
      }
      final entry = CartStorageEntry.fromMap(decoded);
      Logger.info(
        'CartStorage',
        '读取缓存成功: shopId=$shopId, items=${entry.items.length}',
      );
      return entry;
    } catch (e) {
      Logger.error('CartStorage', '解析缓存失败，移除本地缓存: $e');
      await prefs.remove(_key(shopId));
      return null;
    }
  }

  Future<void> write(CartState state) async {
    final prefs = await SharedPreferences.getInstance();
    final entry = CartStorageEntry(
      shopId: state.shopId,
      diningDate: state.diningDate,
      items: state.items,
      totals: state.totals,
      savedAt: DateTime.now(),
    );
    final payload = {'version': _version, ...entry.toMap()};
    await prefs.setString(_key(state.shopId), jsonEncode(payload));
    Logger.info(
      'CartStorage',
      '写入缓存: shopId=${state.shopId}, items=${state.items.length}',
    );
  }

  Future<void> remove(String shopId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(shopId));
    Logger.info('CartStorage', '移除缓存: shopId=$shopId');
  }
}
