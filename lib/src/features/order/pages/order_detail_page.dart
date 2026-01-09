import 'dart:async';

import 'package:chop_user/src/core/l10n/app_localizations.dart';
import 'package:chop_user/src/features/order/models/order_model.dart';
import 'package:chop_user/src/features/order/providers/order_provider.dart';
import 'package:chop_user/src/features/order/utils/order_payment_handler.dart';
import 'package:chop_user/src/core/widgets/common_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'cancel_order_page.dart';
import '../../detail/pages/detail_page.dart';
import '../../../core/utils/logger/logger.dart';

class OrderDetailPage extends ConsumerWidget {
  final String orderNo;

  const OrderDetailPage({super.key, required this.orderNo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderNo));

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: orderAsync.when(
        data: (order) => _buildBody(context, order, ref),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      bottomNavigationBar:
          orderAsync.hasValue
              ? _buildBottomBar(context, orderAsync.value!, ref)
              : null,
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppTradeOrderDetailRespVO order,
    WidgetRef ref,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      // padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusHeader(context, order, ref),
          SizedBox(height: 24.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white60,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(l10n.orderDeliveryAddress),
                  SizedBox(height: 12.h),
                  _buildAddressCard(order),
                  SizedBox(height: 24.h),
                  _buildSectionTitle(l10n.orderChef),
                  SizedBox(height: 12.h),
                  _buildShopCard(order),
                  SizedBox(height: 24.h),
                  _buildSectionTitle(l10n.orderOrderDetails),
                  SizedBox(height: 12.h),
                  _buildItemsAndPriceCard(order),
                  SizedBox(height: 24.h),

                  _buildPriceRow(l10n.orderSubtotal, order.mealSubtotal),
                  _buildPriceRow(
                    l10n.orderTaxAndServiceFee,
                    (order.taxAmount ?? 0) + (order.serviceFee ?? 0),
                  ),
                  _buildPriceRow(l10n.orderDeliveryFee, order.deliveryFee),
                  _buildPriceRow(
                    l10n.orderCouponDiscount,
                    -(order.couponAmount ?? 0),
                    isDiscount: true,
                  ),
                  SizedBox(height: 12.h),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            l10n.orderActualPayment,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: const Color(0xFF333333),
                            ),
                          ),
                          if ((order.deliveryTip ?? 0) > 0)
                            Text(
                              l10n.orderActualPaymentWithTip(
                                order.deliveryTip?.toStringAsFixed(2) ?? '0',
                              ),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFF999999),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        "\$${order.payAmount?.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  _buildSectionTitle(l10n.orderOrderInfo),
                  SizedBox(height: 12.h),
                  _buildOrderInfoCard(order),
                  SizedBox(height: 80.h),
                ],
              ),
            ),
          ), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF333333),
      ),
    );
  }

  Widget _buildStatusHeader(
    BuildContext context,
    AppTradeOrderDetailRespVO order,
    WidgetRef ref,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.getLocalizedStatusName(context),
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF333333),
            ),
          ),
          SizedBox(height: 8.h),
          if (order.status == 100 &&
              order.createTime != null &&
              order.orderPeriod != null) ...[
            _OrderCountdown(
              createTime: order.createTime!,
              orderPeriod: order.orderPeriod!,
              onExpired: () {
                ref.invalidate(orderDetailProvider(orderNo));
              },
            ),
          ] else
            Text(
              order.getLocalizedStatusDesc(context).isNotEmpty
                  ? order.getLocalizedStatusDesc(context)
                  : l10n.orderStatusDescDefault,
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF999999)),
            ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(AppTradeOrderDetailRespVO order) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.location_on, size: 28.sp, color: Colors.black),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.deliveryAddress ??
                      "${order.address ?? ''} ${order.detailAddress ?? ''}"
                          .trim(),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  "${order.nickname ?? ''} ${order.contactPhone ?? ''}",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopCard(AppTradeOrderDetailRespVO order) {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.getLocalizedShopName(context),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333),
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Text(
                    l10n.orderDistance(order.distance ?? 0),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF999999),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.delivery_dining,
                    size: 14.sp,
                    color: const Color(0xFF999999),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    l10n.orderDeliveryTime(order.deliveryTime ?? ''),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemsAndPriceCard(AppTradeOrderDetailRespVO order) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items?.length ?? 0,
            separatorBuilder: (context, index) => SizedBox(height: 24.h),
            itemBuilder: (context, index) {
              final item = order.items![index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64.w,
                    height: 64.w,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child:
                        (item.imageThumbnail != null &&
                                item.imageThumbnail!.isNotEmpty)
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: CommonImage(
                                imagePath: item.imageThumbnail!,
                                width: 64.w,
                                height: 64.w,
                                fit: BoxFit.cover,
                              ),
                            )
                            : const Icon(Icons.fastfood, color: Colors.grey),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.getLocalizedProductName(context),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF333333),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (item.hotMark == true)
                              Container(
                                margin: EdgeInsets.only(left: 6.w),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF5722),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  "HOT",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (item.newMark == true)
                              Container(
                                margin: EdgeInsets.only(left: 6.w),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFB800),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  "NEW",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        // Display selected SKUs if available
                        if (item.selectedSkus != null &&
                            item.selectedSkus!.isNotEmpty)
                          Text(
                            item.selectedSkus!
                                .map((sku) => sku.getLocalizedSkuName(context))
                                .where((name) => name.isNotEmpty)
                                .join(', '),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF999999),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "x${item.quantity}",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF999999),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "\$${item.price?.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double? amount, {
    bool isDiscount = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
          Text(
            "${isDiscount ? '-' : ''}\$${(amount ?? 0).abs().toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 14.sp,
              color: isDiscount ? const Color(0xFFFF5722) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard(AppTradeOrderDetailRespVO order) {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(l10n.orderOrderNo, order.orderNo),
              _buildInfoRow(l10n.orderOrderTime, order.createTime),
              if (order.stripePaymentMethodInfo != null)
                _buildInfoRow(
                  l10n.orderPaymentMethod,
                  "${order.stripePaymentMethodInfo!.cardBrand?.toUpperCase() ?? 'Card'} *${order.stripePaymentMethodInfo!.cardLast4 ?? ''}",
                  isPayment: true,
                  cardBrand: order.stripePaymentMethodInfo!.cardBrand,
                )
              else if (order.payTypeName != null)
                _buildInfoRow(l10n.orderPaymentMethod, order.payTypeName),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(
    String label,
    String? value, {
    bool isPayment = false,
    String? cardBrand,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.w, top: 6.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF999999)),
          ),
          Row(
            children: [
              if (isPayment && cardBrand != null) ...[
                // Simple text for card brand, replace with icon if available
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1F71), // Visa blue-ish
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    cardBrand.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
              ],
              Text(
                value ?? '',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF333333),
                ),
              ),
              if (label == "订单编号")
                Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFDDDDDD)),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      "复制",
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    AppTradeOrderDetailRespVO order,
    WidgetRef ref,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(child: _buildBottomContent(context, order, ref)),
    );
  }

  Widget _buildBottomContent(
    BuildContext context,
    AppTradeOrderDetailRespVO order,
    WidgetRef ref,
  ) {
    final l10n = AppLocalizations.of(context)!;
    // Status Group 1: Pending Payment
    if (order.statusGroup == 1 || order.status == 100) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMoreOptions(context, order, ref),
          _buildActionButton(
            l10n.orderPayNow,
            Colors.white,
            const Color(0xFFFF5722),
            () {
              OrderPaymentHandler.processPayment(
                orderNo: order.orderNo ?? '',
                onSuccess: () {
                  ref.invalidate(orderDetailProvider(orderNo));
                },
                onError: (error) {
                  // Error already handled by OrderPaymentHandler
                },
              );
            },
            isPrimary: true,
          ),
        ],
      );
    }

    // Status Group 2: In Progress
    if (order.statusGroup == 2 ||
        (order.status != null && order.status! > 100 && order.status! < 175)) {
      return _buildFullWidthButton(
        l10n.orderRequestRefund,
        const Color(0xFF333333),
        Colors.white,
        () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CancelOrderPage(
                    orderNo: order.orderNo ?? '',
                    isRefund: true,
                    onSuccess: () {
                      ref.invalidate(orderDetailProvider(orderNo));
                    },
                  ),
            ),
          );
        },
        hasBorder: true,
      );
    }

    // Status Group 3: Completed
    if (order.statusGroup == 3 || order.status == 175) {
      final hasCommented = order.commentMark == true;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMoreOptions(context, order, ref),
          _buildActionButton(
            l10n.orderWriteReview,
            hasCommented ? const Color(0xFF999999) : Colors.white,
            hasCommented ? const Color(0xFFE0E0E0) : const Color(0xFFFF5722),
            hasCommented ? null : () {
              // Review action
            },
            isPrimary: true,
            isDisabled: hasCommented,
          ),
        ],
      );
    }

    // Status Group 4: Cancelled or Refunded
    if (order.statusGroup == 4 || order.status == 180) {
      // If status is 180, it is explicitly Cancelled -> Delete Order
      if (order.status == 180) {
        return _buildFullWidthButton(
          l10n.orderDeleteOrder,
          Colors.red,
          Colors.white,
          () {
            // Delete action
          },
          hasBorder: true,
        );
      }

      // Otherwise, assume Refunded -> Reorder
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMoreOptions(context, order, ref),
          _buildActionButton(
            l10n.orderReorder,
            const Color(0xFF333333),
            Colors.white,
            () => _handleReorder(context, order, ref),
            isPrimary: false,
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildMoreOptions(
    BuildContext context,
    AppTradeOrderDetailRespVO order,
    WidgetRef ref,
  ) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz, color: Colors.grey, size: 24.sp),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      onSelected: (value) {
        if (value == 'cancel') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CancelOrderPage(
                    orderNo: order.orderNo ?? '',
                    onSuccess: () {
                      ref.invalidate(orderDetailProvider(orderNo));
                    },
                  ),
            ),
          );
        }
      },
      itemBuilder: (BuildContext context) {
        final l10n = AppLocalizations.of(context)!;
        final List<PopupMenuItem<String>> items = [];
        // Only show Cancel Order for Pending Payment
        if (order.statusGroup == 1 || order.status == 100) {
          items.add(
            PopupMenuItem<String>(
              value: 'cancel',
              child: Text(
                l10n.orderCancelOrder,
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          );
        }
        // Add other options if needed for other statuses
        return items;
      },
    );
  }

  Widget _buildActionButton(
    String text,
    Color textColor,
    Color bgColor,
    VoidCallback? onPressed, {
    bool isPrimary = false,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24.r),
          border: isPrimary ? null : Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.sp,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFullWidthButton(
    String text,
    Color textColor,
    Color bgColor,
    VoidCallback onPressed, {
    bool hasBorder = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 54.w,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(30.r),
          border: hasBorder ? Border.all(color: const Color(0xFFE0E0E0)) : null,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.sp,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 处理重新下单逻辑
  Future<void> _handleReorder(
    BuildContext context,
    AppTradeOrderDetailRespVO order,
    WidgetRef ref,
  ) async {
    if (order.shopId == null || order.shopId!.isEmpty) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('提示'),
              content: const Text('无法获取店铺信息'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('确定'),
                ),
              ],
            ),
      );
      return;
    }

    Logger.info('OrderDetailPage', '重新下单: 跳转到店铺详情页 shopId=${order.shopId}');

    if (!context.mounted) return;

    // 直接导航到店铺详情页，让用户重新选择商品
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailPage(id: order.shopId!)),
    );
  }
}

class _OrderCountdown extends StatefulWidget {
  final String createTime;
  final int orderPeriod;
  final VoidCallback onExpired;

  const _OrderCountdown({
    required this.createTime,
    required this.orderPeriod,
    required this.onExpired,
  });

  @override
  State<_OrderCountdown> createState() => _OrderCountdownState();
}

class _OrderCountdownState extends State<_OrderCountdown> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateRemaining();
    });
  }

  void _calculateRemaining() {
    DateTime? create;

    // 1. Try parsing as milliseconds timestamp (e.g. "1767425203000")
    final timestamp = int.tryParse(widget.createTime);
    if (timestamp != null) {
      create = DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else {
      // 2. Try parsing as ISO-8601 string
      // If the time string doesn't have timezone info (no 'Z' or offset),
      // we assume it is UTC to avoid timezone offset issues (e.g. server sending UTC but parsed as local).
      if (!widget.createTime.endsWith('Z') &&
          !widget.createTime.contains('+')) {
        create = DateTime.tryParse("${widget.createTime}Z")?.toLocal();
      } else {
        create = DateTime.tryParse(widget.createTime);
      }
    }

    if (create == null) return;

    // User confirmed: if orderPeriod is 30, it means 30 minutes.
    // We strictly treat it as minutes.
    final duration = Duration(minutes: widget.orderPeriod);

    final end = create.add(duration);
    final now = DateTime.now();
    final diff = end.difference(now);

    if (diff.isNegative) {
      _timer.cancel();
      if (_remaining != Duration.zero) {
        widget.onExpired();
      }
      setState(() {
        _remaining = Duration.zero;
      });
    } else {
      setState(() {
        _remaining = diff;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final minutes = _remaining.inMinutes;
    final seconds = _remaining.inSeconds % 60;
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: l10n.orderCountdownTime(minutes, seconds),
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFFFF5722),
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: l10n.orderCountdownSuffix,
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF333333)),
          ),
        ],
      ),
    );
  }
}
