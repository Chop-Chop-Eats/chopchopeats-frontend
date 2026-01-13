import 'package:chop_user/src/core/utils/logger/logger.dart';
import 'package:chop_user/src/core/utils/pop/toast.dart';
import 'package:chop_user/src/core/widgets/common_button.dart';
import 'package:chop_user/src/core/l10n/app_localizations.dart';
import 'package:chop_user/src/core/l10n/locale_service.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.isRefund ? l10n.orderRequestRefund : l10n.orderCancelOrRefundTitle,
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
              widget.isRefund ? l10n.orderWhyRefund : l10n.orderWhyCancel,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              widget.isRefund
                  ? l10n.orderRefundReasonHint
                  : l10n.orderCancelReasonHint,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
            SizedBox(height: 32.h),
            _buildCategoryItem(
              title: l10n.orderReasonCategoryChefProduct,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => CancelReasonPage(
                          orderNo: widget.orderNo,
                          category: 1,
                          categoryName: l10n.orderReasonCategoryChefProduct,
                          onSuccess: widget.onSuccess,
                          isRefund: widget.isRefund,
                        ),
                  ),
                );
              },
            ),
            SizedBox(height: 16.h),
            _buildCategoryItem(
              title: l10n.orderReasonCategoryPersonal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => CancelReasonPage(
                          orderNo: widget.orderNo,
                          category: 2,
                          categoryName: l10n.orderReasonCategoryPersonal,
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

  Widget _buildCategoryItem({
    required String title,
    required VoidCallback onTap,
  }) {
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
      final reasons = await _orderService.getRefundReasonListByCategory(
        widget.category,
      );
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
        final l10n = AppLocalizations.of(context)!;
        Toast.error(l10n.loadingFailedMessage(e.toString()));
      }
    }
  }

  Future<void> _submit() async {
    if (_selectedReasonText.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      Toast.show(widget.isRefund ? l10n.orderSelectRefundReason : l10n.orderSelectCancelReason);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (widget.isRefund) {
        await _orderService.applyRefund(widget.orderNo, _selectedReasonText);
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          Toast.success(l10n.orderRefundSubmitted);
          // Pop Reason Page
          Navigator.pop(context);
          // Pop Category Page
          Navigator.pop(context);
          widget.onSuccess();
        }
      } else {
        await _orderService.cancelOrder(widget.orderNo, _selectedReasonText);
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          Toast.success(l10n.orderCancelled);
          // Pop Reason Page
          Navigator.pop(context);
          // Pop Category Page
          Navigator.pop(context);
          widget.onSuccess();
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        Toast.error(
          widget.isRefund
              ? l10n.orderRefundFailed(e.toString())
              : l10n.orderCancelFailed(e.toString()),
        );
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.isRefund ? l10n.orderRequestRefund : l10n.orderCancelOrder,
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
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16.h),
                          Text(
                            widget.isRefund ? l10n.orderWhyRefund : l10n.orderWhyCancel,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            widget.isRefund
                                ? l10n.orderRefundReasonHint
                                : l10n.orderCancelReasonHint,
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
    final reasonText = LocaleService.getLocalizedText(
      reason.reasonChinese,
      reason.reasonEnglish,
    );
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedReasonId = reason.id;
          _selectedReasonText = reasonText;
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
                reasonText,
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
    final l10n = AppLocalizations.of(context)!;

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
          text: l10n.btnSubmit,
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
