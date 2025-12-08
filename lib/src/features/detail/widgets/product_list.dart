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
  }) {
    final isSku = product.skuSetting == 1;
    final firstSku = product.skus.isNotEmpty ? product.skus.first : null;
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 10.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (product.carouselImages?.isNotEmpty ?? false)
              CommonImage(
                imagePath:
                    product.carouselImages?[0].url ??
                    '',
                width: 48.w,
                height: 48.h,
              )
            else
              CommonImage(
                imagePath: "assets/images/restaurant2.png",
                width: 48.w,
                height: 48.h,
              ),
            CommonSpacing.small,
            Text(
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
            CommonSpacing.small,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  firstSku != null
                      ? !isSku
                          ? '\$${firstSku.price.toStringAsFixed(2)}'
                          : '\$${firstSku.price.toStringAsFixed(2)}+'
                      : '\$0.00',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CommonSpacing.width(8),

                // 操作按钮
                if (isSku)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppTheme.primaryOrange,
                        width: 1.w,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 8.w),
                    child: _buildSelectButton(
                      selectSpecification,
                      product,
                      diningDate,
                    ),
                  )
                else
                  _buildSkuCounter(firstSku, product, diningDate),
              ],
            ),
          ],
        ),
      ),
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

  /// 构建选择按钮
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
      child: Text(
        "+",
        style: TextStyle(
          fontSize: 16.sp,
        ),
      ),
    );
  }
}
