import '../../../core/utils/json_utils.dart';

class CouponListQuery {
  final int pageNo;
  final int pageSize;
  final int? status;
  final String? shopId;

  CouponListQuery({
    required this.pageNo,
    required this.pageSize,
    this.status,
    this.shopId,
  });

  Map<String, dynamic> toJson() {
    return {
      'pageNo': pageNo,
      'pageSize': pageSize,
      if (status != null) 'status': status,
      if (shopId != null) 'shopId': shopId,
    };
  }
}

/// 分页结果
class CouponListModel {
  ///数据
  final List<CouponGroupItem> list;

  ///总量
  final int total;

  CouponListModel({
    required this.list,
    required this.total,
  });

  factory CouponListModel.fromJson(Map<String, dynamic> json) {
    return CouponListModel(
      list: JsonUtils.parseList<CouponGroupItem>(json, 'list', (e) => CouponGroupItem.fromJson(e)) ?? [],
      total: json['total'],
    );
  }
}

/// 我的优惠券按店铺分组响应
class CouponGroupItem {
  ///该店铺的优惠券列表
  final List<CouponItem>? couponList;

  ///店铺ID
  final String? shopId;

  ///店铺名称
  final String? shopName;

  CouponGroupItem({this.couponList, this.shopId, this.shopName});

  factory CouponGroupItem.fromJson(Map<String, dynamic> json) {
    return CouponGroupItem(
      couponList: JsonUtils.parseList<CouponItem>(json, 'couponList', (e) => CouponItem.fromJson(e)),
      shopId: json['shopId'],
      shopName: json['shopName'],
    );
  }
}

/// 我的优惠券项响应
class CouponItem {
  ///优惠券ID
  final String? couponId;

  ///优惠券标题
  final String? couponTitle;

  ///领取时间
  final DateTime? createTime;

  ///优惠金额
  final double? discountAmount;

  ///用户优惠券记录ID
  final String? id;

  ///是否即将过期
  final bool? isExpiringSoon;

  ///使用条件金额（满减金额）
  final double? minSpendAmount;

  ///使用时间
  final DateTime? redeemedAt;

  ///优惠券的备注信息
  final String? remark;

  ///优惠券状态：0表示未使用，1表示已使用，2表示过期
  final int? status;

  ///状态名称
  final String? statusName;

  ///有效开始时间
  final DateTime? validFrom;

  ///有效截止时间
  final DateTime? validUntil;

  CouponItem({
    this.couponId,
    this.couponTitle,
    this.createTime,
    this.discountAmount,
    this.id,
    this.isExpiringSoon,
    this.minSpendAmount,
    this.redeemedAt,
    this.remark,
    this.status,
    this.statusName,
    this.validFrom,
    this.validUntil,
  });

  factory CouponItem.fromJson(Map<String, dynamic> json) {
    return CouponItem(
      couponId: json['couponId'],
      couponTitle: json['couponTitle'],
      createTime: JsonUtils.parseDateTime(json, 'createTime'),
      discountAmount: JsonUtils.parseDouble(json, 'discountAmount'),
      id: json['id'],
      isExpiringSoon: JsonUtils.parseBool(json, 'isExpiringSoon'),
      minSpendAmount: JsonUtils.parseDouble(json, 'minSpendAmount'),
      redeemedAt: JsonUtils.parseDateTime(json, 'redeemedAt'),
      remark: json['remark'],
      status: json['status'],
      statusName: json['statusName'],
      validFrom: JsonUtils.parseDateTime(json, 'validFrom'),
      validUntil: JsonUtils.parseDateTime(json, 'validUntil'),
    );
  }
}
