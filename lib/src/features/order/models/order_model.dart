import 'package:chop_user/src/core/utils/json_utils.dart';
import 'package:flutter/material.dart';

class AppTradeOrderPageRespVO {
  final String? orderNo;
  final int? userId;
  final String? shopId;
  final String? shopName;
  final String? englishShopName;
  final String? categoryId;
  final String? categoryName;
  final String? englishCategoryName;
  final int? status;
  final String? statusName;
  final String? statusDesc;
  final String? statusEnglishName;
  final String? statusEnglishDesc;
  final int? statusGroup;
  final String? statusGroupName;
  final double? payAmount;
  final double? actualPayAmount;
  final double? estimatedIncome;
  final String? createTime; // API says string(date-time)
  final int? orderPeriod;
  final int? totalQuantity;
  final int? deliveryMethod;
  final String? nickname;
  final String? mobile;
  final String? state;
  final String? address;
  final String? detailAddress;
  final String? mealDeliveryTime;
  final String? payTime;
  final double? refundAmount;
  final String? applyRefundTime;
  final String? refundReason;
  final String? rejectRefundReason;
  final String? responseRefundTime;
  final String? finishRefundTime;
  final String? driverMobile;
  final bool? commentMark;
  final List<OrderItemPageRespVO>? items;

  AppTradeOrderPageRespVO({
    this.orderNo,
    this.userId,
    this.shopId,
    this.shopName,
    this.englishShopName,
    this.categoryId,
    this.categoryName,
    this.englishCategoryName,
    this.status,
    this.statusName,
    this.statusDesc,
    this.statusEnglishName,
    this.statusEnglishDesc,
    this.statusGroup,
    this.statusGroupName,
    this.payAmount,
    this.actualPayAmount,
    this.estimatedIncome,
    this.createTime,
    this.orderPeriod,
    this.totalQuantity,
    this.deliveryMethod,
    this.nickname,
    this.mobile,
    this.state,
    this.address,
    this.detailAddress,
    this.mealDeliveryTime,
    this.payTime,
    this.refundAmount,
    this.applyRefundTime,
    this.refundReason,
    this.rejectRefundReason,
    this.responseRefundTime,
    this.finishRefundTime,
    this.driverMobile,
    this.commentMark,
    this.items,
  });

  factory AppTradeOrderPageRespVO.fromJson(Map<String, dynamic> json) {
    return AppTradeOrderPageRespVO(
      orderNo: JsonUtils.parseString(json, 'orderNo'),
      userId: JsonUtils.parseInt(json, 'userId'),
      shopId: JsonUtils.parseString(json, 'shopId'),
      shopName: JsonUtils.parseString(json, 'shopName'),
      englishShopName: JsonUtils.parseString(json, 'englishShopName'),
      categoryId: JsonUtils.parseString(json, 'categoryId'),
      categoryName: JsonUtils.parseString(json, 'categoryName'),
      englishCategoryName: JsonUtils.parseString(json, 'englishCategoryName'),
      status: JsonUtils.parseInt(json, 'status'),
      statusName: JsonUtils.parseString(json, 'statusName'),
      statusDesc: JsonUtils.parseString(json, 'statusDesc'),
      statusEnglishName: JsonUtils.parseString(json, 'statusEnglishName'),
      statusEnglishDesc: JsonUtils.parseString(json, 'statusEnglishDesc'),
      statusGroup: JsonUtils.parseInt(json, 'statusGroup'),
      statusGroupName: JsonUtils.parseString(json, 'statusGroupName'),
      payAmount: JsonUtils.parseDouble(json, 'payAmount'),
      actualPayAmount: JsonUtils.parseDouble(json, 'actualPayAmount'),
      estimatedIncome: JsonUtils.parseDouble(json, 'estimatedIncome'),
      createTime: JsonUtils.parseString(json, 'createTime'),
      orderPeriod: JsonUtils.parseInt(json, 'orderPeriod'),
      totalQuantity: JsonUtils.parseInt(json, 'totalQuantity'),
      deliveryMethod: JsonUtils.parseInt(json, 'deliveryMethod'),
      nickname: JsonUtils.parseString(json, 'nickname'),
      mobile: JsonUtils.parseString(json, 'mobile'),
      state: JsonUtils.parseString(json, 'state'),
      address: JsonUtils.parseString(json, 'address'),
      detailAddress: JsonUtils.parseString(json, 'detailAddress'),
      mealDeliveryTime: JsonUtils.parseString(json, 'mealDeliveryTime'),
      payTime: JsonUtils.parseString(json, 'payTime'),
      refundAmount: JsonUtils.parseDouble(json, 'refundAmount'),
      applyRefundTime: JsonUtils.parseString(json, 'applyRefundTime'),
      refundReason: JsonUtils.parseString(json, 'refundReason'),
      rejectRefundReason: JsonUtils.parseString(json, 'rejectRefundReason'),
      responseRefundTime: JsonUtils.parseString(json, 'responseRefundTime'),
      finishRefundTime: JsonUtils.parseString(json, 'finishRefundTime'),
      driverMobile: JsonUtils.parseString(json, 'driverMobile'),
      commentMark: JsonUtils.parseBool(json, 'commentMark'),
      items: JsonUtils.parseList(
        json,
        'items',
        (e) => OrderItemPageRespVO.fromJson(e),
      ),
    );
  }

  /// 根据当前语言设置返回合适的店铺名称
  String getLocalizedShopName(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'zh') {
      return shopName ?? englishShopName ?? '';
    } else {
      return englishShopName ?? shopName ?? '';
    }
  }

  /// 根据当前语言设置返回合适的分类名称
  String getLocalizedCategoryName(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'zh') {
      return categoryName ?? englishCategoryName ?? '';
    } else {
      return englishCategoryName ?? categoryName ?? '';
    }
  }

  /// 根据当前语言设置返回合适的订单状态名称
  String getLocalizedStatusName(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'zh') {
      return statusName ?? statusEnglishName ?? '';
    } else {
      return statusEnglishName ?? statusName ?? '';
    }
  }

  /// 根据当前语言设置返回合适的订单状态描述
  String getLocalizedStatusDesc(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'zh') {
      return statusDesc ?? statusEnglishDesc ?? '';
    } else {
      return statusEnglishDesc ?? statusDesc ?? '';
    }
  }
}

class OrderItemPageRespVO {
  final String? productId;
  final String? productName;
  final String? englishProductName;
  final String? imageThumbnail;
  final List<String>? detailImages;
  final int? quantity;
  final double? productPrice;
  final double? price;
  final List<SelectedSkuRespVO>? selectedSkus;

  OrderItemPageRespVO({
    this.productId,
    this.productName,
    this.englishProductName,
    this.imageThumbnail,
    this.detailImages,
    this.quantity,
    this.productPrice,
    this.price,
    this.selectedSkus,
  });

  factory OrderItemPageRespVO.fromJson(Map<String, dynamic> json) {
    return OrderItemPageRespVO(
      productId: JsonUtils.parseString(json, 'productId'),
      productName: JsonUtils.parseString(json, 'productName'),
      englishProductName: JsonUtils.parseString(json, 'englishProductName'),
      imageThumbnail: JsonUtils.parseString(json, 'imageThumbnail'),
      detailImages:
          json['detailImages'] is List
              ? (json['detailImages'] as List).whereType<String>().toList()
              : null,
      quantity: JsonUtils.parseInt(json, 'quantity'),
      productPrice: JsonUtils.parseDouble(json, 'productPrice'),
      price: JsonUtils.parseDouble(json, 'price'),
      selectedSkus: JsonUtils.parseList(
        json,
        'selectedSkus',
        (e) => SelectedSkuRespVO.fromJson(e),
      ),
    );
  }

  /// 根据当前语言设置返回合适的产品名称
  String getLocalizedProductName(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'zh') {
      return productName ?? englishProductName ?? '';
    } else {
      return englishProductName ?? productName ?? '';
    }
  }
}

class SelectedSkuRespVO {
  final String? id;
  final String? skuName;
  final String? englishSkuName;
  final double? skuPrice;
  final int? skuGroupId;
  final int? skuGroupType;

  SelectedSkuRespVO({
    this.id,
    this.skuName,
    this.englishSkuName,
    this.skuPrice,
    this.skuGroupId,
    this.skuGroupType,
  });

  factory SelectedSkuRespVO.fromJson(Map<String, dynamic> json) {
    return SelectedSkuRespVO(
      id: JsonUtils.parseString(json, 'id'),
      skuName: JsonUtils.parseString(json, 'skuName'),
      englishSkuName: JsonUtils.parseString(json, 'englishSkuName'),
      skuPrice: JsonUtils.parseDouble(json, 'skuPrice'),
      skuGroupId: JsonUtils.parseInt(json, 'skuGroupId'),
      skuGroupType: JsonUtils.parseInt(json, 'skuGroupType'),
    );
  }

  /// 根据当前语言设置返回合适的SKU名称
  String getLocalizedSkuName(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'zh') {
      return skuName ?? englishSkuName ?? '';
    } else {
      return englishSkuName ?? skuName ?? '';
    }
  }
}

class AppTradeOrderDetailRespVO {
  final String? orderNo;
  final int? userId;
  final String? nickname;
  final String? contactPhone;
  final String? reserveName;
  final String? reserveMobile;
  final double? distance;
  final String? deliveryAddress;
  final String? state;
  final String? address;
  final String? detailAddress;
  final String? shopId;
  final String? shopName;
  final String? englishShopName;
  final int? categoryId;
  final String? categoryName;
  final String? englishCategoryName;
  final int? status;
  final String? statusName;
  final String? statusDesc;
  final String? statusEnglishName;
  final String? statusEnglishDesc;
  final int? statusGroup;
  final String? statusGroupName;
  final double? mealSubtotal;
  final double? taxAmount;
  final double? serviceFee;
  final double? deliveryFee;
  final double? deliveryTip;
  final double? couponAmount;
  final double? payAmount;
  final double? actualPayAmount;
  final double? estimatedIncome;
  final int? payType;
  final String? payTypeName;
  final int? deliveryMethod;
  final String? deliveryMethodName;
  final int? orderSource;
  final String? comment;
  final String? diningDate;
  final String? deliveryTime;
  final String? mealDeliveryTime;
  final String? createTime;
  final String? payTime;
  final int? orderPeriod;
  final String? refundNo;
  final double? refundAmount;
  final String? applyRefundTime;
  final String? refundReason;
  final String? rejectRefundReason;
  final String? responseRefundTime;
  final String? finishRefundTime;
  final String? cancelReason;
  final DeliveredConfirmInfoVO? deliveredConfirmInfo;
  final StripePaymentMethodInfoVO? stripePaymentMethodInfo;
  final List<OrderItemDetailVO>? items;

  AppTradeOrderDetailRespVO({
    this.orderNo,
    this.userId,
    this.nickname,
    this.contactPhone,
    this.reserveName,
    this.reserveMobile,
    this.distance,
    this.deliveryAddress,
    this.state,
    this.address,
    this.detailAddress,
    this.shopId,
    this.shopName,
    this.englishShopName,
    this.categoryId,
    this.categoryName,
    this.englishCategoryName,
    this.status,
    this.statusName,
    this.statusDesc,
    this.statusEnglishName,
    this.statusEnglishDesc,
    this.statusGroup,
    this.statusGroupName,
    this.mealSubtotal,
    this.taxAmount,
    this.serviceFee,
    this.deliveryFee,
    this.deliveryTip,
    this.couponAmount,
    this.payAmount,
    this.actualPayAmount,
    this.estimatedIncome,
    this.payType,
    this.payTypeName,
    this.deliveryMethod,
    this.deliveryMethodName,
    this.orderSource,
    this.comment,
    this.diningDate,
    this.deliveryTime,
    this.mealDeliveryTime,
    this.createTime,
    this.payTime,
    this.orderPeriod,
    this.refundNo,
    this.refundAmount,
    this.applyRefundTime,
    this.refundReason,
    this.rejectRefundReason,
    this.responseRefundTime,
    this.finishRefundTime,
    this.cancelReason,
    this.deliveredConfirmInfo,
    this.stripePaymentMethodInfo,
    this.items,
  });

  factory AppTradeOrderDetailRespVO.fromJson(Map<String, dynamic> json) {
    return AppTradeOrderDetailRespVO(
      orderNo: JsonUtils.parseString(json, 'orderNo'),
      userId: JsonUtils.parseInt(json, 'userId'),
      nickname: JsonUtils.parseString(json, 'nickname'),
      contactPhone: JsonUtils.parseString(json, 'contactPhone'),
      reserveName: JsonUtils.parseString(json, 'reserveName'),
      reserveMobile: JsonUtils.parseString(json, 'reserveMobile'),
      distance: JsonUtils.parseDouble(json, 'distance'),
      deliveryAddress: JsonUtils.parseString(json, 'deliveryAddress'),
      state: JsonUtils.parseString(json, 'state'),
      address: JsonUtils.parseString(json, 'address'),
      detailAddress: JsonUtils.parseString(json, 'detailAddress'),
      shopId: JsonUtils.parseString(json, 'shopId'),
      shopName: JsonUtils.parseString(json, 'shopName'),
      englishShopName: JsonUtils.parseString(json, 'englishShopName'),
      categoryId: JsonUtils.parseInt(json, 'categoryId'),
      categoryName: JsonUtils.parseString(json, 'categoryName'),
      englishCategoryName: JsonUtils.parseString(json, 'englishCategoryName'),
      status: JsonUtils.parseInt(json, 'status'),
      statusName: JsonUtils.parseString(json, 'statusName'),
      statusDesc: JsonUtils.parseString(json, 'statusDesc'),
      statusEnglishName: JsonUtils.parseString(json, 'statusEnglishName'),
      statusEnglishDesc: JsonUtils.parseString(json, 'statusEnglishDesc'),
      statusGroup: JsonUtils.parseInt(json, 'statusGroup'),
      statusGroupName: JsonUtils.parseString(json, 'statusGroupName'),
      mealSubtotal: JsonUtils.parseDouble(json, 'mealSubtotal'),
      taxAmount: JsonUtils.parseDouble(json, 'taxAmount'),
      serviceFee: JsonUtils.parseDouble(json, 'serviceFee'),
      deliveryFee: JsonUtils.parseDouble(json, 'deliveryFee'),
      deliveryTip: JsonUtils.parseDouble(json, 'deliveryTip'),
      couponAmount: JsonUtils.parseDouble(json, 'couponAmount'),
      payAmount: JsonUtils.parseDouble(json, 'payAmount'),
      actualPayAmount: JsonUtils.parseDouble(json, 'actualPayAmount'),
      estimatedIncome: JsonUtils.parseDouble(json, 'estimatedIncome'),
      payType: JsonUtils.parseInt(json, 'payType'),
      payTypeName: JsonUtils.parseString(json, 'payTypeName'),
      deliveryMethod: JsonUtils.parseInt(json, 'deliveryMethod'),
      deliveryMethodName: JsonUtils.parseString(json, 'deliveryMethodName'),
      orderSource: JsonUtils.parseInt(json, 'orderSource'),
      comment: JsonUtils.parseString(json, 'comment'),
      diningDate: JsonUtils.parseString(json, 'diningDate'),
      deliveryTime: JsonUtils.parseString(json, 'deliveryTime'),
      mealDeliveryTime: JsonUtils.parseString(json, 'mealDeliveryTime'),
      createTime: JsonUtils.parseString(json, 'createTime'),
      payTime: JsonUtils.parseString(json, 'payTime'),
      orderPeriod: JsonUtils.parseInt(json, 'orderPeriod'),
      refundNo: JsonUtils.parseString(json, 'refundNo'),
      refundAmount: JsonUtils.parseDouble(json, 'refundAmount'),
      applyRefundTime: JsonUtils.parseString(json, 'applyRefundTime'),
      refundReason: JsonUtils.parseString(json, 'refundReason'),
      rejectRefundReason: JsonUtils.parseString(json, 'rejectRefundReason'),
      responseRefundTime: JsonUtils.parseString(json, 'responseRefundTime'),
      finishRefundTime: JsonUtils.parseString(json, 'finishRefundTime'),
      cancelReason: JsonUtils.parseString(json, 'cancelReason'),
      deliveredConfirmInfo:
          json['deliveredConfirmInfo'] != null
              ? DeliveredConfirmInfoVO.fromJson(json['deliveredConfirmInfo'])
              : null,
      stripePaymentMethodInfo:
          json['stripePaymentMethodInfo'] != null
              ? StripePaymentMethodInfoVO.fromJson(
                json['stripePaymentMethodInfo'],
              )
              : null,
      items: JsonUtils.parseList(
        json,
        'items',
        (e) => OrderItemDetailVO.fromJson(e),
      ),
    );
  }

  /// 根据当前语言设置返回合适的店铺名称
  String getLocalizedShopName(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'zh') {
      return shopName ?? englishShopName ?? '';
    } else {
      return englishShopName ?? shopName ?? '';
    }
  }

  /// 根据当前语言设置返回合适的分类名称
  String getLocalizedCategoryName(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'zh') {
      return categoryName ?? englishCategoryName ?? '';
    } else {
      return englishCategoryName ?? categoryName ?? '';
    }
  }

  /// 根据当前语言设置返回合适的订单状态名称
  String getLocalizedStatusName(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'zh') {
      return statusName ?? statusEnglishName ?? '';
    } else {
      return statusEnglishName ?? statusName ?? '';
    }
  }

  /// 根据当前语言设置返回合适的订单状态描述
  String getLocalizedStatusDesc(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'zh') {
      return statusDesc ?? statusEnglishDesc ?? '';
    } else {
      return statusEnglishDesc ?? statusDesc ?? '';
    }
  }
}

class DeliveredConfirmInfoVO {
  final String? deliveryTime;
  final String? deliveryConfirmedImage;

  DeliveredConfirmInfoVO({this.deliveryTime, this.deliveryConfirmedImage});

  factory DeliveredConfirmInfoVO.fromJson(Map<String, dynamic> json) {
    return DeliveredConfirmInfoVO(
      deliveryTime: JsonUtils.parseString(json, 'deliveryTime'),
      deliveryConfirmedImage: JsonUtils.parseString(
        json,
        'deliveryConfirmedImage',
      ),
    );
  }
}

class StripePaymentMethodInfoVO {
  final String? paymentMethodId;
  final String? stripePaymentMethodId;
  final String? cardBrand;
  final String? cardLast4;
  final int? cardExpMonth;
  final int? cardExpYear;

  StripePaymentMethodInfoVO({
    this.paymentMethodId,
    this.stripePaymentMethodId,
    this.cardBrand,
    this.cardLast4,
    this.cardExpMonth,
    this.cardExpYear,
  });

  factory StripePaymentMethodInfoVO.fromJson(Map<String, dynamic> json) {
    return StripePaymentMethodInfoVO(
      paymentMethodId: JsonUtils.parseString(json, 'paymentMethodId'),
      stripePaymentMethodId: JsonUtils.parseString(
        json,
        'stripePaymentMethodId',
      ),
      cardBrand: JsonUtils.parseString(json, 'cardBrand'),
      cardLast4: JsonUtils.parseString(json, 'cardLast4'),
      cardExpMonth: JsonUtils.parseInt(json, 'cardExpMonth'),
      cardExpYear: JsonUtils.parseInt(json, 'cardExpYear'),
    );
  }
}

class OrderItemDetailVO {
  final String? productId;
  final String? productName;
  final String? englishProductName;
  final String? imageThumbnail;
  final List<String>? detailImages;
  final int? quantity;
  final double? productPrice;
  final double? price;
  final double? subTotalPrice;
  final bool? hotMark;
  final bool? newMark;
  final List<SelectedSkuRespVO>? selectedSkus;
  final String? picUrl;

  OrderItemDetailVO({
    this.productId,
    this.productName,
    this.englishProductName,
    this.imageThumbnail,
    this.detailImages,
    this.quantity,
    this.productPrice,
    this.price,
    this.subTotalPrice,
    this.hotMark,
    this.newMark,
    this.selectedSkus,
    this.picUrl,
  });

  factory OrderItemDetailVO.fromJson(Map<String, dynamic> json) {
    return OrderItemDetailVO(
      productId: JsonUtils.parseString(json, 'productId'),
      productName: JsonUtils.parseString(json, 'productName'),
      englishProductName: JsonUtils.parseString(json, 'englishProductName'),
      imageThumbnail: JsonUtils.parseString(json, 'imageThumbnail'),
      detailImages:
          json['detailImages'] is List
              ? (json['detailImages'] as List).whereType<String>().toList()
              : null,
      quantity: JsonUtils.parseInt(json, 'quantity'),
      productPrice: JsonUtils.parseDouble(json, 'productPrice'),
      price: JsonUtils.parseDouble(json, 'price'),
      subTotalPrice: JsonUtils.parseDouble(json, 'subTotalPrice'),
      hotMark: JsonUtils.parseBool(json, 'hotMark'),
      newMark: JsonUtils.parseBool(json, 'newMark'),
      selectedSkus: JsonUtils.parseList(
        json,
        'selectedSkus',
        (e) => SelectedSkuRespVO.fromJson(e),
      ),
      picUrl: JsonUtils.parseString(json, 'picUrl'),
    );
  }

  /// 根据当前语言设置返回合适的产品名称
  String getLocalizedProductName(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'zh') {
      return productName ?? englishProductName ?? '';
    } else {
      return englishProductName ?? productName ?? '';
    }
  }
}

class AppTradeRefundReasonRespVO {
  final int? id;
  final String? reasonChinese;
  final String? reasonEnglish;
  final int? sort;
  final int? reasonCategory;

  AppTradeRefundReasonRespVO({
    this.id,
    this.reasonChinese,
    this.reasonEnglish,
    this.sort,
    this.reasonCategory,
  });

  factory AppTradeRefundReasonRespVO.fromJson(Map<String, dynamic> json) {
    return AppTradeRefundReasonRespVO(
      id: JsonUtils.parseInt(json, 'id'),
      reasonChinese: JsonUtils.parseString(json, 'reasonChinese'),
      reasonEnglish: JsonUtils.parseString(json, 'reasonEnglish'),
      sort: JsonUtils.parseInt(json, 'sort'),
      reasonCategory: JsonUtils.parseInt(json, 'reasonCategory'),
    );
  }
}
