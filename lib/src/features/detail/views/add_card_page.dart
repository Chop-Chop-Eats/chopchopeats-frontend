import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      toast('Please fill in complete card information');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 使用 Stripe SDK 创建 PaymentMethod
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      // 将 PaymentMethod ID 发送给后端
      final success = await ref
          .read(paymentServiceProvider)
          .addPaymentMethod(paymentMethod.id, isDefault: _isDefault);

      if (success) {
        toast('Added successfully');
        ref.invalidate(paymentMethodsListProvider);
        if (mounted) Navigator.pop(context);
      } else {
        toast('Failed to add, please try again');
      }
    } on StripeException catch (e) {
      final errorMsg =
          e.error.localizedMessage ??
          e.error.message ??
          'Card verification failed';
      toast(errorMsg);
      debugPrint('Stripe Error: ${e.error.code} - $errorMsg');
    } catch (e, stackTrace) {
      toast('An error occurred, please try again');
      debugPrint('Add card error: $e');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(title: 'Add Card'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Card Information'),
            SizedBox(height: 8.h),
            _buildCardField(),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Set as default card',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
                Switch(
                  value: _isDefault,
                  activeColor: AppTheme.primaryOrange,
                  onChanged: (val) => setState(() => _isDefault = val),
                ),
              ],
            ),
            SizedBox(height: 40.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  disabledBackgroundColor: AppTheme.primaryOrange.withOpacity(
                    0.6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                ),
                child:
                    _isLoading
                        ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildCardField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: CardField(
        controller: _cardEditController,
        enablePostalCode: true,
        countryCode: 'US',
        style: TextStyle(fontSize: 16.sp, color: Colors.black),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintStyle: TextStyle(color: Colors.grey[400]),
        ),
      ),
    );
  }
}
