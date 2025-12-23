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
import '../providers/cart_notifier.dart'; // Ensure this is imported for cartProvider
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
    // 只在初始化时加载一次，Provider 会缓存数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final params = ProductListParams(
        shopId: widget.shopId,
        saleWeekDay: widget.saleWeekDay,
      );
      final currentState = ref.read(productListProvider(params));
      // 只有当数据为空且未加载时才请求
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
          height: 100.h, // 固定高度，与商品列表大致相同
          child: const Center(child: CommonIndicator()),
        ),
      );
    }

    if (error != null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: SizedBox(
          height: 200.h, // 固定高度，避免布局抖动
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48.w, color: Colors.red[300]),
                CommonSpacing.medium,
                Text(
                  '加载失败',
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
          height: 200.h, // 固定高度，避免布局抖动
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
                  '暂无商品',
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
            children:
                onSaleProducts
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
    required String diningDate, // 格式: YYYY-MM-DD
    required CartState cartState,
  }) {
    final isSku = product.skuSetting == 1;
    final firstSku = product.skus.isNotEmpty ? product.skus.first : null;

    // 价格显示逻辑：优先使用 productPrice，否则使用第一个 SKU 的价格
    final displayPrice = product.productPrice ?? (firstSku?.price ?? 0.0);
    final priceText =
        isSku
            ? '\$${displayPrice.toStringAsFixed(2)}' // 多规格通常显示起步价，或者直接显示价格
            : '\$${displayPrice.toStringAsFixed(2)}';

    // 数量逻辑
    final quantity =
        !isSku && firstSku != null
            ? cartState.quantityOf(product.id, firstSku.id ?? '')
            : 0;

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
        width: 160.w, // 固定宽度
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        margin: EdgeInsets.only(right: 12.w, bottom: 12.h), // 增加间距
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图片区域
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child:
                    product.carouselImages?.isNotEmpty ?? false
                        ? CommonImage(
                          imagePath: product.carouselImages![0].url ?? '',
                          width: 120.w,
                          height: 120.w, // 正方形图片
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
              height: 40.h, // 固定高度以保持对齐
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

                // 操作按钮
                if (isSku)
                  _buildAddButton(
                    onTap:
                        () => Navigate.push(
                          context,
                          Routes.productDetail,
                          arguments: {
                            "productId": product.id,
                            "shopId": product.shopId,
                          },
                        ),
                  )
                else if (quantity > 0)
                  _buildSkuCounter(firstSku, product, diningDate)
                else
                  _buildAddButton(
                    onTap: () => _addToCart(product, firstSku, diningDate),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
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
    if (sku == null) return;
    await ref
        .read(cartProvider.notifier)
        .increment(
          shopId: product.shopId,
          diningDate: diningDate,
          productId: product.id,
          productName: product.localizedName,
          productSpecId: sku.id ?? '',
          productSpecName: sku.skuName ?? product.localizedName,
          price: sku.price,
        );
  }

  /// 构建SKU计数器
  Widget _buildSkuCounter(
    SaleProductSku? sku,
    SaleProductModel product,
    String diningDate, // 格式: YYYY-MM-DD
  ) {
    if (sku == null || sku.id == null) return SizedBox.shrink();
    return SkuCounter(
      shopId: widget.shopId,
      productId: product.id,
      productName: product.localizedName,
      productSpecId: sku.id ?? '',
      productSpecName: sku.skuName ?? product.localizedName,
      diningDate: diningDate,
      price: sku.price,
    );
  }

  /// 构建选择按钮 (不再使用，保留以防万一)
  Widget _buildSelectButton(
    String selectSpecification,
    SaleProductModel product,
    String diningDate, // 格式: YYYY-MM-DD
  ) {
    return GestureDetector(
      onTap:
          () => Navigate.push(
            context,
            Routes.productDetail,
            arguments: {"productId": product.id, "shopId": product.shopId},
          ),
      child: Text("+", style: TextStyle(fontSize: 16.sp)),
    );
  }
}
