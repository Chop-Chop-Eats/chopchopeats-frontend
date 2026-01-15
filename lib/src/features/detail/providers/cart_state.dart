import '../models/order_model.dart' show formatDiningDate, CartItemModel;

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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartTotals &&
        other.subtotal == subtotal &&
        other.serviceFee == serviceFee &&
        other.taxAmount == taxAmount &&
        other.deliveryFee == deliveryFee &&
        other.couponOffset == couponOffset &&
        other.tipAmount == tipAmount &&
        other.payable == payable;
  }

  @override
  int get hashCode => Object.hash(
        subtotal,
        serviceFee,
        taxAmount,
        deliveryFee,
        couponOffset,
        tipAmount,
        payable,
      );
}

/// 单个店铺的购物车状态
const _cartStateSentinel = Object();

class CartState {
  final String shopId;
  final String diningDate; // 格式: YYYY-MM-DD
  final List<CartItemModel> items;
  final CartTotals totals;
  final double? distance; // 配送距离（英里）
  final DateTime? lastSyncedAt;
  final CartDataOrigin dataOrigin;
  final bool isSyncing;
  final bool isUpdating;
  final bool isOperating;
  final String? error;
  final String? lastError;
  final String? operatingProductId; // 存储 productId
  final String? operatingProductSpecId; // 存储 productSpecId

  // itemRefs 和 operatingProductRef 作为计算属性，不存储在 Hive 中
  Map<CartProductRef, CartItemModel> get itemRefs => _buildItemRefs(items);

  CartProductRef? get operatingProductRef {
    if (operatingProductId != null && operatingProductSpecId != null) {
      return CartProductRef(
        productId: operatingProductId!,
        productSpecId: operatingProductSpecId!,
      );
    }
    return null;
  }

  CartState({
    required this.shopId,
    required this.diningDate,
    this.items = const [],
    this.totals = const CartTotals(),
    this.distance,
    this.lastSyncedAt,
    this.dataOrigin = CartDataOrigin.local,
    this.isSyncing = false,
    this.isUpdating = false,
    this.isOperating = false,
    this.error,
    this.lastError,
    CartProductRef? operatingProductRef,
  }) : operatingProductId = operatingProductRef?.productId,
       operatingProductSpecId = operatingProductRef?.productSpecId;

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
    Object? distance = _cartStateSentinel,
    DateTime? lastSyncedAt,
    CartDataOrigin? dataOrigin,
    bool? isSyncing,
    bool? isUpdating,
    bool? isOperating,
    Object? error = _cartStateSentinel,
    Object? lastError = _cartStateSentinel,
    Object? operatingProductRef = _cartStateSentinel,
  }) {
    final nextItems = items ?? this.items;
    final nextDistance =
        identical(distance, _cartStateSentinel) ? this.distance : distance as double?;
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
      distance: nextDistance,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      dataOrigin: dataOrigin ?? this.dataOrigin,
      isSyncing: isSyncing ?? this.isSyncing,
      isUpdating: isUpdating ?? this.isUpdating,
      isOperating: isOperating ?? this.isOperating,
      error: nextError,
      lastError: nextLastError,
      operatingProductRef: nextOperatingProductRef,
    );
  }

  bool get isEmpty => items.isEmpty;

  int get totalQuantity =>
      items.fold<int>(0, (sum, item) => sum + (item.quantity ?? 0));

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

  static Map<CartProductRef, CartItemModel> _buildItemRefs(
    List<CartItemModel> items,
  ) {
    final map = <CartProductRef, CartItemModel>{};
    for (final item in items) {
      final productId = item.productId;
      final specId = item.productSpecId ?? '';
      if (productId == null) {
        continue;
      }
      map[CartProductRef(productId: productId, productSpecId: specId)] = item;
    }
    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartState &&
        other.shopId == shopId &&
        other.diningDate == diningDate &&
        other.items.length == items.length &&
        _listEquals(other.items, items) &&
        other.totals == totals &&
        other.distance == distance &&
        other.lastSyncedAt == lastSyncedAt &&
        other.dataOrigin == dataOrigin &&
        other.isSyncing == isSyncing &&
        other.isUpdating == isUpdating &&
        other.isOperating == isOperating &&
        other.error == error &&
        other.lastError == lastError &&
        other.operatingProductId == operatingProductId &&
        other.operatingProductSpecId == operatingProductSpecId;
  }

  @override
  int get hashCode => Object.hash(
        shopId,
        diningDate,
        Object.hashAll(items),
        totals,
        distance,
        lastSyncedAt,
        dataOrigin,
        isSyncing,
        isUpdating,
        isOperating,
        error,
        lastError,
        operatingProductId,
        operatingProductSpecId,
      );

  bool _listEquals(List<CartItemModel> a, List<CartItemModel> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
