import 'package:chop_user/src/core/widgets/common_image.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          order.shopName ?? '',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '${order.categoryName ?? ''} • ${order.englishCategoryName ?? ''}',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
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
                final item = order.items![index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    width: 60.w,
                    height: 60.w,
                    color: Colors.grey[100],
                    child: CommonImage(
                      imagePath: item.picUrl ?? '',
                      width: 60.w,
                      height: 60.w,
                      fit: BoxFit.cover,
                    ),
                  ),
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
                fontSize: 16.sp,
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
      children: [
        if (_hasMoreOptions())
          PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz, size: 20.sp, color: Colors.grey),
            color: const Color(0xFF333333),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            offset: const Offset(0, -40), // Adjust position to appear above
            itemBuilder: (context) => [
              if (order.status == 100) // Pending Payment
                PopupMenuItem(
                  value: 'cancel',
                  height: 32.h,
                  child: Center(
                    child: Text(
                      '取消订单',
                      style: TextStyle(color: Colors.white, fontSize: 12.sp),
                    ),
                  ),
                ),
              // Add other options if needed
            ],
            onSelected: (value) {
              if (value == 'cancel') {
                onCancel?.call();
              }
            },
          ),
        const Spacer(),
        ..._buildActionButtons(),
      ],
    );
  }

  bool _hasMoreOptions() {
    // Show for Pending Payment (100) and Completed (300) as per image
    return order.status == 100 || order.status == 300;
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
    // 901, 902=Cancelled
    else if (status == 901 || status == 902) {
      buttons.add(_buildButton("重新下单", Colors.white, Colors.black, onReorder));
    }
    // 440=Refunded
    else if (status == 440) {
      buttons.add(_buildButton("删除订单", Colors.white, Colors.black, onDelete));
    }

    return buttons;
  }

  Widget _buildButton(String text, Color bgColor, Color textColor, VoidCallback? onPressed, {bool isPrimary = false}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: isPrimary ? textColor : const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
