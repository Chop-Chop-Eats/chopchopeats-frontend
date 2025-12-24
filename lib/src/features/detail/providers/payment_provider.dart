import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../models/payment_models.dart';
import '../services/payment_service.dart';
import '../../../core/utils/logger/logger.dart';

final paymentServiceProvider = Provider((ref) => PaymentService());

/// 初始化 Stripe 配置
final stripeConfigProvider = FutureProvider<void>((ref) async {
  try {
    final service = ref.read(paymentServiceProvider);
    final config = await service.getStripeConfig();
    if (config != null && config.publishableKey.isNotEmpty) {
      Stripe.publishableKey = config.publishableKey;
      Logger.info('Stripe', 'Stripe initialized with key: ${config.publishableKey}');
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
    
    final service = ref.read(paymentServiceProvider);
    final cards = await service.getPaymentMethods();
    
    final List<PaymentSelectionWrapper> list = [];

    // 1. 添加银行卡
    for (var card in cards) {
      // 使用 wallet 图标作为通用卡片图标
      String icon = 'assets/images/wallet.png';
      
      list.add(PaymentSelectionWrapper(
        type: AppPaymentMethodType.stripeCard,
        card: card,
        displayName: '${card.cardBrand.toUpperCase()} *${card.cardLast4}',
        iconPath: icon,
      ));
    }

    // 2. 添加钱包
    list.add(PaymentSelectionWrapper(
      type: AppPaymentMethodType.wallet,
      displayName: '我的钱包',
      iconPath: 'assets/images/wallet.png',
      walletBalance: 99.0, // 示例值
    ));

    return list;
  } catch (e, stackTrace) {
    Logger.error('PaymentProvider', '获取支付方式列表失败: $e');
    Logger.error('PaymentProvider', 'Stack trace: $stackTrace');
    // 返回空列表而不是抛出错误
    return [];
  }
});

/// 当前选中的支付方式
final selectedPaymentMethodProvider = StateProvider<PaymentSelectionWrapper?>((ref) => null);
