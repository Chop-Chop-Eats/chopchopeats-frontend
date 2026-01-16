import 'package:chop_user/src/features/detail/providers/cart_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/routing/navigate.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_image.dart';
import '../../../core/widgets/common_indicator.dart';
import '../../../core/widgets/common_spacing.dart';
import '../models/detail_model.dart';
import '../models/order_model.dart';
import '../providers/cart_notifier.dart';
import '../providers/detail_provider.dart';
import 'sku_counter.dart';

/// 商品列表组件
class ProductList extends ConsumerStatefulWidget {
  final String shopId;
  final int saleWeekDay;

  const ProductList({
    super.key,
    required this.shopId,
    required this.saleWeekDay,
  });

  @override
  ConsumerState<ProductList> createState() => _ProductListState();
}

class _ProductListState extends ConsumerState<ProductList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final params = ProductListParams(
        shopId: widget.shopId,
        saleWeekDay: widget.saleWeekDay,
      );
      final currentState = ref.read(productListProvider(params));
      if (currentState.products.isEmpty && !currentState.isLoading) {
        ref
            .read(productListProvider(params).notifier)
            .loadProductList(widget.shopId, widget.saleWeekDay);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final params = ProductListParams(
      shopId: widget.shopId,
      saleWeekDay: widget.saleWeekDay,
    );

    final products = ref.watch(productsProvider(params));
    final isLoading = ref.watch(productListLoadingProvider(params));
    final error = ref.watch(productListErrorProvider(params));
    final cartState = ref.watch(cartStateProvider(widget.shopId));
    final diningDate = cartState.diningDate;

    if (isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: SizedBox(
          height: 100.h,
          child: const Center(child: CommonIndicator()),
        ),
      );
    }

    if (error != null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: SizedBox(
          height: 200.h,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48.w, color: Colors.red[300]),
                CommonSpacing.medium,
                Text(
                  l10n.loadingFailedWithError,
                  style: TextStyle(fontSize: 14.sp, color: Colors.red[500]),
                ),
                CommonSpacing.small,
                Text(
                  error,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final onSaleProducts =
        products.where((product) => product.isOnSale).toList();

    if (onSaleProducts.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: SizedBox(
          height: 200.h,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 48.w,
                  color: Colors.grey[300],
                ),
                CommonSpacing.medium,
                Text(
                  l10n.noProductsText,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: onSaleProducts
                .map<Widget>(
                  (product) => _buildSaleItem(
                    product: product,
                    selectSpecification: l10n.selectSpecification,
                    diningDate: diningDate,
                    cartState: cartState,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  /// 构建可售商品项
  Widget _buildSaleItem({
    required SaleProductModel product,
    required String selectSpecification,
    required String diningDate,
    required CartState cartState,
  }) {
    final hasSku = product.skuSetting == 1;
    final firstSku = product.skus.isNotEmpty ? product.skus.first : null;

    // 价格显示逻辑
    final displayPrice = product.productPrice ?? (firstSku?.price ?? 0.0);
    final priceText = '\$${displayPrice.toStringAsFixed(2)}';

    // 计算该商品在购物车中的总数量（所有规格）
    int totalQuantity = 0;
    for (final item in cartState.items) {
      if (item.productId == product.id) {
        totalQuantity += item.quantity ?? 0;
      }
    }

    // 调试信息
    Logger.info(
      "ProductList",
      "商品: ${product.localizedName}, hasSku: $hasSku, "
      "totalQuantity: $totalQuantity, firstSku: ${firstSku?.id}",
    );

    return GestureDetector(
      onTap: () {
        Logger.info("ProductList", "点击商品: ${product.id}");
        Navigate.push(
          context,
          Routes.productDetail,
          arguments: {"productId": product.id, "shopId": product.shopId},
        );
      },
      child: Container(
        width: 160.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        margin: EdgeInsets.only(right: 12.w, bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图片区域
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: product.carouselImages?.isNotEmpty ?? false
                    ? CommonImage(
                        imagePath: product.carouselImages![0].url ?? '',
                        width: 120.w,
                        height: 120.w,
                        fit: BoxFit.cover,
                      )
                    : CommonImage(
                        imagePath: "assets/images/restaurant2.png",
                        width: 120.w,
                        height: 120.w,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            CommonSpacing.medium,

            // 名称
            SizedBox(
              height: 40.h,
              child: Text(
                product.localizedName,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
              ),
            ),
            CommonSpacing.small,

            // 价格和操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  priceText,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // 操作按钮逻辑：
                // 1. 有多规格 → 始终显示加号，点击跳转详情页选择 SKU
                // 2. 无多规格且数量 > 0 → 显示加减号
                // 3. 无多规格且数量 = 0 → 显示加号，点击直接加入购物车
                _buildActionButton(
                  hasSku: hasSku,
                  totalQuantity: totalQuantity,
                  product: product,
                  firstSku: firstSku,
                  diningDate: diningDate,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButton({
    required bool hasSku,
    required int totalQuantity,
    required SaleProductModel product,
    required SaleProductSku? firstSku,
    required String diningDate,
  }) {
    if (hasSku) {
      // 有多规格，显示加号跳转详情页
      return _buildAddButton(
        onTap: () => Navigate.push(
          context,
          Routes.productDetail,
          arguments: {
            "productId": product.id,
            "shopId": product.shopId,
          },
        ),
      );
    } else if (totalQuantity > 0) {
      // 无多规格且有数量，显示加减号
      return _buildSkuCounter(firstSku, product, diningDate);
    } else {
      // 无多规格且数量为0，显示加号直接加入购物车
      return _buildAddButton(
        onTap: () => _addToCart(product, firstSku, diningDate),
      );
    }
  }

  /// 构建圆形添加按钮
  Widget _buildAddButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28.w,
        height: 28.w,
        decoration: BoxDecoration(
          color: AppTheme.primaryOrange,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.add, color: Colors.white, size: 20.w),
      ),
    );
  }

  /// 添加到购物车
  Future<void> _addToCart(
    SaleProductModel product,
    SaleProductSku? sku,
    String diningDate,
  ) async {
    // 构建selectedSkus列表
    List<SelectedSkuVO>? selectedSkus;
    if (sku != null && sku.id != null) {
      selectedSkus = [
        SelectedSkuVO(
          id: sku.id!,
          skuName: sku.skuName ?? '',
          englishSkuName: sku.englishSkuName,
          skuPrice: sku.price,
          skuGroupId: sku.skuGroupId,
          skuGroupType: sku.skuGroupType,
        ),
      ];
    }

    await ref.read(cartProvider.notifier).increment(
          shopId: product.shopId,
          diningDate: diningDate,
          productId: product.id,
          productName: product.chineseName,
          englishProductName: product.englishName,
          selectedSkus: selectedSkus,
          productPrice: product.productPrice,
        );
  }

  /// 构建SKU计数器
  Widget _buildSkuCounter(
    SaleProductSku? sku,
    SaleProductModel product,
    String diningDate,
  ) {
    // 构建selectedSkus列表
    List<SelectedSkuVO>? selectedSkus;
    if (sku != null && sku.id != null) {
      selectedSkus = [
        SelectedSkuVO(
          id: sku.id!,
          skuName: sku.skuName ?? '',
          englishSkuName: sku.englishSkuName,
          skuPrice: sku.price,
          skuGroupId: sku.skuGroupId,
          skuGroupType: sku.skuGroupType,
        ),
      ];
    }

    return SkuCounter(
      shopId: widget.shopId,
      productId: product.id,
      productName: product.chineseName,
      englishProductName: product.englishName,
      selectedSkus: selectedSkus,
      diningDate: diningDate,
    );
  }
}
