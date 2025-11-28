import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger/logger.dart';
import '../providers/cart_notifier.dart';
import '../providers/cart_state.dart';

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
    // 创建当前商品的引用
    final currentProductRef = CartProductRef(
      productId: productId,
      productSpecId: productSpecId,
    );
    // 只有当正在操作的商品是当前商品时才禁用
    final isBusy = cartState.operatingProductRef != null &&
        cartState.operatingProductRef == currentProductRef;
    final canDecrease = quantity > 0 && !isBusy && _isSpecValid;
    final canIncrease = !isBusy && _isSpecValid;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: canIncrease || canDecrease
              ? AppTheme.primaryOrange
              : Colors.grey[300]!,
          width: 1.w,
        ),
        color: canIncrease || canDecrease ? Colors.white : Colors.grey[100],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            icon: Icons.remove,
            enabled: canDecrease,
            onTap: () => _onDecrease(ref),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              quantity.toString(),
              style: TextStyle(
                color: isBusy ? Colors.grey[400] : Colors.black,
                fontSize: 12.sp,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
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
        decoration: enabled
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
