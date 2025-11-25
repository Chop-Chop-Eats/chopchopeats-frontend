import '../models/order_model.dart' show formatDiningDate, CartItemModel;
import '../models/pending_cart_operation.dart';

/// 标记购物车数据的来源
enum CartDataOrigin { local, remote }

/// 商品 + 规格引用，便于在 UI 中快速定位购物车条目
class CartProductRef {
  final String productId;
  final String productSpecId;

  const CartProductRef({required this.productId, required this.productSpecId});

  CartProductRef.fromItem(CartItemModel item)
    : productId = item.productId ?? '',
      productSpecId = item.productSpecId ?? '';

  String get key => '$productId|$productSpecId';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartProductRef &&
        other.productId == productId &&
        other.productSpecId == productSpecId;
  }

  @override
  int get hashCode => Object.hash(productId, productSpecId);
}

/// 购物车费用明细
class CartTotals {
  final double subtotal;
  final double serviceFee;
  final double taxAmount;
  final double deliveryFee;
  final double couponOffset;
  final double tipAmount;
  final double payable;

  const CartTotals({
    this.subtotal = 0,
    this.serviceFee = 0,
    this.taxAmount = 0,
    this.deliveryFee = 0,
    this.couponOffset = 0,
    this.tipAmount = 0,
    this.payable = 0,
  });

  CartTotals copyWith({
    double? subtotal,
    double? serviceFee,
    double? taxAmount,
    double? deliveryFee,
    double? couponOffset,
    double? tipAmount,
    double? payable,
  }) {
    return CartTotals(
      subtotal: subtotal ?? this.subtotal,
      serviceFee: serviceFee ?? this.serviceFee,
      taxAmount: taxAmount ?? this.taxAmount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      couponOffset: couponOffset ?? this.couponOffset,
      tipAmount: tipAmount ?? this.tipAmount,
      payable: payable ?? this.payable,
    );
  }

  factory CartTotals.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CartTotals();
    }
    return CartTotals(
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      serviceFee: (json['serviceFee'] as num?)?.toDouble() ?? 0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0,
      couponOffset: (json['couponOffset'] as num?)?.toDouble() ?? 0,
      tipAmount: (json['tipAmount'] as num?)?.toDouble() ?? 0,
      payable: (json['payable'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'subtotal': subtotal,
    'serviceFee': serviceFee,
    'taxAmount': taxAmount,
    'deliveryFee': deliveryFee,
    'couponOffset': couponOffset,
    'tipAmount': tipAmount,
    'payable': payable,
  };

  factory CartTotals.fromItems(List<CartItemModel> items) {
    final subtotal = items.fold<double>(0, (sum, item) {
      final price = item.price ?? 0;
      final quantity = item.quantity ?? 0;
      return sum + price * quantity;
    });
    return CartTotals(subtotal: subtotal, payable: subtotal);
  }
}

/// 单个店铺的购物车状态
const _cartStateSentinel = Object();

class CartState {
  final String shopId;
  final String diningDate; // 格式: YYYY-MM-DD
  final List<CartItemModel> items;
  final CartTotals totals;
  final DateTime? lastSyncedAt;
  final CartDataOrigin dataOrigin;
  final bool isSyncing;
  final bool isUpdating;
  final bool isOperating;
  final String? error;
  final String? lastError;
  final CartProductRef? operatingProductRef;
  final Map<CartProductRef, CartItemModel> itemRefs;
  final List<PendingCartOperation> pendingOperations;
  final DateTime? lastSyncAttemptAt;

  CartState({
    required this.shopId,
    required this.diningDate,
    this.items = const [],
    this.totals = const CartTotals(),
    this.lastSyncedAt,
    this.dataOrigin = CartDataOrigin.local,
    this.isSyncing = false,
    this.isUpdating = false,
    this.isOperating = false,
    this.error,
    this.lastError,
    this.operatingProductRef,
    Map<CartProductRef, CartItemModel>? itemRefs,
    this.pendingOperations = const [],
    this.lastSyncAttemptAt,
  }) : itemRefs = itemRefs ?? _buildItemRefs(items);

  factory CartState.initial(String shopId) {
    return CartState(
      shopId: shopId,
      diningDate: formatDiningDate(DateTime.now()),
    );
  }

  CartState copyWith({
    String? diningDate,
    List<CartItemModel>? items,
    CartTotals? totals,
    DateTime? lastSyncedAt,
    CartDataOrigin? dataOrigin,
    bool? isSyncing,
    bool? isUpdating,
    bool? isOperating,
    Object? error = _cartStateSentinel,
    Object? lastError = _cartStateSentinel,
    Object? operatingProductRef = _cartStateSentinel,
    List<PendingCartOperation>? pendingOperations,
    DateTime? lastSyncAttemptAt,
  }) {
    final nextItems = items ?? this.items;
    final nextError =
        identical(error, _cartStateSentinel) ? this.error : error as String?;
    final nextLastError =
        identical(lastError, _cartStateSentinel)
            ? this.lastError
            : lastError as String?;
    final nextOperatingProductRef =
        identical(operatingProductRef, _cartStateSentinel)
            ? this.operatingProductRef
            : operatingProductRef as CartProductRef?;
    return CartState(
      shopId: shopId,
      diningDate: diningDate ?? this.diningDate,
      items: nextItems,
      totals: totals ?? this.totals,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      dataOrigin: dataOrigin ?? this.dataOrigin,
      isSyncing: isSyncing ?? this.isSyncing,
      isUpdating: isUpdating ?? this.isUpdating,
      isOperating: isOperating ?? this.isOperating,
      error: nextError,
      lastError: nextLastError,
      operatingProductRef: nextOperatingProductRef,
      itemRefs: _buildItemRefs(nextItems),
      pendingOperations: pendingOperations ?? this.pendingOperations,
      lastSyncAttemptAt: lastSyncAttemptAt ?? this.lastSyncAttemptAt,
    );
  }

  bool get isEmpty => items.isEmpty;

  int get totalQuantity =>
      items.fold<int>(0, (sum, item) => sum + (item.quantity ?? 0));

  /// 是否有待同步的变更
  bool get hasPendingChanges => pendingOperations.isNotEmpty;

  CartItemModel? findItem(String productId, String productSpecId) {
    return itemRefs[CartProductRef(
      productId: productId,
      productSpecId: productSpecId,
    )];
  }

  int quantityOf(String productId, String productSpecId) {
    final item = findItem(productId, productSpecId);
    return item?.quantity ?? 0;
  }

  Map<String, dynamic> toStorageJson({DateTime? savedAt}) {
    return {
      'shopId': shopId,
      'diningDate': diningDate,
      'items': items.map((item) => item.toJson()).toList(),
      'totals': totals.toJson(),
      'lastSyncedAt': (savedAt ?? lastSyncedAt)?.toIso8601String(),
      'pendingOperations': pendingOperations.map((op) => op.toJson()).toList(),
      'lastSyncAttemptAt': lastSyncAttemptAt?.toIso8601String(),
    };
  }

  factory CartState.fromStorageJson(String shopId, Map<String, dynamic> json) {
    final rawItems =
        (json['items'] as List<dynamic>? ?? [])
            .map(
              (e) =>
                  CartItemModel.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
    final dateStr = json['diningDate'] as String? ?? '';
    final defaultDate = formatDiningDate(DateTime.now());
    
    // 恢复待同步操作队列
    final rawPendingOps = json['pendingOperations'] as List<dynamic>? ?? [];
    final pendingOps = rawPendingOps
        .map((e) => PendingCartOperation.fromJson(
            Map<String, dynamic>.from(e as Map)))
        .toList();
    
    return CartState(
      shopId: shopId,
      diningDate: dateStr.isNotEmpty ? dateStr : defaultDate,
      items: rawItems,
      totals: CartTotals.fromJson(json['totals'] as Map<String, dynamic>?),
      lastSyncedAt: DateTime.tryParse(json['lastSyncedAt'] as String? ?? ''),
      dataOrigin: CartDataOrigin.local,
      pendingOperations: pendingOps,
      lastSyncAttemptAt: DateTime.tryParse(
          json['lastSyncAttemptAt'] as String? ?? ''),
    );
  }

  static Map<CartProductRef, CartItemModel> _buildItemRefs(
    List<CartItemModel> items,
  ) {
    final map = <CartProductRef, CartItemModel>{};
    for (final item in items) {
      final productId = item.productId;
      final specId = item.productSpecId;
      if (productId == null || specId == null) {
        continue;
      }
      map[CartProductRef(productId: productId, productSpecId: specId)] = item;
    }
    return map;
  }
}
