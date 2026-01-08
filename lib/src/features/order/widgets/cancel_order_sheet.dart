import 'package:chop_user/src/core/utils/logger/logger.dart';
import 'package:chop_user/src/core/widgets/common_button.dart';
import 'package:chop_user/src/features/order/models/order_model.dart';
import 'package:chop_user/src/features/order/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CancelOrderSheet extends StatefulWidget {
  final String orderNo;
  final VoidCallback onSuccess;

  const CancelOrderSheet({
    super.key,
    required this.orderNo,
    required this.onSuccess,
  });

  @override
  State<CancelOrderSheet> createState() => _CancelOrderSheetState();
}

class _CancelOrderSheetState extends State<CancelOrderSheet> {
  final OrderService _orderService = OrderService();
  List<AppTradeRefundReasonRespVO> _myReasons = [];
  List<AppTradeRefundReasonRespVO> _chefReasons = [];
  int? _selectedReasonId;
  String _selectedReasonText = '';
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadReasons();
  }

  Future<void> _loadReasons() async {
    try {
      // 1-Chef/Product, 2-My Own
      final chefReasons = await _orderService.getRefundReasonListByCategory(1);
      final myReasons = await _orderService.getRefundReasonListByCategory(2);

      if (mounted) {
        setState(() {
          _chefReasons = chefReasons;
          _myReasons = myReasons;
          _isLoading = false;
        });
      }
    } catch (e) {
      Logger.error('CancelOrderSheet', 'Failed to load reasons: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (_selectedReasonText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请选择取消原因')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _orderService.cancelOrder(widget.orderNo, _selectedReasonText);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('订单已取消')));
        Navigator.pop(context);
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('取消失败: $e')));
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      constraints: BoxConstraints(maxHeight: 0.8.sh),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_myReasons.isNotEmpty) ...[
                      _buildSectionTitle('我自己的原因'),
                      ..._myReasons.map((e) => _buildReasonItem(e)),
                      SizedBox(height: 16.h),
                    ],
                    if (_chefReasons.isNotEmpty) ...[
                      _buildSectionTitle('私厨/商品的原因'),
                      ..._chefReasons.map((e) => _buildReasonItem(e)),
                    ],
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      alignment: Alignment.center,
      child: Text(
        '取消订单',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildReasonItem(AppTradeRefundReasonRespVO reason) {
    final isSelected = _selectedReasonId == reason.id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedReasonId = reason.id;
          _selectedReasonText = reason.reasonChinese ?? '';
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                reason.reasonChinese ?? '',
                style: TextStyle(fontSize: 14.sp, color: Colors.black87),
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFFFF5722) : Colors.grey,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: CommonButton(
          text: '提交',
          onPressed: _submit,
          isLoading: _isSubmitting,
          textColor: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          width: double.infinity,
        ),
      ),
    );
  }
}
