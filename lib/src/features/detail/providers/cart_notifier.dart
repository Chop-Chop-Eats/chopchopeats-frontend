import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/logger/logger.dart';
import '../models/order_model.dart';
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

  Future<void> loadFromLocal(String shopId) async {
    final cached = await _storage.read(shopId);
    if (cached == null) {
      _commit(shopId, _ensureCart(shopId));
      return;
    }
    final cart = CartState(
      shopId: shopId,
      diningDate: cached.diningDate ?? formatDiningDate(DateTime.now()),
      items: cached.items,
      totals: cached.totals,
      lastSyncedAt: cached.savedAt,
      dataOrigin: CartDataOrigin.local,
    );
    _commit(shopId, cart);
  }

  Future<void> syncFromRemote({
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
      await _storage.write(next);
      Logger.info(
        'CartNotifier',
        '远端同步成功: shopId=$shopId, items=${items.length}',
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

  Future<void> addItem(AddCartParams params) async {
    final current = _ensureCart(params.shopId);
    final productRef = CartProductRef(
      productId: params.productId,
      productSpecId: params.productSpecId,
    );
    _commit(
      params.shopId,
      current.copyWith(
        diningDate: params.diningDate,
        isUpdating: true,
        isOperating: true,
        error: null,
        operatingProductRef: productRef,
      ),
    );
    try {
      await _orderServices.addCart(params);
      await syncFromRemote(
        shopId: params.shopId,
        diningDate: params.diningDate,
      );
    } catch (e) {
      Logger.error('CartNotifier', '添加购物车失败: $e');
      _commit(
        params.shopId,
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
    final productRef = CartProductRef(
      productId: targetItem.productId ?? '',
      productSpecId: targetItem.productSpecId ?? '',
    );
    final optimisticItems =
        current.items
            .map(
              (item) =>
                  item.id == params.cartId
                      ? item.copyWith(quantity: params.quantity)
                      : item,
            )
            .toList();
    final optimisticTotals = CartTotals.fromItems(optimisticItems);
    _commit(
      shopId,
      current.copyWith(
        items: optimisticItems,
        totals: optimisticTotals,
        diningDate: diningDate,
        isUpdating: true,
        isOperating: true,
        error: null,
        operatingProductRef: productRef,
      ),
    );
    try {
      await _orderServices.updateCartQuantity(params);
      await syncFromRemote(shopId: shopId, diningDate: diningDate);
    } catch (e) {
      Logger.error('CartNotifier', '更新购物车数量失败: $e');
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
      );
      await addItem(params);
      return;
    }

    if (existing.id == null) {
      Logger.warn('CartNotifier', '购物车条目缺少ID，尝试重新同步后再更新');
      await syncFromRemote(shopId: shopId, diningDate: resolvedDate);
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
