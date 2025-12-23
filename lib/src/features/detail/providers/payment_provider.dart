import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../models/payment_models.dart';
import '../services/payment_service.dart';
import '../../../core/utils/logger/logger.dart';

final paymentServiceProvider = Provider((ref) => PaymentService());

/// 初始化 Stripe 配置
final stripeConfigProvider = FutureProvider<void>((ref) async {
  final service = ref.read(paymentServiceProvider);
  final config = await service.getStripeConfig();
  if (config != null && config.publishableKey.isNotEmpty) {
    Stripe.publishableKey = config.publishableKey;
    Logger.info('Stripe', 'Stripe initialized with key: ${config.publishableKey}');
  }
});

/// 获取支付方式列表（包含钱包和卡片）
final paymentMethodsListProvider = FutureProvider.autoDispose<List<PaymentSelectionWrapper>>((ref) async {
  // 确保 Stripe 已初始化
  await ref.watch(stripeConfigProvider.future);
  
  final service = ref.read(paymentServiceProvider);
  final cards = await service.getPaymentMethods();
  
  final List<PaymentSelectionWrapper> list = [];

  // 1. 添加银行卡
  for (var card in cards) {
    String icon = 'assets/images/card_generic.png'; // 默认图标
    if (card.cardBrand.toLowerCase() == 'visa') icon = 'assets/images/visa.png';
    if (card.cardBrand.toLowerCase() == 'mastercard') icon = 'assets/images/mastercard.png';
    
    list.add(PaymentSelectionWrapper(
      type: AppPaymentMethodType.stripeCard,
      card: card,
      displayName: '${card.cardBrand.toUpperCase()} *${card.cardLast4}',
      iconPath: icon,
    ));
  }

  // 2. 添加 PayPal (如果需要)
  list.add(PaymentSelectionWrapper(
    type: AppPaymentMethodType.paypal,
    displayName: 'PayPal',
    iconPath: 'assets/images/paypal.png',
  ));

  // 3. 添加钱包 (这里假设余额是 99.0，实际应从 WalletProvider 获取)
  // final walletInfo = ref.watch(myWalletProvider); 
  list.add(PaymentSelectionWrapper(
    type: AppPaymentMethodType.wallet,
    displayName: '我的钱包',
    iconPath: 'assets/images/wallet.png',
    walletBalance: 99.0, // 示例值
  ));

  return list;
});

/// 当前选中的支付方式
final selectedPaymentMethodProvider = StateProvider<PaymentSelectionWrapper?>((ref) => null);
