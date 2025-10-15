import '../../models/models.dart';
import '../../../core/utils/json_utils.dart';

/// 获取甄选私厨店铺请求query
class SelectedChefQuery {
  ///店铺分类，不传则查询所有分类
  final int? categoryId;

  ///纬度
  final double latitude;

  ///经度
  final double longitude;

  SelectedChefQuery({
    this.categoryId,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      if (categoryId != null) 'categoryId': categoryId,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

/// 获取分类浏览私厨店铺响应
class ChefItem {
  ///创建时间（审核通过时间）
  final DateTime? approveTime;

  ///店铺分类中文名称
  final String? categoryChineseName;

  ///店铺分类英文名称
  final String? categoryEnglishName;

  ///店铺分类ID
  final int? categoryId;

  ///中文店铺名称
  final String chineseShopName;

  ///距离（千米）
  final double? distance;

  ///店铺编号
  final String id;

  ///新店开业标识
  final bool? newShopMark;

  ///配送时间（营业时间）
  final List<OperatingHour>? operatingHours;

  ///店铺评分
  final double? rating;

  ///店铺logo（封面图）
  final String? shopLogo;

  final bool? favorite;

  ChefItem({
    this.approveTime,
    this.categoryChineseName,
    this.categoryEnglishName,
    this.categoryId,
    required this.chineseShopName,
    this.distance,
    required this.id,
    this.newShopMark,
    this.operatingHours,
    this.rating,
    this.shopLogo,
    this.favorite,
  });

  factory ChefItem.fromJson(Map<String, dynamic> json) {
    return ChefItem(
      approveTime: JsonUtils.parseDateTime(json, 'approveTime'),
      categoryChineseName: json['categoryChineseName'],
      categoryEnglishName: json['categoryEnglishName'],
      categoryId: json['categoryId'],
      chineseShopName: json['chineseShopName'],
      id: json['id'],
      newShopMark: json['newShopMark'],
      distance: JsonUtils.parseDouble(json, 'distance'),
      operatingHours: JsonUtils.parseList<OperatingHour>(
        json,
        'operatingHours',
        (e) => OperatingHour.fromJson(e),
      ),
      rating: JsonUtils.parseDouble(json, 'rating'),
      shopLogo: json['shopLogo'],
      favorite: json['favorite'],
    );
  }
}

/// 配送时间
class OperatingHour {
  ///备注信息
  final String? remark;

  ///排序序号
  final int? sort;

  ///营业时间
  final String? time;

  OperatingHour({this.remark, this.sort, this.time});

  factory OperatingHour.fromJson(Map<String, dynamic> json) {
    return OperatingHour(
      remark: json['remark'],
      sort: json['sort'],
      time: json['time'],
    );
  }
}

/// 获取分类浏览私厨店铺请求query 
class DiamondAreaQuery extends CommonQuery {
  ///店铺分类
  final int categoryId;

  DiamondAreaQuery({
    required this.categoryId,
    required super.latitude,
    required super.longitude,
    required super.pageNo,
    required super.pageSize,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      ...super.toJson(),
    };
  }
}

/// 获取分类浏览私厨店铺响应 分页列表
class TotalWithChefItem {
  ///总量
  final int total;
  ///数据
  final List<ChefItem> list;

  TotalWithChefItem({required this.list, required this.total});

  factory TotalWithChefItem.fromJson(Map<String, dynamic> json) {
    late List<ChefItem> list;
    if (json['list'] is List) {
      final List<dynamic> dataList = json['list'] as List<dynamic>;
      list =
          dataList
              .map((e) => ChefItem.fromJson(e as Map<String, dynamic>))
              .toList();
    }
    return TotalWithChefItem(list: list, total: json['total']);
  }
}

/// 店铺分类列表响应
class CategoryListItem {
  ///分类名称
  final String? categoryName;

  ///分类描述
  final String? description;

  ///英文分类名称
  final String? englishCategoryName;

  ///分类的未选中图标
  final String? icon;

  ///分类编号
  final int? id;

  ///分类的选中图标
  final String? selectedIcon;

  ///排序值
  final int? sortOrder;

  CategoryListItem({
    this.categoryName,
    this.description,
    this.englishCategoryName,
    this.icon,
    this.id,
    this.selectedIcon,
    this.sortOrder,
  });

  factory CategoryListItem.fromJson(Map<String, dynamic> json) {
    return CategoryListItem(
      categoryName: json['categoryName'],
      description: json['description'],
      englishCategoryName: json['englishCategoryName'],
      icon: json['icon'],
      id: json['id'],
      selectedIcon: json['selectedIcon'],
      sortOrder: json['sortOrder'],
    );
  }
}

/// banner Item
class BannerItem {
  ///编号
  final int id;

  ///图片地址
  final String imageUrl;

  ///跳转页面地址
  final String? redirectUrl;

  ///排序值，越小越靠前
  final int sortOrder;

  BannerItem({
    required this.id,
    required this.imageUrl,
    this.redirectUrl,
    required this.sortOrder,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: json['id'],
      imageUrl: json['imageUrl'],
      redirectUrl: json['redirectUrl'],
      sortOrder: json['sortOrder'],
    );
  }
}
