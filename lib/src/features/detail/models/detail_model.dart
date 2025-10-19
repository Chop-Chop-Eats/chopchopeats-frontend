import '../../home/models/home_models.dart';
import '../../../core/utils/json_utils.dart';
import '../../../core/l10n/locale_service.dart';

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

  ///收藏ID
  final String? favoriteId;

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
    this.favoriteId,
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
      favoriteId: json['favoriteId'],
      id: json['id'],
      locationState: json['locationState'],
      newShopMark: json['newShopMark'],
      operatingHours: JsonUtils.parseList<OperatingHour>(
        json,
        'operatingHours',
        (e) => OperatingHour.fromJson(e),
      ),
      platformCommissionRate: JsonUtils.parseDouble(
        json,
        'platformCommissionRate',
      ),
      rating: JsonUtils.parseDouble(json, 'rating'),
      salesVolume: json['salesVolume'],
      shopLogo: json['shopLogo'],
      shopStatus: json['shopStatus'],
      taxRate: JsonUtils.parseDouble(json, 'taxRate'),
    );
  }

  /// copyWith 方法，用于创建修改后的副本（主要用于更新收藏状态）
  ShopModel copyWith({bool? favorite}) {
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

  /// 转换为 ChefItem（用于收藏操作）
  ChefItem toChefItem() {
    return ChefItem(
      id: id,
      chineseShopName: chineseShopName,
      categoryId: categoryId,
      distance: distance,
      operatingHours: operatingHours,
      rating: rating,
      shopLogo: shopLogo,
      favorite: favorite,
      favoriteId: favoriteId,
    );
  }

  /// ========== 国际化便捷属性 ==========
  
  /// 获取本地化的店铺名称
  String get localizedShopName {
    return LocaleService.getLocalizedText(chineseShopName, englishShopName);
  }
  
  /// 获取本地化的店铺介绍
  String? get localizedDescription {
    return LocaleService.getLocalizedText(chineseDescription, englishDescription);
  }
  
  /// 获取本地化的店铺标签列表
  List<TagInfo>? get localizedTagList {
    return LocaleService.isZh ? chineseTagList : englishTagList;
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

  /// ========== 国际化便捷属性 ==========
  
  /// 获取本地化的标签名称（tag 字段已经是本地化的）
  String? get localizedTag => tag;
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

/// 可售商品信息
class SaleProduct {
  ///商品轮播图
  final List<UploadedFile>? carouselImages;

  ///中文描述
  final String? chineseDescription;

  ///中文名称
  final String chineseName;

  ///商品详情图
  final List<UploadedFile>? detailImages;

  ///英文描述
  final String? englishDescription;

  ///英文名称
  final String englishName;

  ///商品卖点，200字以内
  final String? highlight;

  ///热门标记
  final bool? hotMark;

  ///商品ID
  final String id;

  ///商品缩略图
  final String? imageThumbnail;

  ///是否上架
  final bool isOnSale;

  ///销售日期
  final DateTime saleDate;

  ///店铺ID
  final String shopId;

  ///商品SKU列表
  final List<SaleProductSku> skus;

  ///SKU规格设置：0=不区分规格，1=区分规格
  final int skuSetting;

  SaleProduct({
    this.carouselImages,
    this.chineseDescription,
    required this.chineseName,
    this.detailImages,
    this.englishDescription,
    required this.englishName,
    this.highlight,
    this.hotMark,
    required this.id,
    this.imageThumbnail,
    required this.isOnSale,
    required this.saleDate,
    required this.shopId,
    required this.skus,
    required this.skuSetting,
  });

  factory SaleProduct.fromJson(Map<String, dynamic> json) {
    return SaleProduct(
      carouselImages: JsonUtils.parseList<UploadedFile>(
        json,
        'carouselImages',
        (e) => UploadedFile.fromJson(e),
      ),
      chineseDescription: json['chineseDescription'],
      chineseName: json['chineseName'],
      detailImages: JsonUtils.parseList<UploadedFile>(
        json,
        'detailImages',
        (e) => UploadedFile.fromJson(e),
      ),
      englishDescription: json['englishDescription'],
      englishName: json['englishName'],
      highlight: json['highlight'],
      hotMark: json['hotMark'],
      id: json['id'],
      imageThumbnail: json['imageThumbnail'],
      isOnSale: json['isOnSale'],
      saleDate: JsonUtils.parseDateTime(json, 'saleDate') ?? DateTime.now(),
      shopId: json['shopId'],
      skus: JsonUtils.parseList<SaleProductSku>(json, 'skus', (e) => SaleProductSku.fromJson(e)) ?? [],
      skuSetting: json['skuSetting'],
    );
  }

  /// ========== 国际化便捷属性 ==========
  
  /// 获取本地化的商品名称
  String get localizedName {
    return LocaleService.getLocalizedText(chineseName, englishName);
  }
  
  /// 获取本地化的商品描述
  String? get localizedDescription {
    return LocaleService.getLocalizedText(chineseDescription, englishDescription);
  }
}

class SaleProductSku {
  ///SKU ID
  final String? id;

  ///商品价格
  final double price;

  ///SKU名称（规格名称）
  final String? skuName;

  ///状态：0=停售，1=在售
  final int status;

  ///库存数量
  final int stock;

  SaleProductSku({
    this.id,
    required this.price,
    this.skuName,
    required this.status,
    required this.stock,
  });

  factory SaleProductSku.fromJson(Map<String, dynamic> json) {
    return SaleProductSku(
      id: json['id'],
      price: json['price'],
      skuName: json['skuName'],
      status: json['status'],
      stock: json['stock'],
    );
  }
}
