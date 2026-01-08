import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/pop/toast.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_dialog.dart';
import '../../../core/widgets/common_image.dart';
import '../models/payment_models.dart';
import '../providers/payment_provider.dart';
import '../services/payment_service.dart';
import 'add_card_page.dart';

class ManagePaymentMethodsPage extends ConsumerWidget {
  const ManagePaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentMethodsAsync = ref.watch(paymentMethodsListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(title: 'Manage Payment Methods'),
      body: paymentMethodsAsync.when(
        data: (methods) {
          // 过滤掉钱包，只显示卡片
          final cards =
              methods
                  .where((m) => m.type == AppPaymentMethodType.stripeCard)
                  .toList();

          return Column(
            children: [
              // 添加提示信息
              Container(
                margin: EdgeInsets.all(16.w),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: const Color(0xFFFFD966)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: const Color(0xFFFF9800),
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'If card is invalid during payment, please delete and re-add it',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF996600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(24.w),
                  children: [
                    ...cards.map(
                      (method) => _buildCardItem(context, ref, method),
                    ),
                    SizedBox(height: 20.h),
                    // 添加新卡按钮
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddCardPage(),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF5F0),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Add New Card',
                          style: TextStyle(
                            color: AppTheme.primaryOrange,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Failed to load: $err')),
      ),
    );
  }

  Widget _buildCardItem(
    BuildContext context,
    WidgetRef ref,
    PaymentSelectionWrapper method,
  ) {
    final iconPath = _getCardIconPath(method.card?.cardBrand ?? '');

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          // 卡片图标
          CommonImage(
            imagePath: iconPath,
            width: 36.w,
            height: 36.w,
            fit: BoxFit.fitWidth,
          ),
          SizedBox(width: 16.w),
          // 卡片信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      method.displayName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    if (method.card?.isDefault == true) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE4D6),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'Default',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppTheme.primaryOrange,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // 解绑按钮
          GestureDetector(
            onTap: () => _showDeleteConfirmDialog(context, ref, method),
            child: Text(
              'Unbind Card',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.primaryOrange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCardIconPath(String cardBrand) {
    final brand = cardBrand.toLowerCase();
    if (brand.contains('visa')) {
      return 'assets/images/visa.png';
    } else if (brand.contains('mastercard')) {
      return 'assets/images/mastercard.png';
    } else if (brand.contains('paypal')) {
      return 'assets/images/paypal.png';
    }
    return 'assets/images/wallet.png';
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    PaymentSelectionWrapper method,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => CommonDialog(
            title: 'Confirm Unbind',
            subtitle: 'Are you sure you want to unbind ${method.displayName}?',
            cancelText: 'Cancel',
            confirmText: 'Unbind',
            confirmButtonColor: const Color(0xFFFF4D4F),
            confirmTextColor: Colors.white,
            onConfirm: () => _deleteCard(context, ref, method),
          ),
    );
  }

  Future<void> _deleteCard(
    BuildContext context,
    WidgetRef ref,
    PaymentSelectionWrapper method,
  ) async {
    if (method.card == null) return;

    final service = ref.read(paymentServiceProvider);
    final success = await service.deletePaymentMethod(method.card!.id);

    if (success) {
      toast('Unbind Successful');
      // 刷新列表
      ref.invalidate(paymentMethodsListProvider);
    } else {
      toast('Unbind failed, please try again');
    }
  }
}
