import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_image.dart';
import '../../../core/widgets/common_spacing.dart';
import '../models/detail_model.dart';

Future<SaleProductSku?> showSkuSelectorSheet(
  BuildContext context,
  SaleProductModel product,
) {
  if (product.skus.isEmpty) {
    return Future.value(null);
  }
  return showModalBottomSheet<SaleProductSku>(
    context: context,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
    ),
    builder: (_) => _SkuSelectorSheet(product: product),
  );
}

class _SkuSelectorSheet extends StatelessWidget {
  const _SkuSelectorSheet({required this.product});

  final SaleProductModel product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 16.h,
        bottom: 24.h + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CommonImage(
                imagePath: product.imageThumbnail ?? '',
                width: 48.w,
                height: 48.h,
                borderRadius: 8.r,
              ),
              CommonSpacing.width(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.localizedName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    if (product.highlight != null)
                      Text(
                        product.highlight!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          CommonSpacing.medium,
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: product.skus.length,
              separatorBuilder: (_, __) => CommonSpacing.small,
              itemBuilder: (context, index) {
                final sku = product.skus[index];
                return _SkuTile(
                  sku: sku,
                  onTap: () => Navigator.of(context).pop(sku),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SkuTile extends StatelessWidget {
  const _SkuTile({required this.sku, required this.onTap});

  final SaleProductSku sku;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sku.skuName ?? '默认规格',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    CommonSpacing.small,
                    Text(
                      '\$${sku.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppTheme.primaryOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}
