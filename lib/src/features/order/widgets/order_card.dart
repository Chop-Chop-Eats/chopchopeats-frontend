import 'package:chop_user/src/features/order/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class OrderCard extends StatelessWidget {
  final AppTradeOrderPageRespVO order;
  final VoidCallback? onTap;
  final VoidCallback? onPay;
  final VoidCallback? onCancel;
  final VoidCallback? onRefund;
  final VoidCallback? onReview;
  final VoidCallback? onDelete;
  final VoidCallback? onReorder;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.onPay,
    this.onCancel,
    this.onRefund,
    this.onReview,
    this.onDelete,
    this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 16.h),
            _buildContent(),
            SizedBox(height: 16.h),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              order.shopName ?? '',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Icon(Icons.chevron_right, size: 20.sp, color: Colors.grey),
          ],
        ),
        Text(
          order.statusName ?? '',
          style: TextStyle(
            fontSize: 14.sp,
            color: _getStatusColor(order.status),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(int? status) {
    // 100=待支付
    if (status == 100) return const Color(0xFFFF5722);
    // 300=已完成
    if (status == 300) return Colors.grey;
    // 4xx=Cancel/Refund
    if (status != null && status >= 400) return Colors.grey;
    // Others (In Progress)
    return Colors.black;
  }

  Widget _buildContent() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 60.w,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: (order.items?.length ?? 0) > 3 ? 3 : (order.items?.length ?? 0),
              separatorBuilder: (context, index) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                // We don't have image URL in OrderItemPageRespVO?
                // Wait, the API response example shows items, but OrderItemPageRespVO doesn't have 'image'.
                // Let me check the API response example again.
                // The example items have: productId, productName, quantity, price, selectedSkus.
                // No image URL?
                // That's a problem. The UI shows images.
                // Maybe I need to fetch product details? Or maybe the API *does* return it but it's not in the doc?
                // I'll assume there might be a 'picUrl' or 'image' field and add it to the model if I see it in the real response.
                // For now, I'll use a placeholder or check if I missed it.
                // Checking the API doc again... "items": [ ... ]. No image field listed.
                // This is common in some APIs, they expect you to have the image from product ID or it's missing in doc.
                // I will use a placeholder icon for now.
                return Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: const Icon(Icons.fastfood, color: Colors.grey),
                );
              },
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${order.payAmount?.toStringAsFixed(2) ?? '0.00'}',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '共${order.totalQuantity ?? 0}件',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // "..." button (More)
        if (_hasMoreOptions())
          Container(
            margin: EdgeInsets.only(right: 8.w),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(Icons.more_horiz, size: 16.sp, color: Colors.black),
          ),
        
        ..._buildActionButtons(),
      ],
    );
  }

  bool _hasMoreOptions() {
    // Logic for "..." button
    return true; // Simplified
  }

  List<Widget> _buildActionButtons() {
    List<Widget> buttons = [];
    final status = order.status;

    // 100=待支付
    if (status == 100) {
      buttons.add(_buildButton("立即支付", Colors.white, const Color(0xFFFF5722), onPay, isPrimary: true));
    }
    // 200-260=进行中
    else if (status != null && status >= 200 && status < 300) {
      buttons.add(_buildButton("申请退款", Colors.white, Colors.black, onRefund));
    }
    // 300=已完成
    else if (status == 300) {
      buttons.add(_buildButton("申请退款", Colors.white, Colors.black, onRefund));
      buttons.add(SizedBox(width: 8.w));
      buttons.add(_buildButton("写评价", Colors.white, Colors.black, onReview));
    }
    // 4xx=Cancel/Refund
    else if (status == 901 || status == 902) { // Cancelled
      buttons.add(_buildButton("重新下单", Colors.white, Colors.black, onReorder));
    }
    else if (status == 440) { // Refunded
      buttons.add(_buildButton("删除订单", Colors.white, Colors.black, onDelete));
    }

    return buttons;
  }

  Widget _buildButton(String text, Color bgColor, Color textColor, VoidCallback? onPressed, {bool isPrimary = false}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: bgColor,
        border: Border.all(color: isPrimary ? textColor : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
