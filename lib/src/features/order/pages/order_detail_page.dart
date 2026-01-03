import 'package:chop_user/src/features/order/models/order_model.dart';
import 'package:chop_user/src/features/order/providers/order_provider.dart';
import 'package:chop_user/src/core/widgets/common_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';



class OrderDetailPage extends ConsumerWidget {
  final String orderNo;

  const OrderDetailPage({super.key, required this.orderNo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderNo));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: orderAsync.when(
        data: (order) => _buildBody(context, order),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      bottomNavigationBar: orderAsync.hasValue ? _buildBottomBar(context, orderAsync.value!) : null,
    );
  }

  Widget _buildBody(BuildContext context, AppTradeOrderDetailRespVO order) {
    return SingleChildScrollView(
      // padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusHeader(order),
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
                  _buildSectionTitle("配送地址"),
                  SizedBox(height: 12.h),
                  _buildAddressCard(order),
                  SizedBox(height: 24.h),
                  _buildSectionTitle("下单私厨"),
                  SizedBox(height: 12.h),
                  _buildShopCard(order),
                  SizedBox(height: 24.h),
                  _buildSectionTitle("餐品详情"),
                  SizedBox(height: 12.h),
                  _buildItemsAndPriceCard(order),
                  SizedBox(height: 24.h),
                  _buildSectionTitle("订单信息"),
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

  Widget _buildStatusHeader(AppTradeOrderDetailRespVO order) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.statusName ?? '',
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF333333),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            order.statusDesc ?? '私厨已接单，待骑手接单',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF999999),
            ),
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
                  order.deliveryAddress ?? "${order.address ?? ''} ${order.detailAddress ?? ''}".trim(),
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF333333)),
                ),
                SizedBox(height: 6.h),
                Text(
                  "${order.nickname ?? ''} ${order.contactPhone ?? ''}",
                  style: TextStyle(fontSize: 14.sp, color: const Color(0xFF999999)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopCard(AppTradeOrderDetailRespVO order) {
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
            order.shopName ?? '',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF333333)),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(
                "距离${order.distance ?? 0}km",
                style: TextStyle(fontSize: 12.sp, color: const Color(0xFF999999)),
              ),
              SizedBox(width: 8.w),
              Icon(Icons.delivery_dining, size: 14.sp, color: const Color(0xFF999999)),
              SizedBox(width: 4.w),
              Text(
                "计划 ${order.deliveryTime ?? ''} 开始配送",
                style: TextStyle(fontSize: 12.sp, color: const Color(0xFF999999)),
              ),
            ],
          ),
        ],
      ),
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
                    child: (item.imageThumbnail != null && item.imageThumbnail!.isNotEmpty)
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
                                item.productName ?? '',
                                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF333333)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (item.hotMark == true)
                              Container(
                                margin: EdgeInsets.only(left: 6.w),
                                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF5722),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text("HOT", style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            if (item.newMark == true)
                              Container(
                                margin: EdgeInsets.only(left: 6.w),
                                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFB800),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text("NEW", style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        // Mock options if not available, or use description if exists
                        Text(
                          "单人份, 不辣", // Placeholder as per image, replace with actual options if available
                          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF999999)),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "x${item.quantity}",
                        style: TextStyle(fontSize: 14.sp, color: const Color(0xFF999999)),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "\$${item.price?.toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF333333)),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 24.h),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          SizedBox(height: 16.h),
          _buildPriceRow("餐品小计", order.mealSubtotal),
          _buildPriceRow("税费&服务费", (order.taxAmount ?? 0) + (order.serviceFee ?? 0)),
          _buildPriceRow("配送费", order.deliveryFee),
          _buildPriceRow("优惠券抵扣", -(order.couponAmount ?? 0), isDiscount: true),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text("实付款", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF333333))),
                  if ((order.deliveryTip ?? 0) > 0)
                    Text(
                      "(含小费\$${order.deliveryTip?.toStringAsFixed(2)})",
                      style: TextStyle(fontSize: 12.sp, color: const Color(0xFF999999)),
                    ),
                ],
              ),
              Text(
                "\$${order.payAmount?.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: const Color(0xFF333333)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double? amount, {bool isDiscount = false}) {
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
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow("订单编号", order.orderNo),
          _buildInfoRow("下单时间", order.createTime),
          if (order.stripePaymentMethodInfo != null)
            _buildInfoRow(
              "支付方式",
              "${order.stripePaymentMethodInfo!.cardBrand?.toUpperCase() ?? 'Card'} *${order.stripePaymentMethodInfo!.cardLast4 ?? ''}",
              isPayment: true,
              cardBrand: order.stripePaymentMethodInfo!.cardBrand,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value, {bool isPayment = false, String? cardBrand}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14.sp, color: const Color(0xFF999999))),
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
                    style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 8.w),
              ],
              Text(value ?? '', style: TextStyle(fontSize: 14.sp, color: const Color(0xFF333333))),
              if (label == "订单编号")
                Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFDDDDDD)),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text("复制", style: TextStyle(fontSize: 10.sp, color: const Color(0xFF666666))),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, AppTradeOrderDetailRespVO order) {
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
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // If status allows refund (e.g. paid and not completed), show refund button
            // For now, mirroring the image which shows "申请退款"
            GestureDetector(
              onTap: () {
                // Handle refund request
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                alignment: Alignment.center,
                child: Text(
                  "申请退款",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF333333),
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


}
