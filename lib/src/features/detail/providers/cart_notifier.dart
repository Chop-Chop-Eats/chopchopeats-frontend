import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/logger/logger.dart';
import '../models/order_model.dart';
import '../services/order_services.dart';
import 'cart_state.dart';

class CartNotifier extends StateNotifier<Map<String, CartState>> {
  CartNotifier({OrderServices? orderServices})
    : _orderServices = orderServices ?? OrderServices(),
      super({});

  final OrderServices _orderServices;

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

  /// 从远程刷新购物车数据
  Future<void> refreshCart({
    required String shopId,
    required String diningDate,
  }) async {
    final current = _ensureCart(shopId);

    _commit(
      shopId,
      current.copyWith(diningDate: diningDate, isSyncing: true, error: null),
    );
    try {
      final query = GetCartListQuery(diningDate: diningDate, shopId: shopId);
      final items = await _orderServices.getCartList(query);

      final totals = CartTotals.fromItems(items);
      final next = current.copyWith(
        diningDate: diningDate,
        items: items,
        totals: totals,
        lastSyncedAt: DateTime.now(),
        dataOrigin: CartDataOrigin.remote,
        isSyncing: false,
        isUpdating: false,
        isOperating: false,
        error: null,
        lastError: null,
        operatingProductRef: null,
      );
      _commit(shopId, next);
      Logger.info(
        'CartNotifier',
        '刷新购物车成功: shopId=$shopId, items=${items.length}',
      );
    } catch (e) {
      Logger.error('CartNotifier', '刷新购物车失败: $e');
      _commit(
        shopId,
        current.copyWith(
          isSyncing: false,
          error: e.toString(),
          lastError: e.toString(),
          operatingProductRef: null,
        ),
      );
      rethrow;
    }
  }

  /// 添加商品到购物车
  Future<void> addItem(AddCartParams params) async {
    final current = _ensureCart(params.shopId);
    final productRef = CartProductRef(
      productId: params.productId,
      productSpecId: params.productSpecId,
    );

    // 设置加载状态
    _commit(
      params.shopId,
      current.copyWith(
        operatingProductRef: productRef,
        isOperating: true,
        error: null,
      ),
    );

    try {
      // 调用接口
      await _orderServices.addCart(params);

      // 刷新数据：重新拉取整个购物车
      await refreshCart(shopId: params.shopId, diningDate: params.diningDate);

      Logger.info(
        'CartNotifier',
        '添加商品成功: shopId=${params.shopId}, productId=${params.productId}',
      );
    } catch (e) {
      Logger.error('CartNotifier', '添加商品失败: $e');
      _commit(
        params.shopId,
        current.copyWith(
          isOperating: false,
          error: e.toString(),
          lastError: e.toString(),
          operatingProductRef: null,
        ),
      );
      rethrow;
    } finally {
      // 清除加载状态
      final finalState = _ensureCart(params.shopId);
      _commit(
        params.shopId,
        finalState.copyWith(isOperating: false, operatingProductRef: null),
      );
    }
  }

  /// 更新购物车商品数量
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

    final productRef = CartProductRef(
      productId: targetItem.productId!,
      productSpecId: targetItem.productSpecId!,
    );

    // 设置加载状态
    _commit(
      shopId,
      current.copyWith(
        operatingProductRef: productRef,
        isOperating: true,
        error: null,
      ),
    );

    try {
      // 调用接口
      await _orderServices.updateCartQuantity(params);

      // 刷新数据：重新拉取整个购物车
      await refreshCart(shopId: shopId, diningDate: diningDate);

      Logger.info(
        'CartNotifier',
        '更新数量成功: shopId=$shopId, cartId=${params.cartId}, '
            'quantity=${params.quantity}',
      );
    } catch (e) {
      Logger.error('CartNotifier', '更新数量失败: $e');
      _commit(
        shopId,
        current.copyWith(
          isOperating: false,
          error: e.toString(),
          lastError: e.toString(),
          operatingProductRef: null,
        ),
      );
      rethrow;
    } finally {
      // 清除加载状态
      final finalState = _ensureCart(shopId);
      _commit(
        shopId,
        finalState.copyWith(isOperating: false, operatingProductRef: null),
      );
    }
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
    double? price, // 商品价格（用于首次添加时传递到服务端）
  }) async {
    final resolvedDate = _resolveDiningDate(shopId, diningDate);
    final existing = _findItem(shopId, productId, productSpecId);

    if (existing == null) {
      // 新商品，使用 addCart
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

    // 如果商品存在但没有 id，说明数据异常，先刷新购物车
    if (existing.id == null) {
      Logger.warn('CartNotifier', '购物车条目缺少ID，先刷新购物车');
      await refreshCart(shopId: shopId, diningDate: resolvedDate);
      // 刷新后重新查找
      final refreshed = _findItem(shopId, productId, productSpecId);
      if (refreshed == null || refreshed.id == null) {
        throw Exception('刷新后仍无法找到有效的购物车项');
      }
      final nextQuantity = (refreshed.quantity ?? 0) + 1;
      await updateQuantity(
        params: UpdateCartParams(cartId: refreshed.id!, quantity: nextQuantity),
        shopId: shopId,
        diningDate: resolvedDate,
      );
      return;
    }

    // 商品已存在，使用 updateCartQuantity
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
