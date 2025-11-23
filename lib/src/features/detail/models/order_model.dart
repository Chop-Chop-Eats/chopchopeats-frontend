import '../../../core/utils/json_utils.dart';

/// 创建订单参数
class CreateOrderParams {
  ///订单备注（可选）
  final String? comment;

  ///优惠券抵扣金额（可选）
  final double? couponAmount;

  ///配送地址ID（门店配送时必填）
  final int? deliveryAddressId;

  ///配送费
  final double deliveryFee;

  ///配送方式：1-门店配送；2-到店自取
  final int deliveryMethod;

  ///配送时间
  final String deliveryTime;

  ///配送小费
  final double deliveryTip;

  ///用餐日期
  final DateTime diningDate;

  ///订单商品列表
  final List<OrderItem> items;

  ///餐品小计
  final double mealSubtotal;

  ///订单来源：1-APP；2-PC
  final int orderSource;

  ///应付款金额（即订单金额）
  final double payAmount;

  ///支付方式：1-Stripe
  final int payType;

  ///服务费
  final double serviceFee;

  ///商户ID
  final String shopId;

  ///税费
  final double taxAmount;

  ///配送小费率
  final double tipRate;

  ///用户优惠券ID（可选）
  final String? userCouponId;

  CreateOrderParams({
    this.comment,
    this.couponAmount,
    this.deliveryAddressId,
    required this.deliveryFee,
    required this.deliveryMethod,
    required this.deliveryTime,
    required this.deliveryTip,
    required this.diningDate,
    required this.items,
    required this.mealSubtotal,
    required this.orderSource,
    required this.payAmount,
    required this.payType,
    required this.serviceFee,
    required this.shopId,
    required this.taxAmount,
    required this.tipRate,
    this.userCouponId,
  });

  Map<String, dynamic> toJson() => {
    if (comment != null) 'comment': comment,
    if (couponAmount != null) 'couponAmount': couponAmount,
    if (deliveryAddressId != null) 'deliveryAddressId': deliveryAddressId,
    'deliveryAddressId': deliveryAddressId,
    'deliveryFee': deliveryFee,
    'deliveryMethod': deliveryMethod,
    'deliveryTime': deliveryTime,
    'deliveryTip': deliveryTip,
    'diningDate': diningDate.toIso8601String(),
    if (items.isNotEmpty) 'items': items.map((e) => e.toJson()).toList(),
    'mealSubtotal': mealSubtotal,
    'orderSource': orderSource,
    'payAmount': payAmount,
    'payType': payType,
    'serviceFee': serviceFee,
    'shopId': shopId,
    'taxAmount': taxAmount,
    'tipRate': tipRate,
    if (userCouponId != null) 'userCouponId': userCouponId,
  };
}

/// 订单商品项
class OrderItem {
  ///原价（单位：美元）
  final double? originalPrice;

  ///售价（单位：美元）
  final double price;

  ///商品ID
  final String productId;

  ///商品名称
  final String productName;

  ///商品规格ID
  final String productSpecId;

  ///商品规格名称
  final String productSpecName;

  ///商品数量
  final int quantity;

  OrderItem({
    this.originalPrice,
    required this.price,
    required this.productId,
    required this.productName,
    required this.productSpecId,
    required this.productSpecName,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
    if (originalPrice != null) 'originalPrice': originalPrice,
    'price': price,
    'productId': productId,
    'productName': productName,
    'productSpecId': productSpecId,
    'productSpecName': productSpecName,
    'quantity': quantity,
  };
}

/// 添加购物车参数
class AddCartParams {
  ///用餐日期
  final DateTime diningDate;

  ///商品ID
  final String productId;

  ///商品名称
  final String productName;

  ///产品规格ID
  final String productSpecId;

  ///商品规格名称
  final String productSpecName;

  ///数量
  final int quantity;

  ///店铺ID
  final String shopId;

  AddCartParams({
    required this.diningDate,
    required this.productId,
    required this.productName,
    required this.productSpecId,
    required this.productSpecName,
    required this.quantity,
    required this.shopId,
  });

  Map<String, dynamic> toJson() => {
    'diningDate': diningDate.toIso8601String(),
    'productId': productId,
    'productName': productName,
    'productSpecId': productSpecId,
    'productSpecName': productSpecName,
    'quantity': quantity,
    'shopId': shopId,
  };
}

/// 获取购物车列表参数
class GetCartListQuery {
  ///用餐日期
  final DateTime diningDate;

  ///店铺ID
  final String shopId;

  GetCartListQuery({required this.diningDate, required this.shopId});

  Map<String, dynamic> toJson() => {
    'diningDate': diningDate.toIso8601String(),
    'shopId': shopId,
  };
}

/// 更新购物车数量
class UpdateCartParams {
  ///购物车ID
  final String cartId;

  ///数量
  final int quantity;

  UpdateCartParams({required this.cartId, required this.quantity});

  Map<String, dynamic> toJson() => {'cartId': cartId, 'quantity': quantity};
}

// 购物车列表返回值
class CartItemModel {
  ///创建时间
  final DateTime? createTime;

  ///用餐日期
  final DateTime? diningDate;

  ///主键ID
  final String? id;

  ///商品缩略图（商品封面图）
  final String? imageThumbnail;

  ///商品单价
  final double? price;

  ///商品ID
  final String? productId;

  ///商品名称
  final String? productName;

  ///产品规格ID
  final String? productSpecId;

  ///商品规格名称
  final String? productSpecName;

  ///数量
  final int? quantity;

  ///店铺ID
  final String? shopId;

  ///SKU规格设置：0=不区分规格，1=区分规格
  final int? skuSetting;

  ///用户ID
  final int? userId;

  CartItemModel({
    this.createTime,
    this.diningDate,
    this.id,
    this.imageThumbnail,
    this.price,
    this.productId,
    this.productName,
    this.productSpecId,
    this.productSpecName,
    this.quantity,
    this.shopId,
    this.skuSetting,
    this.userId,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      createTime: JsonUtils.parseDateTime(json, 'createTime'),
      diningDate: JsonUtils.parseDateTime(json, 'diningDate'),
      id: json['id'],
      imageThumbnail: json['imageThumbnail'],
      price: json['price'],
      productId: json['productId'],
      productName: json['productName'],
      productSpecId: json['productSpecId'],
      productSpecName: json['productSpecName'],
      quantity: json['quantity'],
      shopId: json['shopId'],
      skuSetting: json['skuSetting'],
      userId: json['userId'],
    );
  }
}

/// SPI返回值
class SPIModel {
  ///Client Secret
  final String? clientSecret;

  ///订单编号
  final String? orderNo;

  ///PaymentIntent ID
  final String? paymentIntentId;

  ///可发布密钥（前端需要）
  final String? publishableKey;

  ///支付状态
  final String? status;

  SPIModel({
    this.clientSecret,
    this.orderNo,
    this.paymentIntentId,
    this.publishableKey,
    this.status,
  });

  factory SPIModel.fromJson(Map<String, dynamic> json) {
    return SPIModel(
      clientSecret: json['clientSecret'],
      orderNo: json['orderNo'],
      paymentIntentId: json['paymentIntentId'],
      publishableKey: json['publishableKey'],
      status: json['status'],
    );
  }
}

/// 计算配送预估费用请求参数
class DeliveryFeeQuery {
  ///纬度
  final double latitude;

  ///经度
  final double longitude;

  ///店铺ID
  final String shopId;

  DeliveryFeeQuery({
    required this.latitude,
    required this.longitude,
    required this.shopId,
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'shopId': shopId,
  };
}

/// 计算配送预估费用返回值
class DeliveryFeeModel {
  ///每英里配送费用
  final double? deliveryFeePerMile;

  ///配送距离（英里）
  final double? distance;

  ///预估配送费用
  final double? estimatedDeliveryFee;

  ///店铺ID
  final String? shopId;

  ///店铺名称
  final String? shopName;

  DeliveryFeeModel({
    this.deliveryFeePerMile,
    this.distance,
    this.estimatedDeliveryFee,
    this.shopId,
    this.shopName,
  });

  factory DeliveryFeeModel.fromJson(Map<String, dynamic> json) {
    return DeliveryFeeModel(
      deliveryFeePerMile: json['deliveryFeePerMile'],
      distance: json['distance'],
      estimatedDeliveryFee: json['estimatedDeliveryFee'],
      shopId: json['shopId'],
      shopName: json['shopName'],
    );
  }
}
