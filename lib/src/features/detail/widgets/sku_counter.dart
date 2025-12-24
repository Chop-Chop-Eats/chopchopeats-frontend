import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/pop/confirm.dart';
import '../models/order_model.dart';
import '../providers/cart_notifier.dart';

class SkuCounter extends ConsumerWidget {
  const SkuCounter({
    super.key,
    required this.shopId,
    required this.productId,
    required this.productName,
    this.englishProductName,
    this.selectedSkus,
    this.diningDate,
    this.price,
    this.cartItemId, // 添加购物车条目ID，用于直接查找
  });

  final String shopId;
  final String productId;
  final String productName;
  final String? englishProductName;
  final List<SelectedSkuVO>? selectedSkus;
  final String? diningDate;
  final double? price;
  final String? cartItemId; // 购物车条目ID

  bool get _isSpecValid => true;
  
  // 用于查找购物车中的商品（使用第一个SKU的ID作为key）
  String get _productSpecId => selectedSkus?.isNotEmpty == true ? selectedSkus!.first.id : '';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartStateProvider(shopId));
    
    // 如果有cartItemId，直接从购物车中查找该条目
    int quantity = 0;
    CartItemModel? matchedItem;
    
    if (cartItemId != null) {
      try {
        matchedItem = cartState.items.firstWhere(
          (item) => item.id == cartItemId,
        );
        quantity = matchedItem.quantity ?? 0;
      } catch (_) {
        quantity = 0;
      }
    } else {
      // 否则使用productId和productSpecId查找
      quantity = cartState.quantityOf(productId, _productSpecId);
    }
    
    final canDecrease = quantity > 0 && _isSpecValid;
    final canIncrease = _isSpecValid;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color:
              canIncrease || canDecrease
                  ? AppTheme.primaryOrange
                  : Colors.grey[300]!,
          width: 1.w,
        ),
        color: canIncrease || canDecrease ? Colors.white : Colors.grey[100],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (quantity > 0) ...[
            _buildButton(
              icon: Icons.remove,
              enabled: canDecrease,
              onTap: () => _onDecrease(context, ref, quantity),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                quantity.toString(),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
          _buildButton(
            icon: Icons.add,
            enabled: canIncrease,
            onTap: () => _onIncrease(ref),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        decoration:
            enabled
                ? null
                : BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12.r),
                ),
        child: Icon(
          icon,
          size: 16.w,
          color: enabled ? Colors.black : Colors.grey[400],
        ),
      ),
    );
  }

  Future<void> _onIncrease(WidgetRef ref) async {
    await ref
        .read(cartProvider.notifier)
        .increment(
          shopId: shopId,
          diningDate: diningDate,
          productId: productId,
          productName: productName,
          englishProductName: englishProductName,
          selectedSkus: selectedSkus,
        );
  }

  Future<void> _onDecrease(
    BuildContext context,
    WidgetRef ref,
    int currentQuantity,
  ) async {
    // 数量为 1 时，弹出确认删除对话框
    if (currentQuantity == 1) {
      final l10n = AppLocalizations.of(context)!;
      final confirmed = await confirm(
        l10n.removeItemConfirmMessage,
        confirmText: l10n.btnConfirm,
        cancelText: l10n.btnCancel,
      );
      if (confirmed != true) {
        return;
      }
    }

    await ref
        .read(cartProvider.notifier)
        .decrement(
          shopId: shopId,
          diningDate: diningDate,
          productId: productId,
          productSpecId: _productSpecId,
        );
  }
}
