import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/logger/logger.dart';
import '../models/order_model.dart';
import '../models/pending_cart_operation.dart';
import '../services/cart_storage.dart';
import '../services/order_services.dart';
import 'cart_state.dart';

class CartNotifier extends StateNotifier<Map<String, CartState>> {
  CartNotifier({OrderServices? orderServices, CartStorage? storage})
    : _orderServices = orderServices ?? OrderServices(),
      _storage = storage ?? CartStorage(),
      super({});

  final OrderServices _orderServices;
  final CartStorage _storage;

  CartState _ensureCart(String shopId) {
    return state[shopId] ?? CartState.initial(shopId);
  }

  void _commit(String shopId, CartState cart) {
    state = {...state, shopId: cart};
  }

  String _resolveDiningDate(String shopId, String? diningDate) {
    if (diningDate != null && diningDate.isNotEmpty) return diningDate;
    return _ensureCart(shopId).diningDate;
  }

  CartItemModel? _findItem(
    String shopId,
    String productId,
    String productSpecId,
  ) {
    final current = _ensureCart(shopId);
    return current.findItem(productId, productSpecId);
  }

  /// 生成操作ID
  String _generateOperationId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}';
  }

  /// 添加待同步操作到队列
  void _addPendingOperation(String shopId, PendingCartOperation operation) {
    final current = _ensureCart(shopId);
    final mergedOps = _mergeOperations([...current.pendingOperations, operation]);
    final updated = current.copyWith(
      pendingOperations: mergedOps,
      lastSyncAttemptAt: null, // 重置同步尝试时间
    );
    _commit(shopId, updated);
    // 立即写入缓存
    unawaited(_storage.write(updated));
    Logger.info(
      'CartNotifier',
      '添加待同步操作: shopId=$shopId, type=${operation.type}, '
      'pendingOps=${mergedOps.length}',
    );
  }

  /// 合并相同商品的操作
  List<PendingCartOperation> _mergeOperations(
    List<PendingCartOperation> operations,
  ) {
    if (operations.isEmpty) return [];

    // 按商品分组
    final Map<String, List<PendingCartOperation>> grouped = {};
    for (final op in operations) {
      final key = op.operationKey;
      grouped.putIfAbsent(key, () => []).add(op);
    }

    final merged = <PendingCartOperation>[];
    for (final group in grouped.values) {
      if (group.isEmpty) continue;

      // 检查是否有删除操作
      final hasRemove = group.any((op) => op.type == CartOperationType.remove);
      if (hasRemove) {
        // 如果有删除操作，只保留最后一个删除操作，清除该商品的其他操作
        final removeOps = group
            .where((op) => op.type == CartOperationType.remove)
            .toList();
        removeOps.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        merged.add(removeOps.last);
        continue;
      }

      // 对于相同商品的连续操作，只保留最后一次操作
      group.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      final lastOp = group.last;

      // 如果是更新操作，合并数量
      if (lastOp.type == CartOperationType.update &&
          group.length > 1 &&
          group.any((op) => op.type == CartOperationType.add)) {
        // 添加后立即更新，合并为一次添加操作（带最终数量）
        final addOp = group.firstWhere(
          (op) => op.type == CartOperationType.add,
        );
        final updateOp = lastOp;
        final finalQuantity = updateOp.params['quantity'] as int? ?? 1;
        merged.add(
          PendingCartOperation.add(
            operationId: addOp.operationId,
            params: {
              ...addOp.params,
              'quantity': finalQuantity,
            },
            createdAt: addOp.createdAt,
          ),
        );
      } else {
        merged.add(lastOp);
      }
    }

    // 按创建时间排序
    merged.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return merged;
  }

  Future<void> loadFromLocal(String shopId) async {
    // 使用 readFullState 以恢复待同步操作队列
    final cached = await _storage.readFullState(shopId);
    if (cached == null) {
      _commit(shopId, _ensureCart(shopId));
      return;
    }
    _commit(shopId, cached);
    Logger.info(
      'CartNotifier',
      '从本地加载购物车: shopId=$shopId, items=${cached.items.length}, '
      'pendingOps=${cached.pendingOperations.length}',
    );
  }

  /// 从远程同步购物车数据
  Future<void> syncFromRemote({
    required String shopId,
    required String diningDate,
    bool skipIfPending = false,
  }) async {
    final current = _ensureCart(shopId);
    
    // 如果有待同步操作且设置了跳过标志，则跳过远程同步
    if (skipIfPending && current.pendingOperations.isNotEmpty) {
      Logger.info(
        'CartNotifier',
        '跳过远程同步（有待同步操作）: shopId=$shopId, pendingOps=${current.pendingOperations.length}',
      );
      return;
    }
    
    _commit(
      shopId,
      current.copyWith(diningDate: diningDate, isSyncing: true, error: null),
    );
    try {
      final query = GetCartListQuery(diningDate: diningDate, shopId: shopId);
      final items = await _orderServices.getCartList(query);
      
      // 如果存在待同步操作，智能合并远程数据和本地待同步操作
      List<CartItemModel> mergedItems = items;
      if (current.pendingOperations.isNotEmpty) {
        mergedItems = _mergeRemoteWithPending(
          items,
          current.pendingOperations,
          current.items,
        );
        Logger.info(
          'CartNotifier',
          '智能合并远程数据: shopId=$shopId, remoteItems=${items.length}, '
          'localItems=${current.items.length}, mergedItems=${mergedItems.length}',
        );
      }
      
      final totals = CartTotals.fromItems(mergedItems);
      final next = current.copyWith(
        diningDate: diningDate,
        items: mergedItems,
        totals: totals,
        lastSyncedAt: DateTime.now(),
        dataOrigin: CartDataOrigin.remote,
        isSyncing: false,
        isUpdating: false,
        isOperating: false,
        error: null,
        lastError: null,
        operatingProductRef: null,
        // 保留待同步操作队列
        pendingOperations: current.pendingOperations,
      );
      _commit(shopId, next);
      await _storage.write(next);
      Logger.info(
        'CartNotifier',
        '远端同步成功: shopId=$shopId, items=${mergedItems.length}',
      );
    } catch (e) {
      Logger.error('CartNotifier', '远端同步失败: $e');
      _commit(
        shopId,
        current.copyWith(
          isSyncing: false,
          error: e.toString(),
          lastError: e.toString(),
          operatingProductRef: null,
        ),
      );
    }
  }

  /// 合并远程数据和本地待同步操作
  /// 策略：保留本地待同步操作的商品，只更新远程已同步的商品
  List<CartItemModel> _mergeRemoteWithPending(
    List<CartItemModel> remoteItems,
    List<PendingCartOperation> pendingOps,
    List<CartItemModel> localItems,
  ) {
    // 创建待同步操作的商品键集合
    final pendingKeys = <String>{};
    for (final op in pendingOps) {
      if (op.productId != null && op.productSpecId != null) {
        pendingKeys.add(op.operationKey);
      }
    }

    // 创建本地商品的映射（按 productId|productSpecId）
    final localMap = <String, CartItemModel>{};
    for (final item in localItems) {
      if (item.productId != null && item.productSpecId != null) {
        final key = '${item.productId}|${item.productSpecId}';
        localMap[key] = item;
      }
    }

    // 创建远程商品的映射（按 productId|productSpecId）
    final remoteMap = <String, CartItemModel>{};
    for (final item in remoteItems) {
      if (item.productId != null && item.productSpecId != null) {
        final key = '${item.productId}|${item.productSpecId}';
        remoteMap[key] = item;
      }
    }

    // 合并结果
    final merged = <CartItemModel>[];
    
    // 1. 添加远程已同步的商品（排除有待同步操作的商品）
    for (final item in remoteItems) {
      if (item.productId != null && item.productSpecId != null) {
        final key = '${item.productId}|${item.productSpecId}';
        // 如果该商品有待同步操作，跳过（保留本地乐观更新的数据）
        if (!pendingKeys.contains(key)) {
          merged.add(item);
        }
      }
    }

    // 2. 添加待同步操作对应的商品（使用本地乐观更新的数据）
    for (final key in pendingKeys) {
      if (localMap.containsKey(key)) {
        merged.add(localMap[key]!);
      }
    }
    
    return merged;
  }

  /// 批量同步待处理的操作
  Future<void> syncPendingOperations(String shopId) async {
    final current = _ensureCart(shopId);
    if (current.pendingOperations.isEmpty) {
      Logger.info('CartNotifier', '无待同步操作: shopId=$shopId');
      return;
    }

    Logger.info(
      'CartNotifier',
      '开始批量同步: shopId=$shopId, pendingOps=${current.pendingOperations.length}',
    );

    // 标记同步开始
    _commit(
      shopId,
      current.copyWith(
        lastSyncAttemptAt: DateTime.now(),
        isSyncing: true,
      ),
    );

    // 合并操作队列
    final mergedOps = _mergeOperations(current.pendingOperations);
    if (mergedOps.isEmpty) {
      // 如果合并后为空，清空队列
      _commit(
        shopId,
        current.copyWith(
          pendingOperations: [],
          isSyncing: false,
          lastSyncAttemptAt: DateTime.now(),
        ),
      );
      await _storage.write(current.copyWith(pendingOperations: []));
      return;
    }

    final failedOps = <PendingCartOperation>[];
    final resolvedDate = current.diningDate;

    // 按顺序执行操作
    for (final operation in mergedOps) {
      try {
        await _processOperation(shopId, operation, resolvedDate);
        Logger.info(
          'CartNotifier',
          '操作同步成功: shopId=$shopId, operationId=${operation.operationId}',
        );
      } catch (e) {
        Logger.error(
          'CartNotifier',
          '操作同步失败: shopId=$shopId, operationId=${operation.operationId}, error=$e',
        );
        // 如果重试次数超过3次，放弃该操作
        if (operation.retryCount >= 3) {
          Logger.warn(
            'CartNotifier',
            '操作重试次数超限，放弃: operationId=${operation.operationId}',
          );
          continue;
        }
        failedOps.add(operation.incrementRetry());
      }
    }

    // 同步完成后，从远程获取最新数据
    try {
      await syncFromRemote(shopId: shopId, diningDate: resolvedDate);
    } catch (e) {
      Logger.error('CartNotifier', '同步后刷新失败: $e');
      // 即使刷新失败，也继续处理
    }

    // 更新状态：移除成功的操作，保留失败的操作
    final finalState = _ensureCart(shopId);
    _commit(
      shopId,
      finalState.copyWith(
        pendingOperations: failedOps,
        isSyncing: false,
        lastSyncAttemptAt: DateTime.now(),
      ),
    );
    await _storage.write(finalState.copyWith(pendingOperations: failedOps));

    if (failedOps.isEmpty) {
      Logger.info(
        'CartNotifier',
        '批量同步完成: shopId=$shopId, 所有操作成功',
      );
    } else {
      Logger.warn(
        'CartNotifier',
        '批量同步完成: shopId=$shopId, 失败操作数=${failedOps.length}',
      );
    }
  }

  /// 处理单个操作
  Future<void> _processOperation(
    String shopId,
    PendingCartOperation operation,
    String diningDate,
  ) async {
    switch (operation.type) {
      case CartOperationType.add:
        final params = AddCartParams(
          diningDate: operation.params['diningDate'] as String,
          productId: operation.params['productId'] as String,
          productName: operation.params['productName'] as String,
          productSpecId: operation.params['productSpecId'] as String,
          productSpecName: operation.params['productSpecName'] as String,
          quantity: operation.params['quantity'] as int,
          shopId: operation.params['shopId'] as String,
        );
        await _orderServices.addCart(params);
        break;
      case CartOperationType.update:
        final params = UpdateCartParams(
          cartId: operation.params['cartId'] as String,
          quantity: operation.params['quantity'] as int,
        );
        await _orderServices.updateCartQuantity(params);
        break;
      case CartOperationType.remove:
        // 删除操作暂未实现，如果需要可以添加
        throw UnimplementedError('删除操作暂未实现');
    }
  }

  /// 添加商品到购物车（本地优先模式）
  Future<void> addItem(AddCartParams params) async {
    final current = _ensureCart(params.shopId);

    // 检查是否已存在该商品
    final existing = current.findItem(params.productId, params.productSpecId);
    final newQuantity = existing != null
        ? (existing.quantity ?? 0) + params.quantity
        : params.quantity;

    // 乐观更新：立即更新本地状态
    final updatedItems = existing == null
        ? [
            ...current.items,
            CartItemModel(
              productId: params.productId,
              productName: params.productName,
              productSpecId: params.productSpecId,
              productSpecName: params.productSpecName,
              quantity: params.quantity,
              shopId: params.shopId,
              diningDate: params.diningDate,
              price: params.price, // 设置价格，用于本地计算总额
              // 注意：本地添加的商品暂时没有 id，等待同步后获得
            ),
          ]
        : current.items
            .map(
              (item) =>
                  item.productId == params.productId &&
                  item.productSpecId == params.productSpecId
                      ? item.copyWith(
                          quantity: newQuantity,
                          // 确保价格被保留，如果商品已有价格则保留，否则使用传入的价格
                          price: item.price ?? params.price,
                        )
                      : item,
            )
            .toList();

    final updatedTotals = CartTotals.fromItems(updatedItems);
    final updatedState = current.copyWith(
      diningDate: params.diningDate,
      items: updatedItems,
      totals: updatedTotals,
      isUpdating: false,
      isOperating: false,
      error: null,
      operatingProductRef: null,
    );

    _commit(params.shopId, updatedState);
    // 立即写入缓存
    await _storage.write(updatedState);

    // 添加待同步操作
    // 如果商品已存在且有 cartId，应该使用 update 操作
    if (existing != null && existing.id != null) {
      final operation = PendingCartOperation.update(
        operationId: _generateOperationId(),
        params: {
          'cartId': existing.id!,
          'quantity': newQuantity,
          'productId': params.productId,
          'productSpecId': params.productSpecId,
        },
      );
      _addPendingOperation(params.shopId, operation);
      Logger.info(
        'CartNotifier',
        '本地更新商品数量: shopId=${params.shopId}, productId=${params.productId}, '
        'quantity=$newQuantity',
      );
    } else {
      // 新商品或没有 cartId，使用 add 操作
      final operation = PendingCartOperation.add(
        operationId: _generateOperationId(),
        params: {
          ...params.toJson(),
          'quantity': newQuantity, // 使用合并后的数量
        },
      );
      _addPendingOperation(params.shopId, operation);
      Logger.info(
        'CartNotifier',
        '本地添加商品成功: shopId=${params.shopId}, productId=${params.productId}, '
        'quantity=$newQuantity',
      );
    }
  }

  /// 更新购物车商品数量（本地优先模式）
  Future<void> updateQuantity({
    required UpdateCartParams params,
    required String shopId,
    required String diningDate,
  }) async {
    final current = _ensureCart(shopId);
    // 找到对应的商品项以获取 productId 和 productSpecId
    final targetItem = current.items.firstWhere(
      (item) => item.id == params.cartId,
      orElse: () => throw Exception('找不到对应的购物车项: ${params.cartId}'),
    );

    if (targetItem.productId == null || targetItem.productSpecId == null) {
      throw Exception('购物车项缺少商品信息: ${params.cartId}');
    }

    // 乐观更新：立即更新本地状态
    final updatedItems = current.items
        .map(
          (item) =>
              item.id == params.cartId
                  ? item.copyWith(quantity: params.quantity)
                  : item,
        )
        .toList();
    final updatedTotals = CartTotals.fromItems(updatedItems);
    final updatedState = current.copyWith(
      items: updatedItems,
      totals: updatedTotals,
      diningDate: diningDate,
      isUpdating: false,
      isOperating: false,
      error: null,
      operatingProductRef: null,
    );

    _commit(shopId, updatedState);
    // 立即写入缓存
    await _storage.write(updatedState);

    // 添加待同步操作
    final operation = PendingCartOperation.update(
      operationId: _generateOperationId(),
      params: {
        ...params.toJson(),
        'productId': targetItem.productId,
        'productSpecId': targetItem.productSpecId,
      },
    );
    _addPendingOperation(shopId, operation);

    Logger.info(
      'CartNotifier',
      '本地更新数量成功: shopId=$shopId, cartId=${params.cartId}, '
      'quantity=${params.quantity}',
    );
  }

  Future<void> clearCart({
    required String shopId,
    required String diningDate,
  }) async {
    final current = _ensureCart(shopId);
      _commit(
        shopId,
        current.copyWith(
          items: const [],
          totals: const CartTotals(),
          diningDate: diningDate,
          isUpdating: true,
          isOperating: true,
          error: null,
          operatingProductRef: null,
        ),
      );
    try {
      await _orderServices.clearCart(shopId, diningDate);
      await _storage.remove(shopId);
      final cleared = CartState(
        shopId: shopId,
        diningDate: diningDate,
        items: const [],
        totals: const CartTotals(),
        lastSyncedAt: DateTime.now(),
        dataOrigin: CartDataOrigin.remote,
      );
      _commit(shopId, cleared);
    } catch (e) {
      Logger.error('CartNotifier', '清空购物车失败: $e');
      _commit(
        shopId,
        current.copyWith(
          isUpdating: false,
          isOperating: false,
          error: e.toString(),
          lastError: e.toString(),
          operatingProductRef: null,
        ),
      );
      rethrow;
    }
  }

  int getQuantity(
    String shopId, {
    required String productId,
    required String productSpecId,
  }) {
    return _ensureCart(shopId).quantityOf(productId, productSpecId);
  }

  Future<void> increment({
    required String shopId,
    required String? diningDate, // 格式: YYYY-MM-DD
    required String productId,
    required String productName,
    required String productSpecId,
    required String productSpecName,
    double? price, // 商品价格（可选，用于本地计算总额）
  }) async {
    final resolvedDate = _resolveDiningDate(shopId, diningDate);
    final existing = _findItem(shopId, productId, productSpecId);

    if (existing == null) {
      final params = AddCartParams(
        diningDate: resolvedDate,
        productId: productId,
        productName: productName,
        productSpecId: productSpecId,
        productSpecName: productSpecName,
        quantity: 1,
        shopId: shopId,
        price: price,
      );
      await addItem(params);
      return;
    }

    // 如果商品存在但没有 id，说明是本地添加的，使用 addItem 来增加数量
    if (existing.id == null) {
      Logger.info(
        'CartNotifier',
        '购物车条目缺少ID（本地添加），使用 addItem 增加数量',
      );
      final params = AddCartParams(
        diningDate: resolvedDate,
        productId: productId,
        productName: productName,
        productSpecId: productSpecId,
        productSpecName: productSpecName,
        quantity: 1,
        shopId: shopId,
        price: price ?? existing.price, // 使用传入的价格或已有商品的价格
      );
      await addItem(params);
      return;
    }

    final nextQuantity = (existing.quantity ?? 0) + 1;
    await updateQuantity(
      params: UpdateCartParams(cartId: existing.id!, quantity: nextQuantity),
      shopId: shopId,
      diningDate: resolvedDate,
    );
  }

  Future<void> decrement({
    required String shopId,
    required String? diningDate, // 格式: YYYY-MM-DD
    required String productId,
    required String productSpecId,
  }) async {
    final resolvedDate = _resolveDiningDate(shopId, diningDate);
    final existing = _findItem(shopId, productId, productSpecId);
    if (existing == null || existing.id == null) {
      Logger.warn('CartNotifier', '尝试减少不存在的商品: $productId');
      return;
    }
    final currentQuantity = existing.quantity ?? 0;
    if (currentQuantity <= 0) {
      return;
    }
    final nextQuantity = currentQuantity - 1;
    await updateQuantity(
      params: UpdateCartParams(
        cartId: existing.id!,
        quantity: nextQuantity < 0 ? 0 : nextQuantity,
      ),
      shopId: shopId,
      diningDate: resolvedDate,
    );
  }
}

final cartProvider =
    StateNotifierProvider<CartNotifier, Map<String, CartState>>((ref) {
      return CartNotifier();
    });

final cartStateProvider = Provider.family<CartState, String>((ref, shopId) {
  final carts = ref.watch(cartProvider);
  return carts[shopId] ?? CartState.initial(shopId);
});
