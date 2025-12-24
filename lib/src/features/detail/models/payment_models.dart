class StripeConfig {
  final String publishableKey;
  final String currency;

  StripeConfig({required this.publishableKey, required this.currency});

  factory StripeConfig.fromJson(Map<String, dynamic> json) {
    return StripeConfig(
      publishableKey: json['publishableKey'] ?? '',
      currency: json['currency'] ?? 'usd',
    );
  }
}

class StripePaymentMethodModel {
  final String id;
  final String stripePaymentMethodId;
  final String cardBrand;
  final String cardLast4;
  final int cardExpMonth;
  final int cardExpYear;
  final bool isDefault;

  StripePaymentMethodModel({
    required this.id,
    required this.stripePaymentMethodId,
    required this.cardBrand,
    required this.cardLast4,
    required this.cardExpMonth,
    required this.cardExpYear,
    required this.isDefault,
  });

  factory StripePaymentMethodModel.fromJson(Map<String, dynamic> json) {
    // 处理 isDefault 字段，可能是 int (0/1) 或 bool
    bool parseIsDefault(dynamic value) {
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value == '1' || value.toLowerCase() == 'true';
      return false;
    }

    return StripePaymentMethodModel(
      id: json['id']?.toString() ?? '',
      stripePaymentMethodId: json['stripePaymentMethodId']?.toString() ?? '',
      cardBrand: json['cardBrand']?.toString() ?? '',
      cardLast4: json['cardLast4']?.toString() ?? '', // 后端返回的是 int，需要转为 string
      cardExpMonth: int.tryParse(json['cardExpMonth']?.toString() ?? '0') ?? 0,
      cardExpYear: int.tryParse(json['cardExpYear']?.toString() ?? '0') ?? 0,
      isDefault: parseIsDefault(json['isDefault']),
    );
  }
}

/// 用于前端区分是钱包支付还是银行卡支付
enum AppPaymentMethodType {
  wallet,
  stripeCard,
  paypal, // 预留
}

/// 支付方式包装类（用于UI列表展示）
class PaymentSelectionWrapper {
  final AppPaymentMethodType type;
  final StripePaymentMethodModel? card;
  final String displayName;
  final String iconPath;
  final double? walletBalance; // 仅钱包类型使用

  PaymentSelectionWrapper({
    required this.type,
    this.card,
    required this.displayName,
    required this.iconPath,
    this.walletBalance,
  });
}
