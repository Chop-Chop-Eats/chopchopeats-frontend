import 'package:chop_user/src/core/network/api_client.dart';
import 'package:chop_user/src/core/network/api_paths.dart';
import 'package:chop_user/src/core/utils/logger/logger.dart';
import 'package:chop_user/src/core/utils/pop/toast.dart';
import 'package:chop_user/src/features/detail/models/order_model.dart';
import 'package:chop_user/src/features/detail/models/payment_models.dart';
import 'package:chop_user/src/features/detail/services/order_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:unified_popups/unified_popups.dart';

/// 订单支付处理工具类
class OrderPaymentHandler {
  /// 处理订单支付
  /// 
  /// [orderNo] 订单编号
  /// [paymentMethod] 支付方式（可选，如果为null则使用默认支付方式）
  /// [onSuccess] 支付成功回调
  /// [onError] 支付失败回调
  static Future<void> processPayment({
    required String orderNo,
    PaymentSelectionWrapper? paymentMethod,
    VoidCallback? onSuccess,
    Function(String error)? onError,
  }) async {
    try {
      Pop.loading();

      await Pop.confirm(
        title: '确认支付',
        content: '确认支付订单 $orderNo？',
        confirmText: '确认',
        cancelText: '取消',
        onConfirm: () async {
          // 根据支付方式类型处理不同的支付流程
          if (paymentMethod?.type == AppPaymentMethodType.wallet) {
            // 钱包支付：直接调用钱包支付 API
            Logger.info('OrderPaymentHandler', '使用钱包支付');
            await _processWalletPayment(
              orderNo,
              onSuccess: onSuccess,
              onError: onError,
            );
          } else {
            // Stripe 卡支付：创建 Payment Intent 并显示支付面板
            Logger.info('OrderPaymentHandler', '使用 Stripe 卡支付');
            await _processStripePayment(
              orderNo,
              paymentMethod,
              onSuccess: onSuccess,
              onError: onError,
            );
          }
        },
        onCancel: () {
          Pop.hideLoading();
          onError?.call('用户取消支付');
        },
      );
    } catch (e) {
      Logger.error('OrderPaymentHandler', '支付处理失败: $e');
      Pop.hideLoading();
      Toast.error('支付处理失败: $e');
      onError?.call(e.toString());
    }
  }

  /// 处理钱包支付
  static Future<void> _processWalletPayment(
    String orderNo, {
    VoidCallback? onSuccess,
    Function(String error)? onError,
  }) async {
    try {
      final response = await ApiClient().post(
        ApiPaths.payWalletApi,
        data: {'orderNo': orderNo},
      );
      Logger.info('OrderPaymentHandler', '钱包支付成功: ${response.data}');

      Pop.hideLoading();
      Toast.success('支付成功');
      onSuccess?.call();
    } catch (e) {
      Logger.error('OrderPaymentHandler', '钱包支付失败: $e');
      Pop.hideLoading();
      Toast.error('钱包支付失败: $e');
      onError?.call(e.toString());
    }
  }

  /// 处理 Stripe 卡支付
  static Future<void> _processStripePayment(
    String orderNo,
    PaymentSelectionWrapper? paymentMethod, {
    VoidCallback? onSuccess,
    Function(String error)? onError,
  }) async {
    SPIModel res;

    try {
      // 获取支付方式ID（使用数据库ID，而不是Stripe PM ID）
      final paymentMethodId =
          paymentMethod?.type == AppPaymentMethodType.stripeCard
              ? paymentMethod?.card?.id
              : null;
      Logger.info('OrderPaymentHandler', '支付方式ID: $paymentMethodId');

      res = await OrderServices().createSPI(
        orderNo,
        paymentMethodId: paymentMethodId,
      );
      Logger.info('OrderPaymentHandler', 'SPI创建成功，status: ${res.status}');

      // 如果支付已经成功，直接跳转成功页面
      if (res.status == 'succeeded') {
        Logger.info('OrderPaymentHandler', '支付已在后端完成，无需调用Stripe SDK');
        Pop.hideLoading();
        Toast.success('支付成功');
        onSuccess?.call();
        return;
      }
    } catch (e) {
      Logger.error('OrderPaymentHandler', '创建支付意图失败: $e');
      Pop.hideLoading();

      // 检查是否是支付方式无效的错误
      final errorMsg = e.toString();
      if (errorMsg.contains('支付方式不存在') || errorMsg.contains('不属于当前用户')) {
        Toast.error('支付卡片已失效，请更换支付方式');
      } else {
        Toast.error('创建支付失败: $e');
      }
      onError?.call(e.toString());
      return;
    }

    try {
      // 安全检查：确保关键数据不为空
      if (res.clientSecret == null || res.publishableKey == null) {
        throw Exception("订单生成失败：缺少 clientSecret 或 publishableKey");
      }
      Stripe.publishableKey = res.publishableKey!;
      await Stripe.instance.applySettings(); // 确保设置生效

      // 初始化支付面板 (Payment Sheet)
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          // 必填：后端返回的 clientSecret
          paymentIntentClientSecret: res.clientSecret!,

          // 必填：商户名称（显示在支付弹窗顶部）
          merchantDisplayName: '订单 ${res.orderNo}',
          
          // UI 外观定制（可选）
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(primary: Colors.blue),
          ),

          // 可选：启用 Apple Pay / Google Pay
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            testEnv: true,
          ),
        ),
      );

      // 唤起支付面板
      await Stripe.instance.presentPaymentSheet();

      Pop.hideLoading();
      Toast.success('支付成功');
      onSuccess?.call();
    } on StripeException catch (e) {
      // 处理 Stripe 内部错误（如用户取消、卡片被拒）
      Logger.error(
        'OrderPaymentHandler',
        'Stripe Error: ${e.error.localizedMessage}',
      );
      Pop.hideLoading();
      
      if (e.error.code == FailureCode.Canceled) {
        Toast.show('取消支付');
        onError?.call('用户取消支付');
      } else {
        Toast.error('支付失败: ${e.error.localizedMessage}');
        onError?.call(e.error.localizedMessage ?? '支付失败');
      }
    } catch (e) {
      // 处理其他错误（如网络请求失败）
      Logger.error('OrderPaymentHandler', 'Unknown Error: $e');
      Pop.hideLoading();
      Toast.error('发生错误: $e');
      onError?.call(e.toString());
    }
  }
}
