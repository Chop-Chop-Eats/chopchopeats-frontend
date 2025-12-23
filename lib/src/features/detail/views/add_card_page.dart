import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/pop/toast.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../providers/payment_provider.dart';

class AddCardPage extends ConsumerStatefulWidget {
  const AddCardPage({super.key});

  @override
  ConsumerState<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends ConsumerState<AddCardPage> {
  final CardEditController _cardEditController = CardEditController();
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _cardEditController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_cardEditController.complete) {
      toast('请填写完整的卡片信息');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. 在 Stripe 创建 PaymentMethod
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      // 2. 发送 ID 给后端
      final success = await ref.read(paymentServiceProvider).addPaymentMethod(
        paymentMethod.id,
        isDefault: _isDefault,
      );

      if (success) {
        toast('添加成功');
        // 刷新列表
        ref.invalidate(paymentMethodsListProvider);
        if (mounted) Navigator.pop(context);
      } else {
        toast('添加失败，请重试');
      }
    } on StripeException catch (e) {
      toast('卡片验证失败: ${e.error.localizedMessage}');
    } catch (e) {
      toast('发生错误: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(title: '添加卡片'),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('卡片信息', style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
            SizedBox(height: 12.h),
            // Stripe 原生卡片输入组件
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              child: CardField(
                controller: _cardEditController,
                style: TextStyle(fontSize: 16.sp, color: Colors.black),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '卡号 / 有效期 / CVC',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                ),
                enablePostalCode: true, // 开启邮编输入
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('设置为默认卡号', style: TextStyle(fontSize: 14.sp)),
                Switch(
                  value: _isDefault,
                  activeColor: AppTheme.primaryOrange,
                  onChanged: (val) => setState(() => _isDefault = val),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        '保存',
                        style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
