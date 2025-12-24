import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_image.dart';
import '../../../core/widgets/common_spacing.dart';
import '../../../core/l10n/locale_service.dart';
import '../models/order_model.dart';
import 'sku_counter.dart';

/// 购物车商品列表组件
class CartItemList extends ConsumerWidget {
  const CartItemList({
    super.key,
    required this.shopId,
    required this.items,
    required this.diningDate,
  });

  final String shopId;
  final List<CartItemModel> items;
  final String diningDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _buildCartItem(items[index]),
        );
      },
    );
  }

  Widget _buildCartItem(CartItemModel item) {
    final specName = item.productSpecName ?? '';
    final productName = item.productName ?? '';
    final image = item.imageThumbnail ?? 'assets/images/shop_cart.png';
    final price = item.price ?? 0;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CommonImage(
          imagePath: image,
          width: 40.w,
          height: 40.h,
          borderRadius: 8.r,
        ),
        CommonSpacing.width(12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                productName,
                style: TextStyle(fontSize: 14.sp, color: Colors.black),
              ),
              if (item.skus != null && item.skus!.isNotEmpty) ...[
                CommonSpacing.height(4.h),
                _buildSkuInfo(item.skus!),
              ],
              CommonSpacing.small,
              Text(
                '${price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.primaryOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        CommonSpacing.width(8.w),
        SkuCounter(
          shopId: shopId,
          productId: item.productId ?? '',
          productName: productName,
          productSpecId: item.productSpecId ?? '',
          productSpecName: specName.isEmpty ? productName : specName,
          diningDate: diningDate,
          price: price,
        ),
      ],
    );
  }

  /// 构建SKU信息显示
  Widget _buildSkuInfo(List<CartItemSku> skus) {
    // 按SKU分组并统计数量
    final skuCountMap = <String, int>{};
    final skuDisplayMap = <String, String>{};
    
    for (final sku in skus) {
      final skuId = sku.id ?? '';
      if (skuId.isEmpty) continue;
      
      final displayName = LocaleService.getLocalizedText(
        sku.skuName,
        sku.englishSkuName,
      );
      if (displayName.isEmpty) continue;
      
      skuCountMap[skuId] = (skuCountMap[skuId] ?? 0) + 1;
      skuDisplayMap[skuId] = displayName;
    }
    
    if (skuCountMap.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // 构建显示文本：数量x SKU名称
    final skuTexts = skuCountMap.entries.map((entry) {
      final skuId = entry.key;
      final count = entry.value;
      final name = skuDisplayMap[skuId] ?? '';
      return count > 1 ? '${count}x$name' : name;
    }).join(', ');

    return Text(
      skuTexts,
      style: TextStyle(
        fontSize: 12.sp,
        color: Colors.grey[600],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
