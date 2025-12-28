import 'package:chop_user/src/features/order/models/order_model.dart';
import 'package:chop_user/src/features/order/providers/order_provider.dart';
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
        title: const Text("订单详情", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
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
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusHeader(order),
          SizedBox(height: 16.h),
          _buildAddressCard(order),
          SizedBox(height: 16.h),
          _buildShopCard(order),
          SizedBox(height: 16.h),
          _buildItemsCard(order),
          SizedBox(height: 16.h),
          _buildPriceCard(order),
          SizedBox(height: 16.h),
          _buildOrderInfoCard(order),
          SizedBox(height: 80.h), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildStatusHeader(AppTradeOrderDetailRespVO order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          order.statusName ?? '',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        if (order.status == 100) ...[
          SizedBox(height: 4.h),
          Text(
            "29分33秒 后失效", // Mock countdown, in real app use timer
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFFFF5722),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAddressCard(AppTradeOrderDetailRespVO order) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("配送地址", style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, size: 24.sp, color: Colors.black),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${order.address ?? ''}, ${order.state ?? ''}",
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "${order.nickname ?? ''} ${order.contactPhone ?? ''}",
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShopCard(AppTradeOrderDetailRespVO order) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("下单私厨", style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
          SizedBox(height: 12.h),
          Row(
            children: [
              Text(
                order.shopName ?? '',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            "距离${order.distance ?? 0}km | 计划 ${order.deliveryTime ?? ''} 开始配送",
            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(AppTradeOrderDetailRespVO order) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("餐品详情", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items?.length ?? 0,
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              final item = order.items![index];
              return Row(
                children: [
                  Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: const Icon(Icons.fastfood, color: Colors.grey),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.productName ?? '',
                                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (item.hotMark == true)
                              Container(
                                margin: EdgeInsets.only(left: 4.w),
                                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text("HOT", style: TextStyle(fontSize: 10.sp, color: Colors.white)),
                              ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "x${item.quantity}",
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "\$${item.price?.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(AppTradeOrderDetailRespVO order) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          _buildPriceRow("餐品小计", order.mealSubtotal),
          _buildPriceRow("税费&服务费", (order.taxAmount ?? 0) + (order.serviceFee ?? 0)),
          _buildPriceRow("配送费", order.deliveryFee),
          _buildPriceRow("优惠券抵扣", -(order.couponAmount ?? 0), isDiscount: true),
          Divider(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("本单你需支付", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
              Text(
                "\$${order.payAmount?.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
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
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("订单信息", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 12.h),
          _buildInfoRow("订单编号", order.orderNo),
          _buildInfoRow("下单时间", order.createTime),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
          Row(
            children: [
              Text(value ?? '', style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
              if (label == "订单编号")
                Padding(
                  padding: EdgeInsets.only(left: 4.w),
                  child: Text("复制", style: TextStyle(fontSize: 10.sp, color: Colors.grey, decoration: TextDecoration.underline)),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // More options
            Icon(Icons.more_horiz, color: Colors.grey),
            
            Row(
              children: [
                if (order.status == 100) ...[
                  _buildActionButton("取消订单", Colors.black, Colors.white, () {}),
                  SizedBox(width: 12.w),
                  _buildActionButton("立即支付", Colors.white, const Color(0xFFFF5722), () {}, isPrimary: true),
                ],
                // Add other status buttons as needed
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, Color textColor, Color bgColor, VoidCallback onPressed, {bool isPrimary = false}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24.r),
          border: isPrimary ? null : Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
