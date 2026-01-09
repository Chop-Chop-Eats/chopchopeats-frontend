import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../models/payment_models.dart';
import '../services/payment_service.dart';
import '../../../core/utils/logger/logger.dart';
import '../../wallet/providers/wallet_provider.dart';

final paymentServiceProvider = Provider((ref) => PaymentService());

/// 初始化 Stripe 配置
final stripeConfigProvider = FutureProvider<void>((ref) async {
  try {
    final service = ref.read(paymentServiceProvider);
    final config = await service.getStripeConfig();
    if (config != null && config.publishableKey.isNotEmpty) {
      Stripe.publishableKey = config.publishableKey;
      Logger.info('Stripe', 'Stripe initialized with key: ${config.publishableKey}');
      
      // Android 端需要额外初始化 PaymentConfiguration
      if (Platform.isAndroid) {
        try {
          const platform = MethodChannel('stripe_config');
          await platform.invokeMethod('initializeStripe', {
            'publishableKey': config.publishableKey,
          });
          Logger.info('Stripe', 'Android PaymentConfiguration initialized');
        } catch (e) {
          Logger.error('Stripe', 'Failed to initialize Android PaymentConfiguration: $e');
        }
      }
    } else {
      Logger.error('Stripe', 'Failed to get Stripe config');
    }
  } catch (e, stackTrace) {
    Logger.error('Stripe', 'Error initializing Stripe: $e');
    Logger.error('Stripe', 'Stack trace: $stackTrace');
    // 不要抛出错误，让应用继续运行
  }
});

/// 获取支付方式列表（包含钱包和卡片）
final paymentMethodsListProvider = FutureProvider.autoDispose<List<PaymentSelectionWrapper>>((ref) async {
  try {
    // 确保 Stripe 已初始化
    await ref.watch(stripeConfigProvider.future);
    
    // 监听钱包信息变化，当余额更新时自动刷新支付方式列表
    final walletInfo = ref.watch(walletInfoDataProvider);
    
    final service = ref.read(paymentServiceProvider);
    final cards = await service.getPaymentMethods();
    
    final List<PaymentSelectionWrapper> list = [];

    // 1. 添加银行卡
    for (var card in cards) {
      // 根据卡品牌选择图标
      String icon = _getCardIconPath(card.cardBrand);
      
      final wrapper = PaymentSelectionWrapper(
        type: AppPaymentMethodType.stripeCard,
        card: card,
        displayName: '${card.cardBrand.toUpperCase()} *${card.cardLast4}',
        iconPath: icon,
      );
      
      list.add(wrapper);
      
      // 如果是默认卡片，自动选中
      if (card.isDefault) {
        ref.read(selectedPaymentMethodProvider.notifier).state = wrapper;
      }
    }

    // 2. 添加钱包 - 使用最新的钱包余额
    final walletBalance = walletInfo?.balance ?? 0.0;
    
    Logger.info('PaymentProvider', '构建支付方式列表: walletInfo=${walletInfo != null ? "not null" : "null"}, balance=\$${walletBalance.toStringAsFixed(2)}');
    
    list.add(PaymentSelectionWrapper(
      type: AppPaymentMethodType.wallet,
      displayName: '', 
      iconPath: 'assets/images/wallet.png',
      walletBalance: walletBalance,
    ));

    Logger.info('PaymentProvider', '支付方式列表加载成功: ${list.length}个, 最后一个是钱包, 余额: \$${walletBalance.toStringAsFixed(2)}');

    return list;
  } catch (e, stackTrace) {
    Logger.error('PaymentProvider', '获取支付方式列表失败: $e');
    Logger.error('PaymentProvider', 'Stack trace: $stackTrace');
    // 返回空列表而不是抛出错误
    return [];
  }
});

String _getCardIconPath(String cardBrand) {
  final brand = cardBrand.toLowerCase();
  if (brand.contains('visa')) {
    return 'assets/images/visa.png';
  } else if (brand.contains('mastercard')) {
    return 'assets/images/mastercard.png';
  } else if (brand.contains('paypal')) {
    return 'assets/images/paypal.png';
  }
  return 'assets/images/wallet.png';
}

/// 当前选中的支付方式
final selectedPaymentMethodProvider = StateProvider<PaymentSelectionWrapper?>((ref) => null);
