import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger/logger.dart';
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
  });

  final String shopId;
  final String productId;
  final String productName;
  final String productSpecId;
  final String productSpecName;
  final String? diningDate; // 格式: YYYY-MM-DD

  bool get _isSpecValid => productSpecId.isNotEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartStateProvider(shopId));
    final quantity = cartState.quantityOf(productId, productSpecId);
    final isBusy = cartState.isUpdating || cartState.isOperating;
    final canDecrease = quantity > 0 && !isBusy;
    final canIncrease = !isBusy;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.primaryOrange, width: 1.w),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            icon: Icons.remove,
            enabled: canDecrease && _isSpecValid,
            onTap: () => _onDecrease(ref),
          ),
          Text(
            quantity.toString(),
            style: TextStyle(
              color: Colors.black,
              fontSize: 12.sp,
              fontWeight: FontWeight.normal,
            ),
          ),
          _buildButton(
            icon: Icons.add,
            enabled: canIncrease && _isSpecValid,
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
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
          child: Icon(icon, size: 16.w, color: Colors.black),
        ),
      ),
    );
  }

  Future<void> _onIncrease(WidgetRef ref) async {
    if (!_isSpecValid) {
      Logger.warn('SkuCounter', '缺少规格信息，无法增加数量 productId=$productId');
      return;
    }
    await ref
        .read(cartProvider.notifier)
        .increment(
          shopId: shopId,
          diningDate: diningDate,
          productId: productId,
          productName: productName,
          productSpecId: productSpecId,
          productSpecName: productSpecName,
        );
  }

  Future<void> _onDecrease(WidgetRef ref) async {
    if (!_isSpecValid) {
      Logger.warn('SkuCounter', '缺少规格信息，无法减少数量 productId=$productId');
      return;
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
