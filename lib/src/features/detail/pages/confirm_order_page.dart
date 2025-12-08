import 'package:chop_user/src/core/widgets/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:unified_popups/unified_popups.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/utils/pop/toast.dart';
import '../providers/cart_notifier.dart';
import '../providers/confirm_order_provider.dart';
import '../models/order_model.dart';
import '../services/order_services.dart';
import '../views/order_info.dart';
import '../views/apply_container.dart';
import '../utils/order_price_calculator.dart';
import '../../address/providers/address_provider.dart';

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
  }

  @override
  void dispose() {
    remarkController.dispose();
    remarkFocusNode.dispose();
    customTipController.dispose();
    customTipFocusNode.dispose();
    super.dispose();
  }

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
        body: Column(
          children: [
            // 上半部分内容，使用 Expanded 占满剩余空间
            Expanded(child: _buildOrderMain()),
            ApplyContainer(
              shopId: widget.shopId,
              onSettlement: _assembleOrderParams,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderMain() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        CommonAppBar(
          title: l10n.confirmOrder,
          backgroundColor: Colors.transparent,
        ),
        Expanded(
          child: OrderInfoView(
            shopId: widget.shopId,
            remarkController: remarkController,
            remarkFocusNode: remarkFocusNode,
            customTipController: customTipController,
            customTipFocusNode: customTipFocusNode,
          ),
        ),
      ],
    );
  }

  /// 组装订单参数
  Future<void> _assembleOrderParams() async {
    final l10n = AppLocalizations.of(context)!;
    final cartState = ref.read(cartStateProvider(widget.shopId));
    final selectedAddress = ref.read(selectedAddressProvider(widget.shopId));
    final selectedCoupon = ref.read(selectedCouponProvider(widget.shopId));
    final selectedDeliveryTime = ref.read(
      selectedDeliveryTimeProvider(widget.shopId),
    );
    final selectedDiningDate = ref.read(
      selectedDiningDateProvider(widget.shopId),
    );
    final prices = OrderPriceCalculator.calculate(
      ref: ref,
      shopId: widget.shopId,
    );
    final pricesMap = prices.toMap();

    // 验证必填项
    if (cartState.items.isEmpty) {
      toast(l10n.confirmOrderEmptyCart);
      return;
    }

    if (selectedAddress == null || selectedAddress.id == null) {
      toast(l10n.confirmOrderSelectAddress);
      return;
    }

    if (selectedDiningDate == null || selectedDiningDate.isEmpty) {
      toast(l10n.confirmOrderSelectDeliveryTime);
      return;
    }

    if (selectedDeliveryTime == null || selectedDeliveryTime.time == null) {
      toast(l10n.confirmOrderSelectDeliveryTime);
      return;
    }

    Pop.loading();
    // 将购物车商品转换为OrderItem列表
    final orderItems =
        cartState.items.map((item) {
          return OrderItem(
            price: formatPrice(item.price),
            productId: item.productId ?? '',
            productName: item.productName ?? '',
            productSpecId: item.productSpecId ?? '',
            productSpecName: item.productSpecName ?? item.productName ?? '',
            quantity: item.quantity ?? 0,
          );
        }).toList();

    // 组装CreateOrderParams，所有价格字段都格式化为两位小数
    final orderParams = CreateOrderParams(
      comment:
          remarkController.text.trim().isEmpty
              ? null
              : remarkController.text.trim(),
      couponAmount: selectedCoupon?.discountAmount != null
          ? formatPrice(selectedCoupon!.discountAmount)
          : null,
      deliveryAddressId: selectedAddress.id,
      deliveryFee: formatPrice(pricesMap['deliveryFee']),
      deliveryMethod: 1, // 固定为1（门店配送）
      deliveryTime: selectedDeliveryTime.time!,
      deliveryTip: formatPrice(pricesMap['tipAmount']),
      diningDate: selectedDiningDate,
      items: orderItems,
      mealSubtotal: formatPrice(pricesMap['mealSubtotal']),
      orderSource: 1, // 固定为1（APP）
      payAmount: formatPrice(
        (pricesMap['orderTotal'] ?? 0) + (pricesMap['tipAmount'] ?? 0),
      ), // 订单总价 + 小费
      payType: 1, // 固定为1（Stripe）
      serviceFee: formatPrice(pricesMap['serviceFee']),
      shopId: widget.shopId,
      taxAmount: formatPrice(pricesMap['taxAmount']),
      tipRate: formatPrice(pricesMap['tipRate']),
      userCouponId: selectedCoupon?.couponId,
    );

    // 打印参数供查看
    Logger.info('ConfirmOrderPage', '订单参数: ${orderParams.toJson()}');

    final orderId = await OrderServices().createOrder(orderParams);
    final res = await OrderServices().createSPI(orderId);
    try {
      // 安全检查：确保关键数据不为空
      if (res.clientSecret == null || res.publishableKey == null) {
        throw Exception("订单生成失败：缺少 clientSecret 或 publishableKey");
      }
      Stripe.publishableKey = res.publishableKey!;
      await Stripe.instance.applySettings(); // 确保设置生效

      // 4. 初始化支付面板 (Payment Sheet)
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          // 必填：后端返回的 clientSecret
          paymentIntentClientSecret: res.clientSecret!,

          // 必填：商户名称（显示在支付弹窗顶部）
          merchantDisplayName: '订单 ${res.orderNo}', // 也可以用 '订单 ${res.orderNo}'

          // UI 外观定制（可选）
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Colors.blue,
            ),
          ),
          
          // 可选：启用 Apple Pay / Google Pay
          // 注意：如果没有 customerId，这些通常作为单次支付处理
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'US', // 根据你的 Stripe 账户所在国家填写，如 'US', 'SG'
            testEnv: true, // 上线时改为 false
          ),
        ),
      );

      // 5. 唤起支付面板
      await Stripe.instance.presentPaymentSheet();


      
      // TODO: 在这里跳转到“支付成功”页面或刷新订单列表
    } on StripeException catch (e) {
      // 处理 Stripe 内部错误（如用户取消、卡片被拒）
      Logger.error('ConfirmOrderPage', 'Stripe Error: ${e.error.localizedMessage}');
      if (e.error.code == FailureCode.Canceled) {
        toast("取消支付");
      } else {
        toast("支付失败: ${e.error.localizedMessage}");
      }
    } catch (e) {
      // 处理其他错误（如网络请求失败）
      Logger.error('ConfirmOrderPage', 'Unknown Error: $e');
      toast("发生错误: $e");
    }finally {
      Pop.hideLoading();
    }
  }
}

