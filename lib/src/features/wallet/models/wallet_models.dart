import '../../../core/l10n/locale_service.dart';
import '../../../core/utils/json_utils.dart';

// 充值卡列表item
class RechargeCardItem {
  ///赠送金额
  final double bonusAmount;

  ///描述
  final String? description;

  ///主键ID
  final int id;

  ///充值金额
  final double rechargeAmount;

  ///排序
  final int? sort;

  ///标题
  final String title;

  ///英文标题
  final String? titleEnglish;

  RechargeCardItem({
    required this.bonusAmount,
    this.description,
    required this.id,
    required this.rechargeAmount,
    this.sort,
    required this.title,
    this.titleEnglish,
  });

  factory RechargeCardItem.fromJson(Map<String, dynamic> json) {
    return RechargeCardItem(
      bonusAmount: json['bonusAmount'],
      description: json['description'],
      id: json['id'],
      rechargeAmount: json['rechargeAmount'],
      sort: json['sort'],
      title: json['title'],
      titleEnglish: json['titleEnglish'],
    );
  }

  // 处理title
  String get localizedTitle {
    return LocaleService.getLocalizedText(title, titleEnglish);
  }
}

// 创建充值订单参数
class RechargeCardOrderParams {
  ///赠送金额
  final double bonusAmount;

  ///订单来源：1=APP，2=PC
  final int orderSource;

  ///应付金额（实际付款金额）
  final double payAmount;

  ///支付方式：1=Stripe，2=钱包余额
  final int payType;

  ///充值金额
  final double rechargeAmount;

  ///充值卡ID
  final String rechargeCardId;

  RechargeCardOrderParams({
    required this.bonusAmount,
    required this.orderSource,
    required this.payAmount,
    required this.payType,
    required this.rechargeAmount,
    required this.rechargeCardId,
  });

  Map<String, dynamic> toJson() {
    return {
      'bonusAmount': bonusAmount,
      'orderSource': orderSource,
      'payAmount': payAmount,
      'payType': payType,
      'rechargeAmount': rechargeAmount,
      'rechargeCardId': rechargeCardId,
    };
  }
}

// 最近钱包交易记录item
class RecentWalletHistoryItem {
  ///交易后余额（现金+赠送）
  final double balanceAfter;

  ///记录ID
  final String id;

  ///支付方式：1=Stripe，2=钱包余额
  final int payType;

  ///支付方式名称
  final String payTypeName;

  ///支付方式英文名称
  final String? englishPayTypeName;

  ///记录日期
  final DateTime recordDate;

  ///交易金额
  final double transactionAmount;

  ///交易类型：1=订单充值，2=订单支付，3=订单退款
  final int txType;

  ///交易类型名称
  final String txTypeName;

  ///交易类型英文名称
  final String? englishTxTypeName;

  RecentWalletHistoryItem({
    required this.balanceAfter,
    required this.id,
    required this.payType,
    required this.payTypeName,
    this.englishPayTypeName,
    required this.recordDate,
    required this.transactionAmount,
    required this.txType,
    required this.txTypeName,
    this.englishTxTypeName,
  });

  factory RecentWalletHistoryItem.fromJson(Map<String, dynamic> json) {
    return RecentWalletHistoryItem(
      balanceAfter: JsonUtils.parseDouble(json, 'balanceAfter') ?? 0.0,
      id: JsonUtils.parseString(json, 'id') ?? '',
      payType: JsonUtils.parseInt(json, 'payType') ?? 0,
      payTypeName: JsonUtils.parseString(json, 'payTypeName') ?? '',
      englishPayTypeName: JsonUtils.parseString(json, 'englishPayTypeName'),
      recordDate: JsonUtils.parseDateTime(json, 'recordDate') ?? DateTime.now(),
      transactionAmount:
          JsonUtils.parseDouble(json, 'transactionAmount') ?? 0.0,
      txType: JsonUtils.parseInt(json, 'txType') ?? 0,
      txTypeName: JsonUtils.parseString(json, 'txTypeName') ?? '',
      englishTxTypeName: JsonUtils.parseString(json, 'englishTxTypeName'),
    );
  }

  /// 获取本地化的交易类型名称
  String getLocalizedTxTypeName() {
    return LocaleService.getLocalizedText(txTypeName, englishTxTypeName);
  }

  /// 获取本地化的支付方式名称
  String getLocalizedPayTypeName() {
    return LocaleService.getLocalizedText(payTypeName, englishPayTypeName);
  }

  Map<String, dynamic> toJson() {
    return {
      'balanceAfter': balanceAfter,
      'id': id,
      'payType': payType,
      'payTypeName': payTypeName,
      'englishPayTypeName': englishPayTypeName,
      'recordDate': recordDate,
      'transactionAmount': transactionAmount,
      'txType': txType,
      'txTypeName': txTypeName,
      'englishTxTypeName': englishTxTypeName,
    };
  }
}

// 全部钱包交易记录item 按照日期分类
class AllWalletHistoryItem {
  ///交易日期
  final String transactionDate;

  ///当天的交易明细列表
  final List<RecentWalletHistoryItem> transactionDetail;

  AllWalletHistoryItem({
    required this.transactionDate,
    required this.transactionDetail,
  });

  factory AllWalletHistoryItem.fromJson(Map<String, dynamic> json) {
    return AllWalletHistoryItem(
      transactionDate: json['transactionDate'],
      transactionDetail:
          JsonUtils.parseList(
            json,
            'transactionDetail',
            (e) => RecentWalletHistoryItem.fromJson(e),
          ) ??
          [],
    );
  }
}

// 我的钱包信息
class MyWalletInfo {
  ///余额
  final double balance;

  ///币种
  final String? currency;

  ///最近资金变动时间
  final DateTime? lastTxTime;

  ///状态：1=正常，0=冻结
  final int status;

  ///累计赠送
  final double? totalBonus;

  ///累计充值
  final double? totalRecharge;

  ///累计退款
  final double? totalRefund;

  ///累计消费
  final double? totalSpent;

  ///用户ID
  final int userId;

  MyWalletInfo({
    required this.balance,
    this.currency,
    this.lastTxTime,
    required this.status,
    this.totalBonus,
    this.totalRecharge,
    this.totalRefund,
    this.totalSpent,
    required this.userId,
  });

  factory MyWalletInfo.fromJson(Map<String, dynamic> json) {
    return MyWalletInfo(
      balance: JsonUtils.parseDouble(json, 'balance') ?? 0.0,
      currency: JsonUtils.parseString(json, 'currency'),
      lastTxTime: JsonUtils.parseDateTime(json, 'lastTxTime'),
      status: JsonUtils.parseInt(json, 'status') ?? 0,
      totalBonus: JsonUtils.parseDouble(json, 'totalBonus'),
      totalRecharge: JsonUtils.parseDouble(json, 'totalRecharge'),
      totalRefund: JsonUtils.parseDouble(json, 'totalRefund'),
      totalSpent: JsonUtils.parseDouble(json, 'totalSpent'),
      userId: JsonUtils.parseInt(json, 'userId') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'currency': currency,
      'lastTxTime': lastTxTime,
      'status': status,
      'totalBonus': totalBonus,
      'totalRecharge': totalRecharge,
      'totalRefund': totalRefund,
      'totalSpent': totalSpent,
      'userId': userId,
    };
  }
}
