import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/locale_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_image.dart';
import '../../../core/widgets/common_spacing.dart';
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
      physics: const BouncingScrollPhysics(),
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
    // 根据当前语言选择产品名称
    final productName = LocaleService.getLocalizedText(
      item.productName,
      item.englishProductName,
    );
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
              // 显示SKU信息
              if (item.skuSetting == 1) ...[
                CommonSpacing.height(4.h),
                _buildSkuInfo(item),
              ],
              CommonSpacing.small,
              Text(
                '\$${price.toStringAsFixed(2)}',
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
          productName: item.productName ?? '',
          englishProductName: item.englishProductName,
          selectedSkus:
              item.selectedSkus
                  ?.map(
                    (sku) => SelectedSkuVO(
                      id: sku.id ?? '',
                      skuName: sku.skuName ?? '',
                      englishSkuName: sku.englishSkuName,
                      skuPrice: sku.skuPrice ?? 0,
                      skuGroupId: sku.skuGroupId,
                      skuGroupType: sku.skuGroupType,
                    ),
                  )
                  .toList(),
          diningDate: diningDate,
          cartItemId: item.id, // 传递购物车条目ID
        ),
      ],
    );
  }

  /// 构建SKU信息显示
  Widget _buildSkuInfo(CartItemModel item) {
    // 优先使用 productSpecName（单个SKU的情况）
    if (item.productSpecName != null && item.productSpecName!.isNotEmpty) {
      return Text(
        item.productSpecName!,
        style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    // 只显示用户实际选择的SKU（selectedSkus），不显示所有可用SKU（skus）
    final skuList = item.selectedSkus;
    if (skuList == null || skuList.isEmpty) {
      return const SizedBox.shrink();
    }

    // 根据 skuGroupType 分组显示
    final mutualExclusiveSkus = <String>[]; // skuGroupType = 2 (互斥)
    final stackableSkus = <String>[]; // skuGroupType = 1 (可叠加)

    for (final sku in skuList) {
      // 根据当前语言选择SKU名称
      final skuName = LocaleService.getLocalizedText(
        sku.skuName,
        sku.englishSkuName,
      );
      if (skuName.isEmpty) continue;

      if (sku.skuGroupType == 2) {
        mutualExclusiveSkus.add(skuName);
      } else {
        stackableSkus.add(skuName);
      }
    }

    final allSkuNames = [...mutualExclusiveSkus, ...stackableSkus];
    if (allSkuNames.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      allSkuNames.join(', '),
      style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
