import 'package:chop_user/src/core/widgets/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/utils/pop/toast.dart';
import '../providers/cart_notifier.dart';
import '../providers/confirm_order_provider.dart';
import '../models/order_model.dart';
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

    // 监听自定义小费输入框焦点变化
    // 注意：处理逻辑在 OrderInfoView 中，这里只负责监听
    // TextField 的 onEditingComplete 会在失去焦点时被调用
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
            Expanded(
              child: _buildOrderMain(),
            ),
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
  void _assembleOrderParams() {
    final l10n = AppLocalizations.of(context)!;
    final cartState = ref.read(cartStateProvider(widget.shopId));
    final selectedAddress = ref.read(selectedAddressProvider(widget.shopId));
    final selectedCoupon = ref.read(selectedCouponProvider(widget.shopId));
    final selectedDeliveryTime =
        ref.read(selectedDeliveryTimeProvider(widget.shopId));
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
        productSpecName:
            item.productSpecName ?? item.productName ?? '',
        quantity: item.quantity ?? 0,
      );
    }).toList();

    // 组装CreateOrderParams
    final orderParams = CreateOrderParams(
      comment: remarkController.text.trim().isEmpty
          ? null
          : remarkController.text.trim(),
      couponAmount: selectedCoupon?.discountAmount,
      deliveryAddressId: selectedAddress.id,
      deliveryFee: pricesMap['deliveryFee']!,
      deliveryMethod: 1, // 固定为1（门店配送）
      deliveryTime: selectedDeliveryTime.time!,
      deliveryTip: pricesMap['tipAmount']!,
      diningDate: DateTime.now(), // 用餐日期 固定为当前日期(临时)
      items: orderItems,
      mealSubtotal: pricesMap['mealSubtotal']!,
      orderSource: 1, // 固定为1（APP）
      payAmount: pricesMap['orderTotal']! +
          pricesMap['tipAmount']!, // 订单总价 + 小费
      payType: 1, // 固定为1（Stripe）
      serviceFee: pricesMap['serviceFee']!,
      shopId: widget.shopId,
      taxAmount: pricesMap['taxAmount']!,
      tipRate: pricesMap['tipRate']!,
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
}
