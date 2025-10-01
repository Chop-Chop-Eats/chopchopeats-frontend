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
      'category_id': categoryId,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

/// 获取分类浏览私厨店铺响应
class SelectedChefResponse {
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

  SelectedChefResponse({
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
  });

  factory SelectedChefResponse.fromJson(Map<String, dynamic> json) {
    return SelectedChefResponse(
      approveTime: json['approve_time'],
      categoryChineseName: json['category_chinese_name'],
      categoryEnglishName: json['category_english_name'],
      categoryId: json['category_id'],
      chineseShopName: json['chinese_shop_name'],
      id: json['id'],
      newShopMark: json['new_shop_mark'],
      operatingHours:
          json['operating_hours']
              ?.map((e) => OperatingHour.fromJson(e))
              .toList(),
      rating: json['rating'],
      shopLogo: json['shop_logo'],
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
class DiamondAreaQuery {
  ///店铺分类
  final int categoryId;

  ///纬度
  final double latitude;

  ///经度
  final double longitude;

  ///页码，从 1 开始
  final int pageNo;

  ///每页条数，最大值为 100
  final int pageSize;

  DiamondAreaQuery({
    required this.categoryId,
    required this.latitude,
    required this.longitude,
    required this.pageNo,
    required this.pageSize,
  });

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'latitude': latitude,
      'longitude': longitude,
      'page_no': pageNo,
      'page_size': pageSize,
    };
  }
}

/// 获取分类浏览私厨店铺响应
class DiamondAreaResponse {
  ///数据
  final List<ShopListItem> list;

  ///总量
  final int total;

  DiamondAreaResponse({required this.list, required this.total});

  factory DiamondAreaResponse.fromJson(Map<String, dynamic> json) {
    return DiamondAreaResponse(
      list: json['list']?.map((e) => ShopListItem.fromJson(e)).toList(),
      total: json['total'],
    );
  }
}

class ShopListItem {
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

  ShopListItem({
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
  });

  factory ShopListItem.fromJson(Map<String, dynamic> json) {
    return ShopListItem(
      approveTime: json['approve_time'],
      categoryChineseName: json['category_chinese_name'],
      categoryEnglishName: json['category_english_name'],
      categoryId: json['category_id'],
      chineseShopName: json['chinese_shop_name'],
      id: json['id'],
      newShopMark: json['new_shop_mark'],
      operatingHours:
          json['operating_hours']
              ?.map((e) => OperatingHour.fromJson(e))
              .toList(),
      rating: json['rating'],
      shopLogo: json['shop_logo'],
    );
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
      categoryName: json['category_name'],
      description: json['description'],
      englishCategoryName: json['english_category_name'],
      icon: json['icon'],
      id: json['id'],
      selectedIcon: json['selected_icon'],
      sortOrder: json['sort_order'],
    );
  }
}
