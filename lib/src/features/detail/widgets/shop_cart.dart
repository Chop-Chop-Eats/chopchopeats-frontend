import 'package:chop_user/src/features/detail/widgets/sku_counter.dart';
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
        await _openCartSheet();
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

  Future<void> _openCartSheet() async {
    final res = await Pop.sheet(
      maxHeight: SheetDimension.fraction(0.6),
      dockToEdge:true,
      edgeGap: 80.h,
      boxShadow: [],
      childBuilder: (dismiss) =>  Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 代表购物车的数量
              Text("购物车(1)", style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.w500)),
              IconButton(
                onPressed: (){
                  Logger.info("ShopCart", "清空购物车");
                }, 
                icon: Icon(Icons.delete_forever_outlined, color: Colors.black, size: 16.sp)
              )
            ],
          ),
          // 每个加入购物车的商品 用 _buildSheetItem 渲染
      
        ],
      )
    );
  }

  Widget _buildSheetItem({
    required String imagePath,
    required String title,
    required String price,
  }){
    return Row(
      children: [
        CommonImage(imagePath: imagePath, width: 24.w, height: 24.h),
        CommonSpacing.width(12.w),
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 14.sp, color: Colors.black)),
            Text(price, style: TextStyle(fontSize: 16.sp, color: AppTheme.primaryOrange, fontWeight: FontWeight.w900)),
          ],
        ),
        SkuCounter()
       
      ],
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
