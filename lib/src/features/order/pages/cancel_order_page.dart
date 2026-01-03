import 'package:chop_user/src/core/utils/logger/logger.dart';
import 'package:chop_user/src/core/utils/pop/toast.dart';
import 'package:chop_user/src/core/widgets/common_button.dart';
import 'package:chop_user/src/features/order/models/order_model.dart';
import 'package:chop_user/src/features/order/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CancelOrderPage extends StatefulWidget {
  final String orderNo;
  final VoidCallback onSuccess;
  final bool isRefund;

  const CancelOrderPage({
    super.key,
    required this.orderNo,
    required this.onSuccess,
    this.isRefund = false,
  });

  @override
  State<CancelOrderPage> createState() => _CancelOrderPageState();
}

class _CancelOrderPageState extends State<CancelOrderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.isRefund ? '申请退款' : '取消/退款',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            Text(
              widget.isRefund ? '您为什么申请退款' : '您为什么取消订单',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              widget.isRefund ? '退款原因私厨不可见，您的选择会促使我们努力改善' : '取消原因私厨不可见，您的选择会促使我们努力改善',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 32.h),
            _buildCategoryItem(
              title: '私厨/商品的原因',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CancelReasonPage(
                      orderNo: widget.orderNo,
                      category: 1,
                      categoryName: '私厨/商品的原因',
                      onSuccess: widget.onSuccess,
                      isRefund: widget.isRefund,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 16.h),
            _buildCategoryItem(
              title: '我自己的原因',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CancelReasonPage(
                      orderNo: widget.orderNo,
                      category: 2,
                      categoryName: '我自己的原因',
                      onSuccess: widget.onSuccess,
                      isRefund: widget.isRefund,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem({required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class CancelReasonPage extends StatefulWidget {
  final String orderNo;
  final int category;
  final String categoryName;
  final VoidCallback onSuccess;
  final bool isRefund;

  const CancelReasonPage({
    super.key,
    required this.orderNo,
    required this.category,
    required this.categoryName,
    required this.onSuccess,
    this.isRefund = false,
  });

  @override
  State<CancelReasonPage> createState() => _CancelReasonPageState();
}

class _CancelReasonPageState extends State<CancelReasonPage> {
  final OrderService _orderService = OrderService();
  List<AppTradeRefundReasonRespVO> _reasons = [];
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
      final reasons = await _orderService.getRefundReasonListByCategory(widget.category);
      if (mounted) {
        setState(() {
          _reasons = reasons;
          _isLoading = false;
        });
      }
    } catch (e) {
      Logger.error('CancelReasonPage', 'Failed to load reasons: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Toast.error('加载失败: $e');
      }
    }
  }

  Future<void> _submit() async {
    if (_selectedReasonText.isEmpty) {
      Toast.show(widget.isRefund ? '请选择退款原因' : '请选择取消原因');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (widget.isRefund) {
        await _orderService.applyRefund(widget.orderNo, _selectedReasonText);
        if (mounted) {
          Toast.success('退款申请已提交');
          // Pop Reason Page
          Navigator.pop(context);
          // Pop Category Page
          Navigator.pop(context);
          widget.onSuccess();
        }
      } else {
        await _orderService.cancelOrder(widget.orderNo, _selectedReasonText);
        if (mounted) {
          Toast.success('订单已取消');
          // Pop Reason Page
          Navigator.pop(context);
          // Pop Category Page
          Navigator.pop(context);
          widget.onSuccess();
        }
      }
    } catch (e) {
      if (mounted) {
        Toast.error(widget.isRefund ? '申请退款失败: $e' : '取消失败: $e');
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.isRefund ? '申请退款' : '取消订单',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.h),
                        Text(
                          widget.isRefund ? '您为什么申请退款' : '您为什么取消订单',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          widget.isRefund ? '退款原因私厨不可见，您的选择会促使我们努力改善' : '取消原因私厨不可见，您的选择会促使我们努力改善',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 32.h),
                        Text(
                          widget.categoryName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Divider(color: Colors.grey[200]),
                        ..._reasons.map((e) => _buildReasonItem(e)),
                      ],
                    ),
                  ),
          ),
          _buildBottomButton(),
        ],
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
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                reason.reasonChinese ?? '',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
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
