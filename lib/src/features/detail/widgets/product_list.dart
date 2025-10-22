import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_image.dart';
import '../../../core/widgets/common_indicator.dart';
import '../../../core/widgets/common_spacing.dart';
import '../models/detail_model.dart';
import '../providers/detail_provider.dart';

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
        ref.read(productListProvider(params).notifier).loadProductList(
          widget.shopId,
          widget.saleWeekDay,
        );
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

    if (isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: SizedBox(
          height: 100.h, // 固定高度，与商品列表大致相同
          child: const Center(
            child: CommonIndicator(),
          ),
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

    final onSaleProducts = products.where((product) => product.isOnSale).toList();

    if (onSaleProducts.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: SizedBox(
          height: 200.h, // 固定高度，避免布局抖动
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant_menu, size: 48.w, color: Colors.grey[300]),
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
            children: onSaleProducts.map<Widget>((product) {
              return _buildSaleItem(
                product: product,
                selectSpecification: l10n.selectSpecification,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// 构建可售商品项
  Widget _buildSaleItem({
    required SaleProductModel product,
    required String selectSpecification,
  }) {
    final isSku = product.skuSetting == 1; 
    final firstSku = product.skus.isNotEmpty ? product.skus.first : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      margin: EdgeInsets.only(right: 8.w),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 10.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CommonImage(
            imagePath: product.carouselImages?[0].url ?? product.imageThumbnail ?? '',
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
                    ? isSku? '\$${firstSku.price.toStringAsFixed(2)}' : '\$${firstSku.price.toStringAsFixed(2)}+'
                    : '\$0.00',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CommonSpacing.width(8),

              // 操作按钮
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isSku ? 12.r : 10.r),
                  border: Border.all(color: AppTheme.primaryOrange, width: 1.w),
                  color: isSku ? Colors.white : AppTheme.primaryOrange,
                ),
                child: isSku? _buildSkuCounter(firstSku): _buildSelectButton(selectSpecification),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建SKU计数器
  Widget _buildSkuCounter(SaleProductSku? sku) {
    if (sku == null) return SizedBox.shrink();
    return Row( 
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          // 数量必须 > 1
          onTap: () {
            // TODO: 实现减少数量逻辑
            Logger.info("ProductList", "点击减少数量");
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
            child: Icon(Icons.remove, size: 16.w, color: Colors.black),
          ),
        ),
        Text(
          '1', // TODO: 从购物车状态获取实际数量
          style: TextStyle(
            color: Colors.black,
            fontSize: 12.sp,
            fontWeight: FontWeight.normal,
          ),
        ),
        GestureDetector(
          // 数量必须小于 sku.stock
          onTap: () {
            Logger.info("ProductList", "点击增加数量");
            // TODO: 实现增加数量逻辑
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
            child: Icon(Icons.add, size: 16.w, color: Colors.black),
          ),
        ),
      ],
    );
  }

  /// 构建选择按钮
  Widget _buildSelectButton(String selectSpecification) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      child: GestureDetector(
        onTap: () {
          Logger.info("ProductList", "点击选择规格");
          // TODO: 实现选择规格逻辑
        },
        child: Text(
          selectSpecification,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
