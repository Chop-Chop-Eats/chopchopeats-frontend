import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_image.dart';
import '../models/payment_models.dart';
import '../providers/payment_provider.dart';
import 'add_card_page.dart';

class PaymentSelectionSheet extends ConsumerWidget {
  const PaymentSelectionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PaymentSelectionSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentMethodsAsync = ref.watch(paymentMethodsListProvider);
    final selectedMethod = ref.watch(selectedPaymentMethodProvider);

    return Container(
      height: 600.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          // 标题栏
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '选择支付方式',
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(width: 40.w), // 占位保持居中
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          
          // 列表内容
          Expanded(
            child: paymentMethodsAsync.when(
              data: (methods) {
                return ListView(
                  padding: EdgeInsets.all(24.w),
                  children: [
                    ...methods.map((method) => _buildPaymentItem(
                      context, 
                      ref, 
                      method, 
                      isSelected: selectedMethod?.displayName == method.displayName && selectedMethod?.type == method.type
                    )),
                    SizedBox(height: 20.h),
                    // 添加新卡按钮
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddCardPage()),
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
                          '添加新卡',
                          style: TextStyle(
                            color: AppTheme.primaryOrange,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('加载失败: $err')),
            ),
          ),

          // 确定按钮
          Padding(
            padding: EdgeInsets.all(24.w),
            child: SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                ),
                child: Text(
                  '确定',
                  style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(
    BuildContext context, 
    WidgetRef ref, 
    PaymentSelectionWrapper method, 
    {required bool isSelected}
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(selectedPaymentMethodProvider.notifier).state = method;
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppTheme.primaryOrange : Colors.grey[200]!,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            // 图标
            CommonImage(
              imagePath: method.iconPath,
              width: 40.w,
              height: 25.h,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 16.w),
            // 文字信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        method.displayName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      if (method.card?.isDefault == true) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE4D6),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            '默认',
                            style: TextStyle(fontSize: 10.sp, color: AppTheme.primaryOrange),
                          ),
                        )
                      ]
                    ],
                  ),
                  if (method.type == AppPaymentMethodType.wallet)
                    Text(
                      '可用余额 \$${method.walletBalance}',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                ],
              ),
            ),
            // 选中圆圈
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.primaryOrange : Colors.grey[400]!,
                  width: isSelected ? 6 : 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
