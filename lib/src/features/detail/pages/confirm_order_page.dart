import 'package:chop_user/src/core/widgets/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/utils/pop/toast.dart';
import '../../../core/widgets/common_button.dart';
import '../../../core/widgets/common_spacing.dart';
import '../../home/models/home_models.dart';
import '../providers/cart_notifier.dart';
import '../providers/detail_provider.dart';
import '../providers/confirm_order_provider.dart';
import '../widgets/bottom_arc_container.dart';
import '../widgets/cart_item_list.dart';
import '../widgets/confirm_order_widgets.dart';
import '../../address/models/address_models.dart';
import '../../address/providers/address_provider.dart';
import '../models/order_model.dart';

class ConfirmOrderPage extends ConsumerStatefulWidget {
  const ConfirmOrderPage({super.key, required this.shopId});

  final String shopId;

  @override
  ConsumerState<ConfirmOrderPage> createState() => _ConfirmOrderPageState();
}

class _ConfirmOrderPageState extends ConsumerState<ConfirmOrderPage> {
  final TextEditingController remarkController = TextEditingController();
  final FocusNode remarkFocusNode = FocusNode();
  final TextEditingController customTipController = TextEditingController();
  final FocusNode customTipFocusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    // 初始化地址列表
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final addressState = ref.read(addressListProvider);
      if (addressState.addresses.isEmpty && !addressState.isLoading) {
        await ref.read(addressListProvider.notifier).loadAddresses();
      }
    });
    
    // 监听自定义小费输入框焦点变化
    customTipFocusNode.addListener(() {
      if (!customTipFocusNode.hasFocus) {
        // 失去焦点时，调用处理函数（数字键盘没有确定键，需要在失焦时处理）
        _handleCustomTipInput(customTipController.text);
      }
    });
  }

  @override
  void dispose() {
    remarkController.dispose();
    remarkFocusNode.dispose();
    customTipController.dispose();
    customTipFocusNode.dispose();
    super.dispose();
  }

  final TextStyle titleText = TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black);
  final TextStyle textStyle = TextStyle(fontSize: 12.sp, color: Colors.grey[600]);
  final TextStyle valueText = TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.w600);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 点击空白区域收起键盘
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        appBar: null,
        // resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            // 上半部分内容，使用 Expanded 占满剩余空间
            Expanded(
              child: _buildOrderMain(),
            ),
            _buildApplyContainer(),
          ],
        ),
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
      padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 24.h, bottom:24.h),
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

  Widget _buildAddress(){
    final l10n = AppLocalizations.of(context)!;
    final selectedAddress = ref.watch(selectedAddressProvider(widget.shopId));
    final addressText = selectedAddress != null
        ? _formatAddressForDisplay(selectedAddress)
        : l10n.confirmOrderAddress;
    
    return CapsuleButton(
      title: addressText, 
      onTap: () async {
        final result = await AddressSelectionSheet.show(
          context: context,
          ref: ref,
        );
        if (result != null) {
          ref.read(selectedAddressProvider(widget.shopId).notifier).state = result;
        }
      }, 
      imagePath: "assets/images/location_b.png",
    );
  }

  String _formatAddressForDisplay(AddressItem address) {
    // 第一行：姓名和电话
    final firstLine = [address.name, address.mobile].where((element) => element.isNotEmpty).join(' · ');
    
    // 第二行：地址信息
    final secondLineParts = [
      address.address,
      if (address.detailAddress?.isNotEmpty ?? false) address.detailAddress!,
      address.state,
    ].where((element) => element.isNotEmpty).toList();
    final secondLine = secondLineParts.join(' · ');
    
    return '$firstLine\n$secondLine';
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
            child: SelectableCapsuleItem(
              title: hour.time ?? "",
              isSelected: isSelected,
              onTap: () {
                ref.read(selectedDeliveryTimeProvider(widget.shopId).notifier).state = hour;
              },
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
    final customTipRate = ref.watch(customTipRateProvider(widget.shopId));
    final selectedTipRate = ref.watch(selectedTipRateProvider(widget.shopId)) ?? 0.10;
    final isEditingCustomTip = ref.watch(isEditingCustomTipProvider(widget.shopId));
    
    // 判断是否选中了自定义小费
    final isCustomTipSelected = customTipRate != null;
    
    // 如果正在编辑，初始化输入框的值
    if (isEditingCustomTip && customTipController.text.isEmpty && customTipRate != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        customTipController.text = customTipRate.toString();
      });
    }
    
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
              child: GestureDetector(
                onTap: () {
                  ref.read(selectedTipRateProvider(widget.shopId).notifier).state = 0.10;
                  ref.read(customTipRateProvider(widget.shopId).notifier).state = null;
                  ref.read(isEditingCustomTipProvider(widget.shopId).notifier).state = false;
                  customTipFocusNode.unfocus();
                },
                child: SelectableCapsuleItem(
                  title: "10%",
                  isSelected: !isCustomTipSelected && !isEditingCustomTip && selectedTipRate == 0.10,
                  onTap: () {
                    ref.read(selectedTipRateProvider(widget.shopId).notifier).state = 0.10;
                    ref.read(customTipRateProvider(widget.shopId).notifier).state = null;
                    ref.read(isEditingCustomTipProvider(widget.shopId).notifier).state = false;
                    customTipFocusNode.unfocus();
                  },
                ),
              ),
            ),  
            Expanded(
              child: GestureDetector(
                onTap: () {
                  ref.read(selectedTipRateProvider(widget.shopId).notifier).state = 0.12;
                  ref.read(customTipRateProvider(widget.shopId).notifier).state = null;
                  ref.read(isEditingCustomTipProvider(widget.shopId).notifier).state = false;
                  customTipFocusNode.unfocus();
                },
                child: SelectableCapsuleItem(
                  title: "12%",
                  isSelected: !isCustomTipSelected && !isEditingCustomTip && selectedTipRate == 0.12,
                  onTap: () {
                    ref.read(selectedTipRateProvider(widget.shopId).notifier).state = 0.12;
                    ref.read(customTipRateProvider(widget.shopId).notifier).state = null;
                    ref.read(isEditingCustomTipProvider(widget.shopId).notifier).state = false;
                    customTipFocusNode.unfocus();
                  },
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  ref.read(selectedTipRateProvider(widget.shopId).notifier).state = 0.15;
                  ref.read(customTipRateProvider(widget.shopId).notifier).state = null;
                  ref.read(isEditingCustomTipProvider(widget.shopId).notifier).state = false;
                  customTipFocusNode.unfocus();
                },
                child: SelectableCapsuleItem(
                  title: "15%",
                  isSelected: !isCustomTipSelected && !isEditingCustomTip && selectedTipRate == 0.15,
                  onTap: () {
                    ref.read(selectedTipRateProvider(widget.shopId).notifier).state = 0.15;
                    ref.read(customTipRateProvider(widget.shopId).notifier).state = null;
                    ref.read(isEditingCustomTipProvider(widget.shopId).notifier).state = false;
                    customTipFocusNode.unfocus();
                  },
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  ref.read(selectedTipRateProvider(widget.shopId).notifier).state = 0.20;
                  ref.read(customTipRateProvider(widget.shopId).notifier).state = null;
                  ref.read(isEditingCustomTipProvider(widget.shopId).notifier).state = false;
                  customTipFocusNode.unfocus();
                },
                child: SelectableCapsuleItem(
                  title: "20%",
                  isSelected: !isCustomTipSelected && !isEditingCustomTip && selectedTipRate == 0.20,
                  onTap: () {
                    ref.read(selectedTipRateProvider(widget.shopId).notifier).state = 0.20;
                    ref.read(customTipRateProvider(widget.shopId).notifier).state = null;
                    ref.read(isEditingCustomTipProvider(widget.shopId).notifier).state = false;
                    customTipFocusNode.unfocus();
                  },
                ),
              ),
            ),
            Expanded(
              child: isEditingCustomTip
                  ? _buildCustomTipInput()
                  : GestureDetector(
                      onTap: () {
                        ref.read(isEditingCustomTipProvider(widget.shopId).notifier).state = true;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          customTipFocusNode.requestFocus();
                        });
                      },
                      child: SelectableCapsuleItem(
                        title: isCustomTipSelected ? "$customTipRate%" : l10n.other,
                        isSelected: isCustomTipSelected,
                        onTap: () {
                          ref.read(isEditingCustomTipProvider(widget.shopId).notifier).state = true;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            customTipFocusNode.requestFocus();
                          });
                        },
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }
  
  /// 构建自定义小费输入框
  Widget _buildCustomTipInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryOrange,
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      alignment: Alignment.center,
      margin: EdgeInsets.only(right: 4.h),
      child: TextField(
        controller: customTipController,
        focusNode: customTipFocusNode,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: '',
          hintStyle: TextStyle(
            fontSize: 12.sp,
            color: Colors.white.withValues(alpha: 0.7),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
          suffix: Text(
            '%',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white,
            ),
          ),
        ),
        onSubmitted: (value) {
          _handleCustomTipInput(value);
        },
        onEditingComplete: () {
          _handleCustomTipInput(customTipController.text);
        },
      ),
    );
  }
  
  /// 处理自定义小费输入
  void _handleCustomTipInput(String value) {
    final l10n = AppLocalizations.of(context)!;
    if (value.trim().isEmpty) {
      // 如果输入为空，取消编辑状态
      ref.read(isEditingCustomTipProvider(widget.shopId).notifier).state = false;
      ref.read(customTipRateProvider(widget.shopId).notifier).state = null;
      customTipController.clear();
      customTipFocusNode.unfocus();
      return;
    }
    
    final tipValue = int.tryParse(value.trim());
    if (tipValue == null) {
      toast(l10n.pleaseEnterValidNumber);
      customTipFocusNode.requestFocus();
      return;
    }
    
    if (tipValue <= 0 || tipValue >= 100) {
      toast(l10n.pleaseEnter0To100);
      customTipFocusNode.requestFocus();
      return;
    }
    
    // 保存自定义小费比例
    ref.read(customTipRateProvider(widget.shopId).notifier).state = tipValue;
    ref.read(isEditingCustomTipProvider(widget.shopId).notifier).state = false;
    customTipFocusNode.unfocus();
  }
  

  

  // 计算价格
  Map<String, double> _calculatePrices() {
    final cartState = ref.read(cartStateProvider(widget.shopId));
    final shop = ref.read(shopDetailProvider(widget.shopId));
    final selectedCoupon = ref.read(selectedCouponProvider(widget.shopId));
    
    // 餐品小记
    final mealSubtotal = cartState.totals.subtotal;
    
    // 配送费
    final deliveryFee = cartState.totals.deliveryFee;
    
    // 税费&服务费：餐品小记 * taxRate + 餐品小记 * platformCommissionRate
    final taxRate = shop?.taxRate ?? 0.0;
    final serviceFeeRate = shop?.platformCommissionRate ?? 0.0;
    final taxAmount = mealSubtotal * taxRate;
    final serviceFee = mealSubtotal * serviceFeeRate;
    final taxAndServiceFee = taxAmount + serviceFee;
    
    // 优惠券折扣
    final couponDiscount = selectedCoupon?.discountAmount ?? 0.0;
    
    // 订单总价：餐品小记 + 配送费 + 税费&服务费 - 优惠券折扣
    final orderTotal = mealSubtotal + deliveryFee + taxAndServiceFee - couponDiscount;
    
    // 小费：订单总价 * 小费比例
    // 优先使用自定义小费比例，否则使用预设比例
    final customTipRate = ref.read(customTipRateProvider(widget.shopId));
    final selectedTipRate = customTipRate != null 
        ? (customTipRate / 100.0) 
        : (ref.read(selectedTipRateProvider(widget.shopId)) ?? 0.10);
    final tipAmount = orderTotal * selectedTipRate;
    
    return {
      'mealSubtotal': mealSubtotal,
      'deliveryFee': deliveryFee,
      'taxAmount': taxAmount,
      'serviceFee': serviceFee,
      'taxAndServiceFee': taxAndServiceFee,
      'couponDiscount': couponDiscount,
      'orderTotal': orderTotal,
      'tipAmount': tipAmount,
      'tipRate': selectedTipRate,
    };
  }

  Widget _buildOrderAmount(){
    final l10n = AppLocalizations.of(context)!;
    final prices = _calculatePrices();
    final selectedCoupon = ref.watch(selectedCouponProvider(widget.shopId));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonSpacing.standard,
        Text(l10n.confirmOrderOrderAmount, style: titleText),
        CommonSpacing.medium,
        _buildOrderAmountItem(
          title: l10n.confirmOrderMealSubtotal, 
          value: "\$${prices['mealSubtotal']!.toStringAsFixed(2)}"
        ),
        _buildOrderAmountItem(
          title: l10n.confirmOrderDeliveryFee, 
          value: "\$${prices['deliveryFee']!.toStringAsFixed(2)}"
        ),
        _buildOrderAmountItem(
          title: l10n.confirmOrderTaxAndServiceFee, 
          value: "\$${prices['taxAndServiceFee']!.toStringAsFixed(2)}"
        ),
        _buildOrderAmountItem(
          title: l10n.confirmOrderCouponDiscount, 
          value: _getCouponDisplayValue(selectedCoupon, prices),
          couponUsed: selectedCoupon != null,
          isCouponHint: _isCouponHintValue(selectedCoupon, prices),
          onTap: () async {
            final l10n = AppLocalizations.of(context)!;
            final couponData = ref.read(couponDataProvider(widget.shopId));
            final isLoading = ref.read(couponLoadingProvider(widget.shopId));
            
            
            if (couponData == null || couponData.list == null || couponData.list!.isEmpty) {
              toast(l10n.noCoupon);
              return;
            }
            final availableCoupons = couponData.list!
                .where((item) => (item.status ?? 0) == 1)
                .toList();
            if (availableCoupons.isEmpty) {
              toast(l10n.noCoupon);
              return;
            }
            
            final result = await CouponSelectionSheet.show(
              context: context,
              ref: ref,
              shopId: widget.shopId,
              couponList: availableCoupons,
              isLoading: isLoading,
            );
            
            if (result != null) {
              ref.read(selectedCouponProvider(widget.shopId).notifier).state = result;
            }
          },
        ),

        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
          ),
          height: 0.5.h,
          margin: EdgeInsets.symmetric(vertical: 10.h),
        ),
        SizedBox(
          width: double.infinity,
          child: Text(
            "${l10n.confirmOrderTotal}: \$${prices['orderTotal']!.toStringAsFixed(2)}", 
            style: titleText,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  /// 获取优惠券显示值
  String _getCouponDisplayValue(CouponSelectionResult? selectedCoupon, Map<String, double> prices) {
    if (selectedCoupon != null) {
      return "-\$${prices['couponDiscount']!.toStringAsFixed(2)}";
    }
    
    // 检查是否有可用优惠券
    final couponData = ref.read(couponDataProvider(widget.shopId));
    if (couponData != null && couponData.list != null && couponData.list!.isNotEmpty) {
      final availableCoupons = couponData.list!
          .where((item) => (item.status ?? 0) == 1)
          .toList();
      if (availableCoupons.isNotEmpty) {
        final l10n = AppLocalizations.of(context)!;
        return l10n.confirmOrderAvailableCoupons;
      }
    }
    
    return "\$0.00";
  }
  
  /// 判断是否为优惠券提示文本
  bool _isCouponHintValue(CouponSelectionResult? selectedCoupon, Map<String, double> prices) {
    if (selectedCoupon != null) {
      return false;
    }
    
    // 检查是否有可用优惠券
    final couponData = ref.read(couponDataProvider(widget.shopId));
    if (couponData != null && couponData.list != null && couponData.list!.isNotEmpty) {
      final availableCoupons = couponData.list!
          .where((item) => (item.status ?? 0) == 1)
          .toList();
      if (availableCoupons.isNotEmpty) {
        return true;
      }
    }
    
    return false;
  }

  Widget _buildOrderAmountItem({
    required String title,
    required String value,
    bool? couponUsed = false,
    bool isCouponHint = false,
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value, 
                  style: valueText.copyWith(
                    color: (couponUsed != null && couponUsed) || isCouponHint 
                        ? AppTheme.primaryOrange 
                        : Colors.black
                  ),
                ),
                if (isCouponHint) ...[
                  CommonSpacing.width(4.w),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12.w,
                    color: AppTheme.primaryOrange,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }


  /// 组装订单参数
  void _assembleOrderParams() {
    final l10n = AppLocalizations.of(context)!;
    final cartState = ref.read(cartStateProvider(widget.shopId));
    final selectedAddress = ref.read(selectedAddressProvider(widget.shopId));
    final selectedCoupon = ref.read(selectedCouponProvider(widget.shopId));
    final selectedDeliveryTime = ref.read(selectedDeliveryTimeProvider(widget.shopId));
    final prices = _calculatePrices();
    
    // 验证必填项
    if (cartState.items.isEmpty) {
      toast(l10n.confirmOrderEmptyCart);
      return;
    }
    
    if (selectedAddress == null || selectedAddress.id == null) {
      toast(l10n.confirmOrderSelectAddress);
      return;
    }
    
    if (selectedDeliveryTime == null || selectedDeliveryTime.time == null) {
      toast(l10n.confirmOrderSelectDeliveryTime);
      return;
    }
    
    // 将购物车商品转换为OrderItem列表
    final orderItems = cartState.items.map((item) {
      return OrderItem(
        price: item.price ?? 0,
        productId: item.productId ?? '',
        productName: item.productName ?? '',
        productSpecId: item.productSpecId ?? '',
        productSpecName: item.productSpecName ?? item.productName ?? '',
        quantity: item.quantity ?? 0,
      );
    }).toList();
    
   
    
    // 组装CreateOrderParams
    final orderParams = CreateOrderParams(
      comment: remarkController.text.trim().isEmpty ? null : remarkController.text.trim(),
      couponAmount: selectedCoupon?.discountAmount,
      deliveryAddressId: selectedAddress.id,
      deliveryFee: prices['deliveryFee']!,
      deliveryMethod: 1, // 固定为1（门店配送）
      deliveryTime: selectedDeliveryTime.time!,
      deliveryTip: prices['tipAmount']!,
      diningDate: DateTime.now(), // 用餐日期 固定为当前日期(临时)
      items: orderItems,
      mealSubtotal: prices['mealSubtotal']!,
      orderSource: 1, // 固定为1（APP）
      payAmount: prices['orderTotal']! + prices['tipAmount']!, // 订单总价 + 小费
      payType: 1, // 固定为1（Stripe）
      serviceFee: prices['serviceFee']!,
      shopId: widget.shopId,
      taxAmount: prices['taxAmount']!,
      tipRate: prices['tipRate']!,
      userCouponId: selectedCoupon?.couponId,
    );
    
    // 打印参数供查看
    Logger.info('ConfirmOrderPage', '订单参数: ${orderParams.toJson()}');
    
    // 输出格式化的参数信息
    Logger.info('ConfirmOrderPage', '''
订单参数详情:
- 备注 : ${orderParams.comment}
- 店铺ID: ${orderParams.shopId}
- 配送地址ID: ${orderParams.deliveryAddressId}
- 配送时间: ${orderParams.deliveryTime}
- 用餐日期: ${orderParams.diningDate.toIso8601String()}
- 餐品小记: ${orderParams.mealSubtotal.toStringAsFixed(2)}
- 配送费: ${orderParams.deliveryFee.toStringAsFixed(2)}
- 税费: ${orderParams.taxAmount.toStringAsFixed(2)}
- 服务费: ${orderParams.serviceFee.toStringAsFixed(2)}
- 优惠券折扣: ${orderParams.couponAmount?.toStringAsFixed(2) ?? '0.00'}
- 小费: ${orderParams.deliveryTip.toStringAsFixed(2)}
- 应付款: ${orderParams.payAmount.toStringAsFixed(2)}
- 商品: ${orderParams.items.map((e) => e.toJson()).toList()}
- 优惠券ID: ${orderParams.userCouponId ?? '无'}
    ''');
  }

  Widget _buildPaymentMethod(){
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonSpacing.standard,
        Text(l10n.confirmOrderPaymentMethod, style: titleText),
        CommonSpacing.medium,
        CapsuleButton(
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
    return GestureDetector(
      onTap: () {
        // 点击备注区域时聚焦输入框
        remarkFocusNode.requestFocus();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF2F3F5),
          borderRadius: BorderRadius.circular(16.r),
        ),
        margin: EdgeInsets.only(bottom: 24.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        child: TextField(
          controller: remarkController,
          focusNode: remarkFocusNode,
          cursorColor: Colors.black,
          decoration: InputDecoration(
            hintText: l10n.confirmOrderRemark,
            border: InputBorder.none,
          ),
          style: textStyle,
          maxLines: 3,
        ),
      ),
    );
  }


  Widget _buildApplyContainer() {
    final l10n = AppLocalizations.of(context)!;
    final prices = _calculatePrices();
    
    // 现价（包含小费，减了优惠券）
    final finalPrice = prices['orderTotal']! + prices['tipAmount']!;
    
    // 原价（包含小费，不算优惠券的原价）
    final originalPrice = (prices['mealSubtotal']! + prices['deliveryFee']! +  prices['taxAndServiceFee']!) *  (1 + prices['tipRate']!);
    
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
                    // 现价（包含小费） 减了优惠券 
                    TextSpan(
                      text: "\$${finalPrice.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryOrange,
                      ),
                    ),
                    if (prices['couponDiscount']! > 0) ...[
                      TextSpan(text: "  "),
                      // 原价（包含小费）不算优惠券的原价
                      TextSpan(
                        text: "\$${originalPrice.toStringAsFixed(2)}",
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
                  ],
                ),
              ),
              // 小费 总价*小费比例
              Text(
                l10n.confirmOrderSettlementTip("\$${prices['tipAmount']!.toStringAsFixed(2)}"), 
                style: TextStyle(fontSize: 12.sp, color: Color(0xFF86909C))
              ),
            ],
          ),
          // 按钮区域 点击时 组装 CreateOrderParams 数据 有多少组装多少
          CommonButton(
            text: l10n.confirmOrderSettlement,
            padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 12.h),
            onPressed: () {
              _assembleOrderParams();
            }
          ),
        ],
      ),
    );
  }
}

