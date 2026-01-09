import 'package:chop_user/src/core/l10n/app_localizations.dart';
import 'package:chop_user/src/core/widgets/common_image.dart';
import 'package:chop_user/src/features/order/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:chop_user/src/features/order/pages/cancel_order_page.dart';
import 'package:chop_user/src/features/comment/pages/write_review_page.dart';

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
  // ... (existing code)
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
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Builder(
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.getLocalizedShopName(context),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              order.getLocalizedCategoryName(context),
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
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
              itemCount:
                  (order.items?.length ?? 0) > 3
                      ? 3
                      : (order.items?.length ?? 0),
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
                      imagePath:
                          item.imageThumbnail ??
                          'assets/images/restaurant1.png',
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
        Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Column(
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
                  l10n.orderTotalQuantity(order.totalQuantity ?? 0),
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            itemBuilder:
                (context) => [
                  if (order.status == 100) // Pending Payment
                    PopupMenuItem(
                      value: 'cancel',
                      onTap: () {
                        // Use Future.delayed to wait for popup to close before navigating
                        Future.delayed(const Duration(milliseconds: 100), () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => CancelOrderPage(
                                    orderNo: order.orderNo ?? '',
                                    onSuccess: () {
                                      onCancel?.call();
                                    },
                                  ),
                            ),
                          );
                        });
                      },
                      height: 32.h,
                      child: Center(
                        child: Text(
                          l10n.orderCancelOrder,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ),
                  // Add other options if needed
                ],
            onSelected: (value) {
              // Handled in onTap for specific items if needed, or here
            },
          ),
        const Spacer(),
        ..._buildActionButtons(context),
      ],
    );
  }

  bool _hasMoreOptions() {
    // Show for Pending Payment (100) and Completed (300) as per image
    return order.status == 100;
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    List<Widget> buttons = [];
    final status = order.status;

    // 100=待支付
    if (status == 100) {
      buttons.add(
        _buildButton(
          l10n.orderPayNow,
          Colors.white,
          const Color(0xFFFF5722),
          onPay,
          isPrimary: true,
        ),
      );
    }
    // 200-260=进行中
    else if (status != null && status >= 200 && status < 300) {
      buttons.add(
        _buildButton(
          l10n.orderRequestRefund,
          Colors.white,
          Colors.black,
          onRefund,
        ),
      );
    }
    // 300=已完成
    else if (status == 300) {
      buttons.add(
        _buildButton(
          l10n.orderRequestRefund,
          Colors.white,
          Colors.black,
          onRefund,
        ),
      );
      buttons.add(SizedBox(width: 8.w));
      // Check if already commented
      final isCommented = order.commentMark ?? false;
      buttons.add(
        _buildButton(
          l10n.orderWriteReview,
          Colors.white,
          isCommented ? Colors.grey : Colors.black,
          isCommented
              ? null
              : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WriteReviewPage(order: order),
                  ),
                ).then((value) {
                  if (value == true) {
                    onReview?.call();
                  }
                });
              },
          isCommented: isCommented,
        ),
      );
    }
    // 901, 902=Cancelled
    else if (status == 901 || status == 902) {
      buttons.add(
        _buildButton(l10n.orderReorder, Colors.white, Colors.black, onReorder),
      );
    }
    // 440=Refunded
    else if (status == 440) {
      buttons.add(
        _buildButton(
          l10n.orderDeleteOrder,
          Colors.white,
          Colors.black,
          onDelete,
        ),
      );
    }

    return buttons;
  }

  Widget _buildButton(
    String text,
    Color bgColor,
    Color textColor,
    VoidCallback? onPressed, {
    bool isPrimary = false,
    bool isCommented = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isCommented ? Colors.grey[200] : bgColor,
          border: Border.all(
            color: isPrimary
                ? textColor
                : (isCommented ? Colors.grey[300]! : const Color(0xFFE0E0E0)),
          ),
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
