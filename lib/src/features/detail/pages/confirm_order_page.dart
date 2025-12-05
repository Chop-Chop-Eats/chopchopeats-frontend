import 'package:chop_user/src/core/widgets/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_button.dart';
import '../../../core/widgets/common_image.dart';
import '../../../core/widgets/common_spacing.dart';
import '../../home/models/home_models.dart';
import '../providers/cart_notifier.dart';
import '../providers/detail_provider.dart';
import '../widgets/bottom_arc_container.dart';
import '../widgets/cart_item_list.dart';

/// 选中的配送时间 Provider
final selectedDeliveryTimeProvider = StateProvider.family<OperatingHour?, String>((ref, shopId) {
  return null;
});

class ConfirmOrderPage extends ConsumerStatefulWidget {
  const ConfirmOrderPage({super.key, required this.shopId});

  final String shopId;

  @override
  ConsumerState<ConfirmOrderPage> createState() => _ConfirmOrderPageState();
}

class _ConfirmOrderPageState extends ConsumerState<ConfirmOrderPage> {
  final TextStyle titleText = TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black);
  final TextStyle textStyle = TextStyle(fontSize: 12.sp, color: Colors.grey[600]);
  final TextStyle valueText = TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.w600);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          _buildOrderMain(),
       
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom,
            left: 0,
            right: 0,
            child: _buildApplyContainer(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderMain(){
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        CommonAppBar(title: l10n.confirmOrder, backgroundColor: Colors.transparent,),
        Expanded(child: _buildOrderInfo()),
        
      ],
    );
  }


  Widget _buildOrderInfo(){
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24.r), topRight: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 24.h, bottom:80.h + MediaQuery.of(context).padding.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAddress(), // 地址
            _buildPrivateChef(), // 私厨
            _buildMealDetail(), // 餐品详情
            _buildDeliveryTip(), // 配送小费
            _buildOrderAmount(), // 订单金额区域
            _buildPaymentMethod(), // 支付方式
            _buildRemark(), // 备注
          ],
        ),
      ),
    );
  }

  Widget _buildCapsuleButton({
    required String title,
    required VoidCallback onTap,
    required String imagePath,
  }){
    return GestureDetector(
      onTap: onTap, 
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12.r,
              offset: Offset(0, 6.h),
            ),
          ]
        ),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CommonImage(imagePath: imagePath, width: 24.w, height: 24.h),
                CommonSpacing.width(8.w),
                Text(title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.black)),
              ],
            ),
            Icon(Icons.arrow_forward_ios, size: 16.w, color: Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _buildAddress(){
    final l10n = AppLocalizations.of(context)!;
    return _buildCapsuleButton(
      title: l10n.confirmOrderAddress, 
      onTap: () {
        Logger.info('ConfirmOrderPage', '点击地址');
      }, 
      imagePath: "assets/images/location_b.png",
    );
  }

  Widget _buildPrivateChef(){
    final l10n = AppLocalizations.of(context)!;
    final shop = ref.watch(shopDetailProvider(widget.shopId));
    final selectedDeliveryTime = ref.watch(selectedDeliveryTimeProvider(widget.shopId));
    
    // 如果没有店铺数据，显示占位
    if (shop == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonSpacing.standard,
          Text(l10n.confirmOrderPrivateChef, style: titleText),
          CommonSpacing.medium,
          Text("加载中...", style: textStyle),
        ],
      );
    }

    // 处理配送时间
    final operatingHours = shop.operatingHours ?? [];
    Logger.info('ConfirmOrderPage', 'operatingHours: $operatingHours');
    OperatingHour? displayDeliveryTime;
    if (selectedDeliveryTime != null) {
      displayDeliveryTime = selectedDeliveryTime;
    } else if (operatingHours.isNotEmpty) {
      // 如果没有选中，默认选择第一个
      displayDeliveryTime = operatingHours.first;
      // 初始化选中状态
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedDeliveryTimeProvider(widget.shopId).notifier).state = displayDeliveryTime;
      });
    }

    // 格式化距离
    final distanceText = shop.distance != null 
        ? "${shop.distance!.toStringAsFixed(1)}km" 
        : "";

    // 格式化配送时间
    final deliveryTimeText = displayDeliveryTime?.time ?? "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonSpacing.standard,
        Text(l10n.confirmOrderPrivateChef, style: titleText),
        CommonSpacing.medium,
        Text(shop.localizedShopName, style: titleText.copyWith(fontSize: 14.sp)),
        CommonSpacing.height(4.h),
        Row(
          children: [
            if (distanceText.isNotEmpty) ...[
              Text("${l10n.confirmOrderDistance}$distanceText", style: textStyle),
              Icon(Icons.directions_car_outlined, size: 24.w, color: Colors.black),
            ],
            if (deliveryTimeText.isNotEmpty) ...[
              Text(l10n.confirmOrderPlan, style: textStyle),
              Text("$deliveryTimeText ", style: textStyle.copyWith(color: AppTheme.primaryOrange)),
              Text(l10n.confirmOrderStartDelivery, style: textStyle),
            ],
          ],
        ),
        // 如果有多个配送时间选项，显示选择器
        if (operatingHours.length > 1) ...[
          CommonSpacing.small,
          Text(l10n.confirmOrderDeliveryTime, style: textStyle),
          CommonSpacing.small,
          _buildDeliveryTimeSelector(operatingHours),
        ],
      ],
    );
  }

  Widget _buildDeliveryTimeSelector(List<OperatingHour> operatingHours) {
    final selectedDeliveryTime = ref.watch(selectedDeliveryTimeProvider(widget.shopId));
    
    return Row(
      children: operatingHours.map((hour) {
        final isSelected = selectedDeliveryTime?.time == hour.time;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              ref.read(selectedDeliveryTimeProvider(widget.shopId).notifier).state = hour;
            },
            child: _buildDeliverItem(
              title: hour.time ?? "",
              isSelected: isSelected,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMealDetail(){
    final l10n = AppLocalizations.of(context)!;
    final cartState = ref.watch(cartStateProvider(widget.shopId));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CommonSpacing.standard,
        Text(l10n.confirmOrderMealDetail, style: titleText),
        CommonSpacing.medium,
        if (cartState.items.isEmpty)
          Text("购物车为空", style: textStyle)
        else
          
          CartItemList(
              shopId: widget.shopId,
              items: cartState.items,
              diningDate: cartState.diningDate,
            ),
          
        
      ],
    );
  }

  Widget _buildDeliveryTip(){
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonSpacing.standard,
        Text(l10n.confirmOrderDeliveryTip, style: titleText),
        CommonSpacing.medium,
        Text(l10n.confirmOrderDeliveryFeeTip, style: textStyle),
        CommonSpacing.small,
        Row(
          children: [
            Expanded(
              child: _buildDeliverItem(title: "10%", isSelected: true),
            ),  
            Expanded(
              child: _buildDeliverItem(title: "12%", isSelected: false),
            ),
            Expanded(
              child: _buildDeliverItem(title: "15%", isSelected: false),
            ),
            Expanded(
              child: _buildDeliverItem(title: "20%", isSelected: false),
            ),
          ],
        )
      ],
    );
  }
  
  Widget _buildDeliverItem({
    required String title,
    required bool isSelected,
  }){
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryOrange : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.symmetric(vertical: 6.h),
      alignment: Alignment.center,
      margin: EdgeInsets.only(right: 4.h),
      child: Text(title, style: TextStyle(fontSize: 12.sp, color: isSelected ? Colors.white : Colors.black)),
    );
  }


  Widget _buildOrderAmount(){
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonSpacing.standard,
        Text(l10n.confirmOrderOrderAmount, style: titleText),
        CommonSpacing.medium,
        _buildOrderAmountItem(title: l10n.confirmOrderMealSubtotal, value: "\$100.00"), // 餐品小记
        _buildOrderAmountItem(title: l10n.confirmOrderDeliveryFee, value: "\$10.00"), // 配送费
        _buildOrderAmountItem(title: l10n.confirmOrderTaxAndServiceFee, value: "\$8.17"), // 税费&服务费
        _buildOrderAmountItem(title: l10n.confirmOrderCouponDiscount, value: "-\$10.00", couponUsed: true), // 优惠券折扣

        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
          ),
          height: 0.5.h,
          margin: EdgeInsets.symmetric(vertical: 10.h),
        ),
        SizedBox(
          width: double.infinity,
          child: Text("${l10n.confirmOrderTotal}: \$128.17", style: titleText ,textAlign: TextAlign.end,),
        ),
      ],
    );
  }

  Widget _buildOrderAmountItem({
    required String title,
    required String value,
    bool? couponUsed = false,
    VoidCallback? onTap,
  }){
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: textStyle),
            Text(value, style: valueText.copyWith(color: couponUsed != null && couponUsed ? AppTheme.primaryOrange : Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(){
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonSpacing.standard,
        Text(l10n.confirmOrderPaymentMethod, style: titleText),
        CommonSpacing.medium,
        _buildCapsuleButton(
          title: l10n.confirmOrderSelectPaymentMethod, 
          onTap: () {}, 
          imagePath: "assets/images/wallet.png",
        ),
         CommonSpacing.standard,
      ],
    );
  }

  // 最多三行的文本域
  Widget _buildRemark(){
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF2F3F5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      // 文本框 去除下边的横线
      child: TextField(
        cursorColor: Colors.black,
        decoration: InputDecoration(
          hintText: l10n.confirmOrderRemark,
          border: InputBorder.none,
        ),
        style: textStyle,
        maxLines: 3,
      ),
    );
  }


  Widget _buildApplyContainer() {
    final l10n = AppLocalizations.of(context)!;
    return BottomArcContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 价格区域
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    // 现价
                    TextSpan(
                      text: "\$100.00",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryOrange,
                      ),
                    ),
                    TextSpan(text: "  "),
                    // 原价
                    TextSpan(
                      text: "\$120.00",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF86909C),
                        decoration: TextDecoration.lineThrough,
                        decorationColor: Color(0xFF86909C),
                        decorationThickness: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Text( l10n.confirmOrderSettlementTip("\$8.17"), style: TextStyle(fontSize: 12.sp, color: Color(0xFF86909C))),
            ],
          ),
          // 按钮区域
          CommonButton(
            text: l10n.confirmOrderSettlement,
            padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 12.h),
            onPressed: () {}
          ),
        ],
      ),
    );
  }
}


