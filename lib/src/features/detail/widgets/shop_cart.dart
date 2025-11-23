import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unified_popups/unified_popups.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_image.dart';
import '../../../core/widgets/common_spacing.dart';

class ShopCart extends StatefulWidget {
  const ShopCart({super.key});

  @override
  State<ShopCart> createState() => _ShopCartState();
}

class _ShopCartState extends State<ShopCart> {
  final GlobalKey _shopCartKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () async {
        if(PopupManager.hasNonToastPopup) {
          PopupManager.hideLast();
          return;
        }
        Logger.info("ShopCart", "点击购物车");
        final res = await Pop.sheet(
          dockToEdge:true,
          edgeGap: 80.h,
          boxShadow: [],
          childBuilder: (dismiss) => Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("构图车弹出层"),
                Text("构图车弹出层"),
                Text("构图车弹出层"),
                Text("构图车弹出层"),
              ],
            ),
          )
        );
      },
      child: Container(
        key: _shopCartKey,
        height: 80.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
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
      ),
    );
  }

  Widget _buildPriceInfo({
    required AppLocalizations l10n,
  }){
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
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
                child: Center(child: Text('10', style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.bold))),
              ),
            ),
            CommonImage(imagePath: 'assets/images/shop_cart.png', width: 24.w, height: 24.h),
          ],
        ), 
        CommonSpacing.width(12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${l10n.totalPrice}:', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
                  TextSpan(text: '\$100', style: TextStyle(fontSize: 16.sp, color: AppTheme.primaryOrange, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Text('${l10n.estimatedDeliveryFee}  : \$10', style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
          ],
        )
      ],
    );
  }

  Widget _buildOrder({
    required AppLocalizations l10n,
  }){
    return GestureDetector(
      onTap: () {
        Logger.info("ShopCart", "点击下单");
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.primaryOrange,
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        child: Text(l10n.orderNow, style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold)),
      )
    );
  }
}
