import 'package:chop_user/src/core/routing/navigate.dart';
import 'package:chop_user/src/features/detail/widgets/sku_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unified_popups/unified_popups.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/utils/pop/confirm.dart';
import '../../../core/utils/pop/toast.dart';
import '../../../core/widgets/common_image.dart';
import '../../../core/widgets/common_spacing.dart';
import '../models/order_model.dart';
import '../providers/cart_notifier.dart';
import '../providers/cart_state.dart';
import 'bottom_arc_container.dart';

class ShopCart extends ConsumerStatefulWidget {
  const ShopCart({super.key, required this.shopId});

  final String shopId;

  @override
  ConsumerState<ShopCart> createState() => _ShopCartState();
}

class _ShopCartState extends ConsumerState<ShopCart> {
  final GlobalKey _shopCartKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cartState = ref.watch(cartStateProvider(widget.shopId));

    return GestureDetector(
      onTap: cartState.isEmpty ? null : () => _openCartSheet(cartState, l10n),
      key: _shopCartKey,
      child: BottomArcContainer(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPriceInfo(
              l10n: l10n,
              quantity: cartState.totalQuantity,
              totals: cartState.totals,
            ),
            
            
            _buildOrder(l10n: l10n, cartState: cartState),
          ],
        ),
      ),
    );
  }

  Future<void> _openCartSheet(
    CartState cartState,
    AppLocalizations l10n,
  ) async {
    if (cartState.isEmpty) {
      return;
    }
    if (PopupManager.hasNonToastPopup) {
      PopupManager.hideLast();
    }
    await Pop.sheet(
      maxHeight: SheetDimension.fraction(0.4),
      dockToEdge: true,
      edgeGap: 80.h,
      boxShadow: [],
      childBuilder:
          (dismiss) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${l10n.cartTitle} (${cartState.totalQuantity})',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final res = await confirm(
                        l10n.clearCartConfirmMessage,
                        confirmText: l10n.btnConfirm,
                        cancelText: l10n.btnCancel,
                      );
                      if (res != null && res == true) {
                        _clearCart(cartState, dismiss);
                      }
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Colors.black,
                      size: 16.sp,
                    ),
                  ),
                ],
              ),
              CommonSpacing.medium,
              if (cartState.items.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Text(
                    l10n.cartEmpty,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemBuilder:
                        (context, index) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: _buildSheetItem(
                            cartState,
                            cartState.items[index],
                          ),
                        ),
                    itemCount: cartState.items.length,
                  ),
                ),
            ],
          ),
    );
  }

  Future<void> _clearCart(CartState cartState, VoidCallback dismiss) async {
    final notifier = ref.read(cartProvider.notifier);
    try {
      await notifier.clearCart(
        shopId: widget.shopId,
        diningDate: cartState.diningDate,
      );
      dismiss();
    } catch (e) {
      _toast('清空失败，请稍后重试');
    }
  }

  Widget _buildSheetItem(CartState cartState, CartItemModel item) {
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
              CommonSpacing.small,
              Text(
                specName,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              ),
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
          shopId: widget.shopId,
          productId: item.productId ?? '',
          productName: productName,
          productSpecId: item.productSpecId ?? '',
          productSpecName: specName.isEmpty ? productName : specName,
          diningDate: cartState.diningDate,
          price: price,
        ),
      ],
    );
  }

  Widget _buildPriceInfo({
    required AppLocalizations l10n,
    required int quantity,
    required CartTotals totals,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -8.w,
              top: -10.h,
              child: Container(
                width: 16.w,
                height: 16.h,
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Text(
                    '$quantity',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            CommonImage(
              imagePath: 'assets/images/shop_cart.png',
              width: 24.w,
              height: 24.h,
            ),
          ],
        ),
        CommonSpacing.width(10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${l10n.totalPrice}:',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  TextSpan(
                    text: '\$${totals.subtotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppTheme.primaryOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${l10n.estimatedDeliveryFee}:\$${totals.deliveryFee.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrder({
    required AppLocalizations l10n,
    required CartState cartState,
  }) {
    return GestureDetector(
      onTap: () {
        if (cartState.isEmpty) {
          _toast('购物车为空，无法下单');
          return;
        }
        Logger.info('ShopCart', '点击下单 shopId=${widget.shopId}');
        Navigate.push(context, Routes.confirmOrder);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.primaryOrange,
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        child: Text(
          l10n.orderNow,
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _toast(String message) {
    toast.warn(message);
  }
}

