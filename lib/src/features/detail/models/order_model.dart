import '../../../core/utils/json_utils.dart';

/// 优惠券选择结果
class CouponSelectionResult {
  final String couponId;
  final double discountAmount;

  CouponSelectionResult({required this.couponId, required this.discountAmount});

  /// 特殊标记：用户主动移除优惠券
  static final CouponSelectionResult removed = CouponSelectionResult(
    couponId: '__REMOVED__',
    discountAmount: 0.0,
  );

  /// 判断是否为移除标记
  bool get isRemoved => couponId == '__REMOVED__';
}

/// 将 DateTime 转换为 YYYY-MM-DD 格式的字符串
String formatDiningDate(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

/// 将 YYYY-MM-DD 格式的字符串转换为 DateTime
DateTime? parseDiningDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return null;
  try {
    final parts = dateStr.split('-');
    if (parts.length == 3) {
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }
  } catch (e) {
    // 解析失败返回 null
  }
  return null;
}

double formatPrice(double? price) {
  if (price == null) return 0.0;
  // 使用标准四舍五入：将价格乘以100，四舍五入到整数，再除以100
  return (price * 100).round() / 100;
}

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

  ///配送方式：1-门店配送；2-到店自取 固定为1
  final int deliveryMethod;

  ///配送时间
  final String deliveryTime;

  ///配送小费
  final double deliveryTip;

  ///用餐日期
  final String diningDate;

  ///订单商品列表
  final List<OrderItem> items;

  ///餐品小计
  final double mealSubtotal;

  ///订单来源：1-APP；2-PC 固定为1
  final int orderSource;

  ///应付款金额（即订单金额）
  final double payAmount;

  ///支付方式：1-Stripe 暂不处理 固定为1
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
    'diningDate': diningDate,
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
  ///商品ID
  final String productId;

  ///商品名称
  final String productName;

  ///英文商品名称
  final String? englishProductName;

  ///商品数量
  final int quantity;

  ///产品价格，不含规格附加价格（单位：美元）
  final double productPrice;

  ///售价（单位：美元）
  final double price;

  ///选择的规格SKU列表（可选）
  final List<SelectedSkuVO>? selectedSkus;

  OrderItem({
    required this.productId,
    required this.productName,
    this.englishProductName,
    required this.quantity,
    required this.productPrice,
    required this.price,
    this.selectedSkus,
  });

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    if (englishProductName != null) 'englishProductName': englishProductName,
    'quantity': quantity,
    'productPrice': productPrice,
    'price': price,
    if (selectedSkus != null && selectedSkus!.isNotEmpty)
      'selectedSkus': selectedSkus!.map((e) => e.toJson()).toList(),
  };
}

/// 购物车选择的SKU
class SelectedSkuVO {
  ///SKU ID
  final String id;

  ///SKU名称
  final String skuName;

  ///SKU英文名称
  final String? englishSkuName;

  ///SKU价格（该SKU的总价 = 商品基础价 + SKU附加价，单位：美元）
  final double skuPrice;

  ///SKU分组ID
  final int? skuGroupId;

  ///SKU分组类型：1=可叠加，2=互斥
  final int? skuGroupType;

  SelectedSkuVO({
    required this.id,
    required this.skuName,
    this.englishSkuName,
    required this.skuPrice,
    this.skuGroupId,
    this.skuGroupType,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'skuName': skuName,
    if (englishSkuName != null) 'englishSkuName': englishSkuName,
    'skuPrice': skuPrice,
    if (skuGroupId != null) 'skuGroupId': skuGroupId,
    if (skuGroupType != null) 'skuGroupType': skuGroupType,
  };
}

/// 添加购物车参数
class AddCartParams {
  ///店铺ID
  final String shopId;

  ///商品ID
  final String productId;

  ///商品名称
  final String productName;

  ///英文商品名称
  final String? englishProductName;

  ///选择的SKU列表
  final List<SelectedSkuVO>? selectedSkus;

  ///数量
  final int quantity;

  ///用餐日期 (格式: YYYY-MM-DD)
  final String diningDate;

  ///商品基础价格
  final double? productPrice;

  AddCartParams({
    required this.shopId,
    required this.productId,
    required this.productName,
    this.englishProductName,
    this.selectedSkus,
    required this.quantity,
    required this.diningDate,
    this.productPrice,
  });

  Map<String, dynamic> toJson() {
    // 如果有SKU，需要计算附加价发送给后端
    // SKU附加价 = SKU总价 - 商品基础价
    List<Map<String, dynamic>>? skusToSend;
    if (selectedSkus != null &&
        selectedSkus!.isNotEmpty &&
        productPrice != null) {
      skusToSend =
          selectedSkus!.map((sku) {
            final additionalPrice = sku.skuPrice - productPrice!;
            return {
              'id': sku.id,
              'skuName': sku.skuName,
              if (sku.englishSkuName != null)
                'englishSkuName': sku.englishSkuName,
              'skuPrice': additionalPrice > 0 ? additionalPrice : 0, // 发送附加价
              if (sku.skuGroupId != null) 'skuGroupId': sku.skuGroupId,
              if (sku.skuGroupType != null) 'skuGroupType': sku.skuGroupType,
            };
          }).toList();
    }

    return {
      'shopId': shopId,
      'productId': productId,
      'productName': productName,
      if (englishProductName != null) 'englishProductName': englishProductName,
      if (skusToSend != null && skusToSend.isNotEmpty)
        'selectedSkus': skusToSend,
      'quantity': quantity,
      'diningDate': diningDate,
      // 注意：不发送 productPrice 给后端，后端会根据 productId 自己查询价格
    };
  }
}

/// 获取购物车列表参数
class GetCartListQuery {
  ///用餐日期 (格式: YYYY-MM-DD)
  final String diningDate;

  ///店铺ID
  final String shopId;

  GetCartListQuery({required this.diningDate, required this.shopId});

  Map<String, dynamic> toJson() => {'diningDate': diningDate, 'shopId': shopId};
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

/// 购物车商品SKU信息
class CartItemSku {
  ///SKU ID
  final String? id;

  ///SKU名称（规格名称）
  final String? skuName;

  ///英文规格名称
  final String? englishSkuName;

  ///规格附加价格
  final double? skuPrice;

  ///规格分组ID，1 表示通用附加
  final int? skuGroupId;

  ///规格分组类型：1-可叠加；2-互斥
  final int? skuGroupType;

  ///状态：0=停售，1=在售
  final int? status;

  CartItemSku({
    this.id,
    this.skuName,
    this.englishSkuName,
    this.skuPrice,
    this.skuGroupId,
    this.skuGroupType,
    this.status,
  });

  factory CartItemSku.fromJson(Map<String, dynamic> json) {
    return CartItemSku(
      id: json['id'] as String?,
      skuName: json['skuName'] as String?,
      englishSkuName: json['englishSkuName'] as String?,
      skuPrice: JsonUtils.parseDouble(json, 'skuPrice'),
      skuGroupId: JsonUtils.parseInt(json, 'skuGroupId'),
      skuGroupType: JsonUtils.parseInt(json, 'skuGroupType'),
      status: JsonUtils.parseInt(json, 'status'),
    );
  }
}

// 购物车列表返回值
class CartItemModel {
  ///创建时间
  final DateTime? createTime;

  ///用餐日期 (格式: YYYY-MM-DD)
  final String? diningDate;

  ///主键ID
  final String? id;

  ///商品缩略图（商品封面图）
  final String? imageThumbnail;

  ///商品单价（包含SKU后的总价）
  final double? price;

  ///商品基础价格（不含SKU）
  final double? productPrice;

  ///商品ID
  final String? productId;

  ///商品名称
  final String? productName;

  ///英文商品名称
  final String? englishProductName;

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

  ///选择的SKU规格列表（用户实际选择的SKU）
  final List<CartItemSku>? selectedSkus;

  ///该商品下的所有SKU规格列表（仅供参考）
  final List<CartItemSku>? skus;

  CartItemModel({
    this.createTime,
    this.diningDate,
    this.id,
    this.imageThumbnail,
    this.price,
    this.productPrice,
    this.productId,
    this.productName,
    this.englishProductName,
    this.productSpecId,
    this.productSpecName,
    this.quantity,
    this.shopId,
    this.skuSetting,
    this.userId,
    this.selectedSkus,
    this.skus,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    // 解析 selectedSkus
    final selectedSkus = JsonUtils.parseList<CartItemSku>(
      json,
      'selectedSkus',
      (e) => CartItemSku.fromJson(e),
    );

    // 如果后端没有返回 productSpecId，则从 selectedSkus 中获取第一个 SKU 的 ID
    // 或者使用 productId 作为后备
    String? productSpecId = json['productSpecId'] as String?;
    if (productSpecId == null || productSpecId.isEmpty) {
      if (selectedSkus != null && selectedSkus.isNotEmpty) {
        productSpecId = selectedSkus.first.id;
      } else {
        productSpecId = json['productId'] as String?;
      }
    }

    return CartItemModel(
      createTime: JsonUtils.parseDateTime(json, 'createTime'),
      diningDate: JsonUtils.parseString(json, 'diningDate'), // 格式: YYYY-MM-DD
      id: json['id'] as String?,
      imageThumbnail: json['imageThumbnail'] as String?,
      price: JsonUtils.parseDouble(json, 'price'),
      productPrice: JsonUtils.parseDouble(json, 'productPrice'),
      productId: json['productId'] as String?,
      productName: json['productName'] as String?,
      englishProductName: json['englishProductName'] as String?,
      productSpecId: productSpecId,
      productSpecName: json['productSpecName'] as String?,
      quantity: JsonUtils.parseInt(json, 'quantity'),
      shopId: json['shopId'] as String?,
      skuSetting: JsonUtils.parseInt(json, 'skuSetting'),
      userId: JsonUtils.parseInt(json, 'userId'),
      selectedSkus: selectedSkus,
      skus: JsonUtils.parseList<CartItemSku>(
        json,
        'skus',
        (e) => CartItemSku.fromJson(e),
      ),
    );
  }

  CartItemModel copyWith({
    DateTime? createTime,
    String? diningDate, // 格式: YYYY-MM-DD
    String? id,
    String? imageThumbnail,
    double? price,
    String? productId,
    String? productName,
    String? englishProductName,
    String? productSpecId,
    String? productSpecName,
    int? quantity,
    String? shopId,
    int? skuSetting,
    int? userId,
    List<CartItemSku>? selectedSkus,
    List<CartItemSku>? skus,
  }) {
    return CartItemModel(
      createTime: createTime ?? this.createTime,
      diningDate: diningDate ?? this.diningDate,
      id: id ?? this.id,
      imageThumbnail: imageThumbnail ?? this.imageThumbnail,
      price: price ?? this.price,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      englishProductName: englishProductName ?? this.englishProductName,
      productSpecId: productSpecId ?? this.productSpecId,
      productSpecName: productSpecName ?? this.productSpecName,
      quantity: quantity ?? this.quantity,
      shopId: shopId ?? this.shopId,
      skuSetting: skuSetting ?? this.skuSetting,
      userId: userId ?? this.userId,
      selectedSkus: selectedSkus ?? this.selectedSkus,
      skus: skus ?? this.skus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (createTime != null) 'createTime': createTime!.toIso8601String(),
      if (diningDate != null) 'diningDate': diningDate!, // 已经是字符串格式
      'id': id,
      'imageThumbnail': imageThumbnail,
      'price': price,
      'productId': productId,
      'productName': productName,
      if (englishProductName != null) 'englishProductName': englishProductName,
      'productSpecId': productSpecId,
      'productSpecName': productSpecName,
      'quantity': quantity,
      'shopId': shopId,
      'skuSetting': skuSetting,
      'userId': userId,
      if (selectedSkus != null) 'selectedSkus': selectedSkus,
      if (skus != null) 'skus': skus,
    };
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
      deliveryFeePerMile: JsonUtils.parseDouble(json, 'deliveryFeePerMile'),
      distance: JsonUtils.parseDouble(json, 'distance'),
      estimatedDeliveryFee: JsonUtils.parseDouble(json, 'estimatedDeliveryFee'),
      shopId: JsonUtils.parseString(json, 'shopId'),
      shopName: JsonUtils.parseString(json, 'shopName'),
    );
  }
}
