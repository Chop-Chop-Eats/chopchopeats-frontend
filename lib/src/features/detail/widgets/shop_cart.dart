import 'package:chop_user/src/core/routing/navigate.dart';
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
import '../providers/cart_notifier.dart';
import '../providers/cart_state.dart';
import '../models/order_model.dart' show formatDiningDate;
import 'bottom_arc_container.dart';
import 'cart_item_list.dart';

class ShopCart extends ConsumerStatefulWidget {
  const ShopCart({
    super.key,
    required this.shopId,
    required this.selectedDate,
  });

  final String shopId;
  final DateTime selectedDate; // 当前选中的日期

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
          (dismiss) => Consumer(
            builder: (context, ref, child) {
              // 实时监听购物车状态变化
              final currentCartState = ref.watch(cartStateProvider(widget.shopId));
              
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${l10n.cartTitle} (${currentCartState.totalQuantity})',
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
                            _clearCart(currentCartState, dismiss);
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
                  if (currentCartState.items.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: Text(
                        l10n.cartEmpty,
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                      ),
                    )
                  else
                    Flexible(
                      child: SingleChildScrollView(
                        child: CartItemList(
                          shopId: widget.shopId,
                          items: currentCartState.items,
                          diningDate: currentCartState.diningDate,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
    );
  }

  Future<void> _clearCart(CartState cartState, VoidCallback dismiss) async {
    final notifier = ref.read(cartProvider.notifier);
    try {
      // 先关闭Sheet，给用户即时反馈
      dismiss();
      // 然后清空购物车
      await notifier.clearCart(
        shopId: widget.shopId,
        diningDate: cartState.diningDate,
      );
    } catch (e) {
      _toast('清空失败，请稍后重试');
    }
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
    final isBusy = cartState.isSyncing || cartState.isUpdating;
    final isDisabled = cartState.isEmpty || isBusy;
    
    return GestureDetector(
      onTap: isDisabled ? null : () async {
        Logger.info('ShopCart', '点击下单 shopId=${widget.shopId}');
        // 使用传入的选中日期
        final diningDateStr = formatDiningDate(widget.selectedDate);
        final result = await Navigate.push(
          context,
          Routes.confirmOrder,
          arguments: {
            "shopId": widget.shopId,
            "initialDiningDate": diningDateStr,
          },
        );
        
        // 支付成功后清空购物车
        if (result == true || (result is Map && result['success'] == true)) {
          final notifier = ref.read(cartProvider.notifier);
          try {
            await notifier.clearCart(
              shopId: widget.shopId,
              diningDate: cartState.diningDate,
            );
            Logger.info('ShopCart', '支付成功，购物车已清空');
          } catch (e) {
            Logger.error('ShopCart', '清空购物车失败: $e');
            _toast('清空购物车失败');
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey[400] : AppTheme.primaryOrange,
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


