import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/logger/logger.dart';
import '../models/detail_model.dart';
import '../services/detail_services.dart';

/// 店铺详情数据状态
class DetailState {
  final ShopModel? shop;
  final bool isLoading;
  final String? error;

  DetailState({this.shop, this.isLoading = false, this.error});

  DetailState copyWith({ShopModel? shop, bool? isLoading, String? error}) {
    return DetailState(
      shop: shop ?? this.shop,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// 优惠券数据状态
class CouponState {
  final AvailableCouponModel? couponData;
  final bool isLoading;
  final bool isClaiming;
  final String? error;

  CouponState({
    this.couponData,
    this.isLoading = false,
    this.isClaiming = false,
    this.error,
  });

  CouponState copyWith({
    AvailableCouponModel? couponData,
    bool? isLoading,
    bool? isClaiming,
    String? error,
  }) {
    return CouponState(
      couponData: couponData ?? this.couponData,
      isLoading: isLoading ?? this.isLoading,
      isClaiming: isClaiming ?? this.isClaiming,
      error: error ?? this.error,
    );
  }
  @override
  String toString() {
    return 'CouponState(couponData: $couponData, isLoading: $isLoading, isClaiming: $isClaiming, error: $error)';
  }
}

/// 商品列表数据状态
class ProductListState {
  final List<SaleProductModel> products;
  final bool isLoading;
  final String? error;

  ProductListState({
    this.products = const [],
    this.isLoading = false,
    this.error,
  });

  ProductListState copyWith({
    List<SaleProductModel>? products,
    bool? isLoading,
    String? error,
  }) {
    return ProductListState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// 店铺详情数据状态管理
class DetailNotifier extends StateNotifier<DetailState> {
  final DetailServices _detailServices = DetailServices();

  DetailNotifier() : super(DetailState());

  /// 加载店铺详情
  Future<void> loadShopDetail(String shopId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final shop = await _detailServices.getShop(shopId);

      state = state.copyWith(shop: shop, isLoading: false);

      Logger.info('DetailNotifier', '店铺详情加载成功: ${shop.chineseShopName}');
    } catch (e) {
      Logger.error('DetailNotifier', '店铺详情加载失败: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 刷新店铺详情
  Future<void> refresh(String shopId) async {
    await loadShopDetail(shopId);
  }

  /// 更新店铺的收藏状态
  /// [shopId] 店铺ID
  /// [isFavorite] 是否收藏
  void updateShopFavorite(String shopId, bool isFavorite) {
    if (state.shop?.id == shopId) {
      state = state.copyWith(shop: state.shop?.copyWith(favorite: isFavorite));
      Logger.info(
        'DetailNotifier',
        '更新店铺收藏状态: shopId=$shopId, favorite=$isFavorite',
      );
    }
  }

  /// 清除错误状态
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 优惠券数据状态管理
class CouponNotifier extends StateNotifier<CouponState> {
  final DetailServices _detailServices = DetailServices();

  CouponNotifier() : super(CouponState());

  /// 加载优惠券列表
  Future<void> loadCouponList(String shopId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final couponData = await _detailServices.getAvailableCouponList(shopId);
      state = state.copyWith(couponData: couponData, isLoading: false);
      Logger.info('CouponNotifier', '优惠券列表加载成功: shopId=$shopId');
    } catch (e) {
      Logger.error('CouponNotifier', '优惠券列表加载失败: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> claimCoupon({
    required String couponId,
    required String shopId,
    required int? userLimit,
    required int? userClaimed,
  }) async {
    if (userLimit != null && userClaimed != null && userClaimed >= userLimit) {
      Logger.warn('CouponNotifier', '用户已达到领取上限 couponId=$couponId');
      return false;
    }

    state = state.copyWith(isClaiming: true, error: null);

    try {
      await _detailServices.claimCoupon(couponId);
      await loadCouponList(shopId);
      return true;
    } catch (e) {
      Logger.error('CouponNotifier', '领取优惠券失败: $e');
      state = state.copyWith(error: e.toString());
      rethrow;
    } finally {
      state = state.copyWith(isClaiming: false);
    }
  }

  /// 刷新优惠券列表
  Future<void> refresh(String shopId) async {
    await loadCouponList(shopId);
  }

  /// 清除错误状态
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 商品列表数据状态管理
class ProductListNotifier extends StateNotifier<ProductListState> {
  final DetailServices _detailServices = DetailServices();

  ProductListNotifier() : super(ProductListState());

  /// 加载商品列表
  Future<void> loadProductList(String shopId, int saleWeekDay) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final query = SaleProductListQuery(
        shopId: shopId,
        saleWeekDay: saleWeekDay,
      );
      final products = await _detailServices.getSaleProductList(query);

      state = state.copyWith(products: products, isLoading: false);

      Logger.info(
        'ProductListNotifier',
        '商品列表加载成功: shopId=$shopId, saleWeekDay=$saleWeekDay, 共${products.length}个商品',
      );
    } catch (e) {
      Logger.error('ProductListNotifier', '商品列表加载失败: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 刷新商品列表
  Future<void> refresh(String shopId, int saleWeekDay) async {
    await loadProductList(shopId, saleWeekDay);
  }

  /// 清除错误状态
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 店铺详情数据 Provider（使用 family 支持多个店铺）
final detailProvider =
    StateNotifierProvider.family<DetailNotifier, DetailState, String>((
      ref,
      shopId,
    ) {
      return DetailNotifier();
    });

/// 店铺详情数据选择器
final shopDetailProvider = Provider.family<ShopModel?, String>((ref, shopId) {
  return ref.watch(detailProvider(shopId)).shop;
});

/// 店铺详情加载状态选择器
final shopDetailLoadingProvider = Provider.family<bool, String>((ref, shopId) {
  return ref.watch(detailProvider(shopId)).isLoading;
});

/// 店铺详情错误状态选择器
final shopDetailErrorProvider = Provider.family<String?, String>((ref, shopId) {
  return ref.watch(detailProvider(shopId)).error;
});

// ============= 优惠券相关 Providers =============

/// 优惠券数据 Provider（使用 family 支持多个店铺）
final couponProvider =
    StateNotifierProvider.family<CouponNotifier, CouponState, String>((
      ref,
      shopId,
    ) {
      return CouponNotifier();
    });

/// 优惠券数据选择器
final couponDataProvider = Provider.family<AvailableCouponModel?, String>((
  ref,
  shopId,
) {
  return ref.watch(couponProvider(shopId)).couponData;
});

/// 优惠券加载状态选择器
final couponLoadingProvider = Provider.family<bool, String>((ref, shopId) {
  return ref.watch(couponProvider(shopId)).isLoading;
});

/// 优惠券错误状态选择器
final couponErrorProvider = Provider.family<String?, String>((ref, shopId) {
  return ref.watch(couponProvider(shopId)).error;
});

final couponClaimingProvider = Provider.family<bool, String>((ref, shopId) {
  return ref.watch(couponProvider(shopId)).isClaiming;
});

// ============= 商品列表相关 Providers =============

/// 商品列表参数类
class ProductListParams {
  final String shopId;
  final int saleWeekDay;

  ProductListParams({required this.shopId, required this.saleWeekDay});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductListParams &&
        other.shopId == shopId &&
        other.saleWeekDay == saleWeekDay;
  }

  @override
  int get hashCode => shopId.hashCode ^ saleWeekDay.hashCode;
}

/// 商品列表数据 Provider（使用 family 支持多个店铺和星期）
final productListProvider = StateNotifierProvider.family<
  ProductListNotifier,
  ProductListState,
  ProductListParams
>((ref, params) {
  return ProductListNotifier();
});

/// 商品列表数据选择器
final productsProvider =
    Provider.family<List<SaleProductModel>, ProductListParams>((ref, params) {
      return ref.watch(productListProvider(params)).products;
    });

/// 商品列表加载状态选择器
final productListLoadingProvider = Provider.family<bool, ProductListParams>((
  ref,
  params,
) {
  return ref.watch(productListProvider(params)).isLoading;
});

/// 商品列表错误状态选择器
final productListErrorProvider = Provider.family<String?, ProductListParams>((
  ref,
  params,
) {
  return ref.watch(productListProvider(params)).error;
});

// ============= 商品详情相关 Providers =============

/// 商品详情数据状态
class ProductDetailState {
  final SaleProductModel? product;
  final bool isLoading;
  final String? error;

  ProductDetailState({this.product, this.isLoading = false, this.error});

  ProductDetailState copyWith({
    SaleProductModel? product,
    bool? isLoading,
    String? error,
  }) {
    return ProductDetailState(
      product: product ?? this.product,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// 商品详情参数类
class ProductDetailParams {
  final String productId;
  final String shopId;

  ProductDetailParams({required this.productId, required this.shopId});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductDetailParams &&
        other.productId == productId &&
        other.shopId == shopId;
  }

  @override
  int get hashCode => productId.hashCode ^ shopId.hashCode;
}

/// 商品详情数据状态管理
class ProductDetailNotifier extends StateNotifier<ProductDetailState> {
  ProductDetailNotifier(this.ref) : super(ProductDetailState());

  final Ref ref;

  /// 加载商品详情
  /// 优先从已加载的商品列表中查找
  Future<void> loadProductDetail(String productId, String shopId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 尝试从当前星期（以及可能的其他星期）的商品列表中查找
      SaleProductModel? foundProduct;
      final currentWeekday = DateTime.now().weekday;

      // 优先尝试当前星期
      for (int weekDay = 1; weekDay <= 7; weekDay++) {
        final params = ProductListParams(shopId: shopId, saleWeekDay: weekDay);

        // 检查该星期的商品列表是否已加载
        try {
          final productListState = ref.read(productListProvider(params));
          final product = productListState.products.firstWhere(
            (p) => p.id == productId,
            orElse: () => throw StateError('Not found'),
          );
          foundProduct = product;
          Logger.info(
            'ProductDetailNotifier',
            '从商品列表中找到商品: productId=$productId, weekDay=$weekDay',
          );
          break;
        } catch (e) {
          // 如果该星期的列表未加载或找不到商品，尝试下一个星期
          continue;
        }
      }

      if (foundProduct != null) {
        state = state.copyWith(product: foundProduct, isLoading: false);
        Logger.info(
          'ProductDetailNotifier',
          '商品详情加载成功: ${foundProduct.chineseName}',
        );
      } else {
        // 如果找不到，尝试加载当前星期的商品列表
        final currentParams = ProductListParams(
          shopId: shopId,
          saleWeekDay: currentWeekday,
        );
        await ref
            .read(productListProvider(currentParams).notifier)
            .loadProductList(shopId, currentWeekday);

        // 再次尝试查找
        final productListState = ref.read(productListProvider(currentParams));
        final product = productListState.products.firstWhere(
          (p) => p.id == productId,
          orElse: () => throw StateError('商品未找到'),
        );

        state = state.copyWith(product: product, isLoading: false);
        Logger.info(
          'ProductDetailNotifier',
          '商品详情加载成功: ${product.chineseName}',
        );
      }
    } catch (e) {
      Logger.error('ProductDetailNotifier', '商品详情加载失败: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 刷新商品详情
  Future<void> refresh(String productId, String shopId) async {
    await loadProductDetail(productId, shopId);
  }

  /// 清除错误状态
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 商品详情数据 Provider（使用 family 支持多个商品）
final productDetailProvider = StateNotifierProvider.family<
  ProductDetailNotifier,
  ProductDetailState,
  ProductDetailParams
>((ref, params) {
  return ProductDetailNotifier(ref);
});

/// 商品详情数据选择器
final productDetailDataProvider =
    Provider.family<SaleProductModel?, ProductDetailParams>((ref, params) {
      return ref.watch(productDetailProvider(params)).product;
    });

/// 商品详情加载状态选择器
final productDetailLoadingProvider = Provider.family<bool, ProductDetailParams>(
  (ref, params) {
    return ref.watch(productDetailProvider(params)).isLoading;
  },
);

/// 商品详情错误状态选择器
final productDetailErrorProvider =
    Provider.family<String?, ProductDetailParams>((ref, params) {
      return ref.watch(productDetailProvider(params)).error;
    });

/// 当前选中的星期
final selectedWeekdayProvider = StateProvider<int>((ref) {
  return DateTime.now().weekday;
});
