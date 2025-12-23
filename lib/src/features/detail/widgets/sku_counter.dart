import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/pop/confirm.dart';
import '../providers/cart_notifier.dart';

class SkuCounter extends ConsumerWidget {
  const SkuCounter({
    super.key,
    required this.shopId,
    required this.productId,
    required this.productName,
    required this.productSpecId,
    required this.productSpecName,
    this.diningDate,
    this.price,
  });

  final String shopId;
  final String productId;
  final String productName;
  final String productSpecId;
  final String productSpecName;
  final String? diningDate;
  final double? price;

  bool get _isSpecValid => true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartStateProvider(shopId));
    final quantity = cartState.quantityOf(productId, productSpecId);
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
          productSpecId: productSpecId,
          productSpecName: productSpecName,
          price: price,
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
          productSpecId: productSpecId,
        );
  }
}
