import '../../home/models/home_models.dart';
import '../../../core/utils/json_utils.dart';

/// 商户店铺返回
class ShopModel {
  ///门店地址
  final String address;

  ///认证审核ID
  final String? approveReviewId;

  ///审核通过时间
  final DateTime? approveTime;

  ///平均评分
  final double? averageRate;

  ///门店背景图列表
  final List<UploadedFile>? backgroundImage;

  ///店铺分类
  final int? categoryId;

  ///中文店铺介绍
  final String? chineseDescription;

  ///中文店铺名称
  final String chineseShopName;

  ///中文店铺标签列表(返回)
  final List<TagInfo>? chineseTagList;

  ///中文店铺标签(入参)
  final String? chineseTags;

  ///评论条数
  final int? commentCount;

  ///联系电话
  final String contactNumber;

  ///每英里配送费用
  final double? deliveryFeePerMile;

  ///配送方式
  final List<DeliveryMethod>? deliveryMethod;

  ///配送禁止时长（分钟）
  final int? deliveryRestrictionDuration;

  ///详细地址
  final String? detailedAddress;

  ///距离（千米）
  final double? distance;

  ///英文店铺介绍
  final String? englishDescription;

  ///英文店铺名称
  final String englishShopName;

  ///英文店铺标签列表(返回)
  final List<TagInfo>? englishTagList;

  ///英文店铺标签(入参)
  final String? englishTags;

  ///预估配送费用
  final double? estimatedDeliveryFee;

  ///是否收藏/点赞
  final bool? favorite;

  ///店铺编号
  final String id;

  ///所在州
  final String? locationState;

  ///新店开业标识
  final bool? newShopMark;

  ///营业时间列表（店铺设置的开始配送时间）
  final List<OperatingHour>? operatingHours;

  ///平台抽成比例-用户计算服务费
  final double? platformCommissionRate;

  ///店铺评分
  final double? rating;

  ///店铺销量
  final int? salesVolume;

  ///门店logo，封面图
  final String? shopLogo;

  ///店铺状态 0：初始化 1：正常 2：关闭
  final int? shopStatus;

  ///税率 (从merchant_state_tax表获取)
  final double? taxRate;

  ShopModel({
    required this.address,
    this.approveReviewId,
    this.approveTime,
    this.averageRate,
    this.backgroundImage,
    this.categoryId,
    this.chineseDescription,
    required this.chineseShopName,
    this.chineseTagList,
    this.chineseTags,
    this.commentCount,
    required this.contactNumber,
    this.deliveryFeePerMile,
    this.deliveryMethod,
    this.deliveryRestrictionDuration,
    this.detailedAddress,
    this.distance,
    this.englishDescription,
    required this.englishShopName,
    this.englishTagList,
    this.englishTags,
    this.estimatedDeliveryFee,
    this.favorite,
    required this.id,
    this.locationState,
    this.newShopMark,
    this.operatingHours,
    this.platformCommissionRate,
    this.rating,
    this.salesVolume,
    this.shopLogo,
    this.shopStatus,
    this.taxRate,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      address: json['address'],
      approveReviewId: json['approveReviewId'],
      approveTime: JsonUtils.parseDateTime(json, 'approveTime'),
      averageRate: JsonUtils.parseDouble(json, 'averageRate'),
      backgroundImage: JsonUtils.parseList<UploadedFile>(
        json,
        'backgroundImage',
        (e) => UploadedFile.fromJson(e),
      ),
      categoryId: json['categoryId'],
      chineseDescription: json['chineseDescription'],
      chineseShopName: json['chineseShopName'],
      chineseTagList: JsonUtils.parseList<TagInfo>(
        json,
        'chineseTagList',
        (e) => TagInfo.fromJson(e),
      ),
      chineseTags: json['chineseTags'],
      commentCount: json['commentCount'],
      contactNumber: json['contactNumber'],
      deliveryFeePerMile: JsonUtils.parseDouble(json, 'deliveryFeePerMile'),
      deliveryMethod: JsonUtils.parseList<DeliveryMethod>(
        json,
        'deliveryMethod',
        (e) => DeliveryMethod.fromJson(e),
      ),
      deliveryRestrictionDuration: json['deliveryRestrictionDuration'],
      detailedAddress: json['detailedAddress'],
      distance: JsonUtils.parseDouble(json, 'distance'),
      englishDescription: json['englishDescription'],
      englishShopName: json['englishShopName'],
      englishTagList: JsonUtils.parseList<TagInfo>(
        json,
        'englishTagList',
        (e) => TagInfo.fromJson(e),
      ),
      englishTags: json['englishTags'],
      estimatedDeliveryFee: JsonUtils.parseDouble(json, 'estimatedDeliveryFee'),
      favorite: json['favorite'],
      id: json['id'],
      locationState: json['locationState'],
      newShopMark: json['newShopMark'],
      operatingHours: JsonUtils.parseList<OperatingHour>(
        json,
        'operatingHours',
        (e) => OperatingHour.fromJson(e),
      ),
      platformCommissionRate: JsonUtils.parseDouble(json, 'platformCommissionRate'),
      rating: JsonUtils.parseDouble(json, 'rating'),
      salesVolume: json['salesVolume'],
      shopLogo: json['shopLogo'],
      shopStatus: json['shopStatus'],
      taxRate: JsonUtils.parseDouble(json, 'taxRate'),
    );
  }

  /// copyWith 方法，用于创建修改后的副本（主要用于更新收藏状态）
  ShopModel copyWith({
    bool? favorite,
  }) {
    return ShopModel(
      address: address,
      approveReviewId: approveReviewId,
      approveTime: approveTime,
      averageRate: averageRate,
      backgroundImage: backgroundImage,
      categoryId: categoryId,
      chineseDescription: chineseDescription,
      chineseShopName: chineseShopName,
      chineseTagList: chineseTagList,
      chineseTags: chineseTags,
      commentCount: commentCount,
      contactNumber: contactNumber,
      deliveryFeePerMile: deliveryFeePerMile,
      deliveryMethod: deliveryMethod,
      deliveryRestrictionDuration: deliveryRestrictionDuration,
      detailedAddress: detailedAddress,
      distance: distance,
      englishDescription: englishDescription,
      englishShopName: englishShopName,
      englishTagList: englishTagList,
      englishTags: englishTags,
      estimatedDeliveryFee: estimatedDeliveryFee,
      favorite: favorite ?? this.favorite,
      id: id,
      locationState: locationState,
      newShopMark: newShopMark,
      operatingHours: operatingHours,
      platformCommissionRate: platformCommissionRate,
      rating: rating,
      salesVolume: salesVolume,
      shopLogo: shopLogo,
      shopStatus: shopStatus,
      taxRate: taxRate,
    );
  }
}

///UploadedFile，上传文件信息
class UploadedFile {
  ///文件ID
  final int? id;

  ///上传时间
  final int? uploadTime;

  ///文件URL
  final String? url;

  UploadedFile({this.id, this.uploadTime, this.url});

  factory UploadedFile.fromJson(Map<String, dynamic> json) {
    return UploadedFile(
      id: json['id'],
      uploadTime: json['uploadTime'],
      url: json['url'],
    );
  }
}

///TagInfo，标签信息
class TagInfo {
  ///标签ID
  final int? id;

  ///标签名称
  final String? tag;

  TagInfo({this.id, this.tag});

  factory TagInfo.fromJson(Map<String, dynamic> json) {
    return TagInfo(id: json['id'], tag: json['tag']);
  }
}

///DeliveryMethod，配送方式信息
class DeliveryMethod {
  ///配送方式ID
  final int? id;

  ///配送方式名称
  final String? method;

  DeliveryMethod({this.id, this.method});

  factory DeliveryMethod.fromJson(Map<String, dynamic> json) {
    return DeliveryMethod(id: json['id'], method: json['method']);
  }
}
