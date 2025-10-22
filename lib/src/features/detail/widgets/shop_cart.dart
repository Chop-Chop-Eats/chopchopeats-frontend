import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_image.dart';
import '../../../core/widgets/common_spacing.dart';

class ShopCart extends StatefulWidget {
  const ShopCart({super.key});

  @override
  State<ShopCart> createState() => _ShopCartState();
}

class _ShopCartState extends State<ShopCart> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.r),
          topRight: Radius.circular(10.r),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildPriceInfo(l10n: l10n),
          _buildOrder(l10n: l10n),
        ],
      ),
    );
  }

  Widget _buildPriceInfo({
    required AppLocalizations l10n,
  }){
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // 角标 
            Positioned(
              right: -8.w,
              top: -8.h,
              child: Container(
                width: 16.w,
                height: 16.h,
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(child: Text('100', style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.bold))),
              ),
            ),
            CommonImage(imagePath: 'assets/images/shop_cart.png', width: 24.w, height: 24.h),
          ],
        ), 
        CommonSpacing.width(8.w),
        Column(
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${l10n.totalPrice}:', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
                  TextSpan(text: '\$100', style: TextStyle(fontSize: 16.sp, color: AppTheme.primaryOrange, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            // 国际化
            Text('${l10n.estimatedDeliveryFee}  : \$10', style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
          ],
        )
      ],
    );
  }

  Widget _buildOrder({
    required AppLocalizations l10n,
  }){
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryOrange,
        borderRadius: BorderRadius.circular(16.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: Text('${l10n.orderNow}', style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}
