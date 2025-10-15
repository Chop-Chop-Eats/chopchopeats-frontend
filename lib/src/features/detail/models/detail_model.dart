import '../../home/models/home_models.dart';
import '../../../core/utils/json_utils.dart';

/// 我的收藏返回
class FavoriteModel {
  ///数据
  final List<FavoriteItem> list;

  ///总量
  final int total;

  FavoriteModel({required this.list, required this.total});

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    late List<FavoriteItem> list;
    if (json['list'] is List) {
      final List<dynamic> dataList = json['list'] as List<dynamic>;
      list = dataList.map((e) => FavoriteItem.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      list = [];
    }
    return FavoriteModel(
      list: list, 
      total: json['total']
    );
  }
}

/// 收藏Item
class FavoriteItem {
  ///分类英文名称
  final String? categoryEnglishName;

  ///分类名称
  final String? categoryName;

  ///收藏时间
  final DateTime createTime;

  ///距离（公里）
  final double? distance;

  ///收藏ID
  final String id;

  ///营业时间
  final List<OperatingHour>? operatingHours;

  ///店铺英文名称
  final String? shopEnglishName;

  ///店铺ID
  final String shopId;

  ///店铺logo(封面图)
  final String? shopLogo;

  ///店铺名称
  final String shopName;

  FavoriteItem({
    this.categoryEnglishName,
    this.categoryName,
    required this.createTime,
    this.distance,
    required this.id,
    this.operatingHours,
    this.shopEnglishName,
    required this.shopId,
    this.shopLogo,
    required this.shopName,
  });

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      categoryEnglishName: json['categoryEnglishName'],
      categoryName: json['categoryName'],
      createTime: DateTime.fromMillisecondsSinceEpoch(
        json['createTime'] as int,
      ),
      distance: JsonUtils.parseDouble(json, 'distance'),
      id: json['id'],
      operatingHours: JsonUtils.parseList<OperatingHour>(
        json,
        'operatingHours',
        (e) => OperatingHour.fromJson(e),
      ),
      shopEnglishName: json['shopEnglishName'],
      shopId: json['shopId'],
      shopLogo: json['shopLogo'],
      shopName: json['shopName'],
    );
  }
}

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
