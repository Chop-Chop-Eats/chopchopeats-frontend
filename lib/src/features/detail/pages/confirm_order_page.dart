import 'package:chop_user/src/core/widgets/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:unified_popups/unified_popups.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/utils/pop/toast.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../../order/providers/order_provider.dart';
import '../providers/cart_notifier.dart';
import '../providers/confirm_order_provider.dart';
import '../providers/detail_provider.dart';
import '../providers/payment_provider.dart';
import '../models/order_model.dart';
import '../models/payment_models.dart';
import '../services/order_services.dart';
import '../views/order_info.dart';
import '../views/apply_container.dart';
import '../utils/order_price_calculator.dart';
import '../../address/providers/address_provider.dart';
import '../../wallet/providers/wallet_provider.dart';

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
    // 初始化地址列表和钱包信息
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final addressState = ref.read(addressListProvider);
      if (addressState.addresses.isEmpty && !addressState.isLoading) {
        await ref.read(addressListProvider.notifier).loadAddresses();
      }

      // 加载钱包信息（用于支付方式选择）
      final walletState = ref.read(walletInfoProvider);
      if (!walletState.hasLoaded && !walletState.isLoading) {
        await ref.read(walletInfoProvider.notifier).loadWalletInfo();
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
    final selectedPaymentMethod = ref.read(selectedPaymentMethodProvider);
    final shop = ref.read(shopDetailProvider(widget.shopId));
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

    // 刷新购物车以确保价格与后端同步
    try {
      await ref
          .read(cartProvider.notifier)
          .refreshCart(shopId: widget.shopId, diningDate: selectedDiningDate);
      Logger.info('ConfirmOrderPage', '购物车刷新成功');
    } catch (e) {
      Logger.error('ConfirmOrderPage', '刷新购物车失败: $e');
      Pop.hideLoading();
      toast('同步购物车失败，请稍后重试');
      return;
    }

    // 重新获取最新的购物车状态
    final refreshedCartState = ref.read(cartStateProvider(widget.shopId));

    // 将购物车商品转换为OrderItem列表，并添加详细日志
    final orderItems = <OrderItem>[];
    Logger.info(
      'ConfirmOrderPage',
      '开始转换购物车商品 (${refreshedCartState.items.length} 项)',
    );

    for (var i = 0; i < refreshedCartState.items.length; i++) {
      final item = refreshedCartState.items[i];

      // 详细日志：记录每个商品的关键信息
      Logger.info(
        'ConfirmOrderPage',
        '商品 [$i]: '
            'productId=${item.productId}, '
            'productSpecId=${item.productSpecId}, '
            'price=${item.price}, '
            'productPrice=${item.productPrice}, '
            'quantity=${item.quantity}, '
            'selectedSkus=${item.selectedSkus?.map((s) => "${s.id}(${s.skuPrice})").join(", ")}',
      );

      // 验证必填字段
      if (item.price == null || item.productPrice == null) {
        Logger.error('ConfirmOrderPage', '商品 [$i] price 或 productPrice 为空');
        Pop.hideLoading();
        toast('购物车存在无效商品（价格为空），请重新添加');
        return;
      }

      if (item.productId == null || item.productId!.isEmpty) {
        Logger.error('ConfirmOrderPage', '商品 [$i] productId 为空');
        Pop.hideLoading();
        toast('购物车存在无效商品（商品ID为空），请重新添加');
        return;
      }

      // 转换 CartItemSku 为 SelectedSkuVO
      // 根据后端反馈：使用 skus 列表中的附加价（数据库价格），而不是 selectedSkus 中的错误价格
      final selectedSkus = item.selectedSkus?.map((sku) {
        // 从 skus 列表查找对应的 SKU 以获取数据库中的正确附加价
        final dbSku = item.skus?.firstWhere(
          (s) => s.id == sku.id,
          orElse: () => sku,
        );
        
        final cartSkuPrice = sku.skuPrice ?? 0; // 购物车返回的价格（可能不准确）
        final dbSkuPrice = dbSku?.skuPrice ?? cartSkuPrice; // 数据库中的正确附加价
        
        Logger.info(
          'ConfirmOrderPage',
          'SKU ${sku.id}: cartSkuPrice=$cartSkuPrice, '
              'dbSkuPrice=$dbSkuPrice (使用数据库价格)',
        );

        return SelectedSkuVO(
          id: sku.id ?? '',
          skuName: sku.skuName ?? '',
          englishSkuName: sku.englishSkuName,
          skuPrice: dbSkuPrice, // 使用数据库中的正确附加价
          skuGroupId: sku.skuGroupId,
          skuGroupType: sku.skuGroupType,
        );
      }).toList();

      // 重新计算正确的 price = productPrice + sum(selectedSkus.skuPrice)
      final sumOfSkuPrices = selectedSkus?.fold<double>(
            0,
            (sum, sku) => sum + sku.skuPrice,
          ) ??
          0;
      final correctPrice = (item.productPrice ?? 0) + sumOfSkuPrices;

      Logger.info(
        'ConfirmOrderPage',
        '订单商品 [$i]: productPrice=${item.productPrice}, '
            '计算price=${item.productPrice} + $sumOfSkuPrices = $correctPrice, '
            '购物车price=${item.price}',
      );

      orderItems.add(
        OrderItem(
          productId: item.productId!,
          productName: item.productName ?? '',
          englishProductName: item.englishProductName,
          quantity: item.quantity ?? 0,
          productPrice: formatPrice(item.productPrice),
          price: formatPrice(correctPrice), // 使用重新计算的正确价格
          selectedSkus: selectedSkus,
        ),
      );
    }

    // 重新计算 mealSubtotal，基于修正后的商品价格
    final recalculatedMealSubtotal = orderItems.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    // 重新计算 taxAmount 和 serviceFee，基于修正后的 mealSubtotal
    final taxRate = shop?.taxRate ?? 0.0;
    final serviceFeeRate = shop?.platformCommissionRate ?? 0.0;
    final recalculatedTaxAmount = recalculatedMealSubtotal * taxRate;
    final recalculatedServiceFee = recalculatedMealSubtotal * serviceFeeRate;
    
    // 重新计算 deliveryTip，基于修正后的 mealSubtotal
    final tipRate = pricesMap['tipRate'] ?? 0.1;
    final recalculatedDeliveryTip = recalculatedMealSubtotal * tipRate;

    Logger.info(
      'ConfirmOrderPage',
      '重新计算 mealSubtotal: $recalculatedMealSubtotal (原值: ${pricesMap['mealSubtotal']})',
    );
    Logger.info(
      'ConfirmOrderPage',
      '重新计算 taxAmount: $recalculatedTaxAmount (原值: ${pricesMap['taxAmount']}, taxRate: $taxRate)',
    );
    Logger.info(
      'ConfirmOrderPage',
      '重新计算 serviceFee: $recalculatedServiceFee (原值: ${pricesMap['serviceFee']}, serviceFeeRate: $serviceFeeRate)',
    );
    Logger.info(
      'ConfirmOrderPage',
      '重新计算 deliveryTip: $recalculatedDeliveryTip (原值: ${pricesMap['tipAmount']}, tipRate: $tipRate)',
    );

    // 组装CreateOrderParams，所有价格字段都格式化为两位小数
    final orderParams = CreateOrderParams(
      comment:
          remarkController.text.trim().isEmpty
              ? null
              : remarkController.text.trim(),
      couponAmount:
          selectedCoupon?.discountAmount != null
              ? formatPrice(selectedCoupon!.discountAmount)
              : null,
      deliveryAddressId: selectedAddress.id,
      deliveryFee: formatPrice(pricesMap['deliveryFee']),
      deliveryMethod: 1, // 固定为1（门店配送）
      deliveryTime: selectedDeliveryTime.time!,
      deliveryTip: formatPrice(recalculatedDeliveryTip), // 使用重新计算的小费
      diningDate: selectedDiningDate,
      items: orderItems,
      mealSubtotal: formatPrice(recalculatedMealSubtotal), // 使用重新计算的餐品小计
      orderSource: 1, // 固定为1（APP）
      payAmount: formatPrice(
        recalculatedMealSubtotal +
            recalculatedTaxAmount +
            recalculatedServiceFee +
            (pricesMap['deliveryFee'] ?? 0) +
            recalculatedDeliveryTip -
            (selectedCoupon?.discountAmount ?? 0),
      ), // 重新计算总支付金额
      payType: 1, // 固定为1（Stripe）
      serviceFee: formatPrice(recalculatedServiceFee), // 使用重新计算的服务费
      shopId: widget.shopId,
      taxAmount: formatPrice(recalculatedTaxAmount), // 使用重新计算的税费
      tipRate: formatPrice(pricesMap['tipRate']),
      userCouponId: selectedCoupon?.couponId,
    );

    // 打印完整订单参数供查看
    final paramsJson = orderParams.toJson();
    Logger.info('ConfirmOrderPage', '========== 订单参数详情 ==========');
    Logger.info('ConfirmOrderPage', 'shopId: ${paramsJson['shopId']}');
    Logger.info('ConfirmOrderPage', 'diningDate: ${paramsJson['diningDate']}');
    Logger.info(
      'ConfirmOrderPage',
      'deliveryTime: ${paramsJson['deliveryTime']}',
    );
    Logger.info(
      'ConfirmOrderPage',
      'mealSubtotal: ${paramsJson['mealSubtotal']}',
    );
    Logger.info(
      'ConfirmOrderPage',
      'deliveryFee: ${paramsJson['deliveryFee']}',
    );
    Logger.info('ConfirmOrderPage', 'taxAmount: ${paramsJson['taxAmount']}');
    Logger.info('ConfirmOrderPage', 'serviceFee: ${paramsJson['serviceFee']}');
    Logger.info('ConfirmOrderPage', 'payAmount: ${paramsJson['payAmount']}');
    Logger.info('ConfirmOrderPage', 'items: ${paramsJson['items']}');
    Logger.info('ConfirmOrderPage', '==================================');

    String orderId;

    try {
      orderId = await OrderServices().createOrder(orderParams);
      Logger.info('ConfirmOrderPage', '订单创建成功: orderId=$orderId');

      // 根据支付方式类型处理不同的支付流程
      if (selectedPaymentMethod?.type == AppPaymentMethodType.wallet) {
        // 钱包支付：直接调用钱包支付 API
        Logger.info('ConfirmOrderPage', '使用钱包支付');
        await _processWalletPayment(orderId);
      } else {
        // Stripe 卡支付：创建 Payment Intent 并显示支付面板
        Logger.info('ConfirmOrderPage', '使用 Stripe 卡支付');
        await _processStripePayment(orderId, selectedPaymentMethod);
      }
    } catch (e) {
      Logger.error('ConfirmOrderPage', '创建订单失败: $e');
      Pop.hideLoading();
      toast('创建订单失败: $e');
      return;
    }
  }

  /// 处理钱包支付
  Future<void> _processWalletPayment(String orderNo) async {
    try {
      final response = await ApiClient().post(
        ApiPaths.payWalletApi,
        data: {'orderNo': orderNo},
      );
      Logger.info('ConfirmOrderPage', '钱包支付成功: ${response.data}');

      Pop.hideLoading();

      if (!mounted) return;

      toast('支付成功');
      
      Logger.info('ConfirmOrderPage', '准备刷新订单列表...');
      
      // 支付成功后返回，并传递需要刷新的标志
      Navigator.pop(context, true);
      
      // 延迟刷新，确保已经返回到订单页面
      Future.delayed(const Duration(milliseconds: 300), () {
        Logger.info('ConfirmOrderPage', '开始刷新订单列表（钱包支付）');
        if (mounted) {
          ref.read(orderListProvider(null).notifier).refresh();  // 全部
          ref.read(orderListProvider(1).notifier).refresh();     // 待支付
          ref.read(orderListProvider(2).notifier).refresh();     // 进行中
        } else {
          Logger.error('ConfirmOrderPage', 'Widget已销毁，无法刷新');
        }
      });
    } catch (e) {
      Logger.error('ConfirmOrderPage', '钱包支付失败: $e');
      Pop.hideLoading();
      toast('钱包支付失败: $e');
    }
  }

  /// 处理 Stripe 卡支付
  Future<void> _processStripePayment(
    String orderNo,
    PaymentSelectionWrapper? paymentMethod,
  ) async {
    SPIModel res;

    try {
      // 获取支付方式ID
      final paymentMethodId = paymentMethod?.type == AppPaymentMethodType.stripeCard
          ? paymentMethod?.card?.stripePaymentMethodId
          : null;
      Logger.info('ConfirmOrderPage', '支付方式ID: $paymentMethodId');

      res = await OrderServices().createSPI(orderNo, paymentMethodId: paymentMethodId);
      Logger.info('ConfirmOrderPage', 'SPI创建成功');
    } catch (e) {
      Logger.error('ConfirmOrderPage', '创建订单失败: $e');
      Pop.hideLoading();
      toast('创建订单失败: $e');
      return;
    }

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
            colors: PaymentSheetAppearanceColors(primary: Colors.blue),
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
      
      Pop.hideLoading();
      
      if (!mounted) return;

      toast('支付成功');
      
      Logger.info('ConfirmOrderPage', '准备刷新订单列表...');
      
      // 支付成功后返回，并传递需要刷新的标志
      Navigator.pop(context, true);
      
      // 延迟刷新，确保已经返回到订单页面
      Future.delayed(const Duration(milliseconds: 300), () {
        Logger.info('ConfirmOrderPage', '开始刷新订单列表（Stripe支付）');
        if (mounted) {
          ref.read(orderListProvider(null).notifier).refresh();  // 全部
          ref.read(orderListProvider(1).notifier).refresh();     // 待支付
          ref.read(orderListProvider(2).notifier).refresh();     // 进行中
        } else {
          Logger.error('ConfirmOrderPage', 'Widget已销毁，无法刷新');
        }
      });
      // TODO: 在这里跳转到"支付成功"页面或刷新订单列表
    } on StripeException catch (e) {
      // 处理 Stripe 内部错误（如用户取消、卡片被拒）
      Logger.error(
        'ConfirmOrderPage',
        'Stripe Error: ${e.error.localizedMessage}',
      );
      if (e.error.code == FailureCode.Canceled) {
        toast("取消支付");
      } else {
        toast("支付失败: ${e.error.localizedMessage}");
      }
    } catch (e) {
      // 处理其他错误（如网络请求失败）
      Logger.error('ConfirmOrderPage', 'Unknown Error: $e');
      toast("发生错误: $e");
    } finally {
      Pop.hideLoading();
    }
  }
}
