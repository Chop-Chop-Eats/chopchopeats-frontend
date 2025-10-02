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
    List<OperatingHour>? operatingHours;
    try {
      final operatingHoursData = json['operatingHours'];
      if (operatingHoursData != null) {
        if (operatingHoursData is List) {          
          operatingHours = operatingHoursData
              .map((e) {
                return OperatingHour.fromJson(e as Map<String, dynamic>);
              })
              .toList();
        }
      }
    } catch (e) {
      operatingHours = null;
    }

    return SelectedChefResponse(
      approveTime: json['approveTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['approveTime'] as int)
          : null,
      categoryChineseName: json['categoryChineseName'],
      categoryEnglishName: json['categoryEnglishName'],
      categoryId: json['categoryId'],
      chineseShopName: json['chineseShopName'],
      id: json['id'],
      newShopMark: json['newShopMark'],
      distance: json['distance']?.toDouble(),
      operatingHours: operatingHours,
      rating: json['rating']?.toDouble(),
      shopLogo: json['shopLogo'],
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
    List<OperatingHour>? operatingHours;
    try {
      final operatingHoursData = json['operatingHours'];  
      if (operatingHoursData != null) {
        if (operatingHoursData is List) {
          operatingHours = operatingHoursData
              .map((e) {
                return OperatingHour.fromJson(e as Map<String, dynamic>);
              })
              .toList();
        } 
      }
    } catch (e) {
      operatingHours = null;
    }

    return ShopListItem(
      approveTime: json['approveTime'],
      categoryChineseName: json['categoryChineseName'],
      categoryEnglishName: json['categoryEnglishName'],
      categoryId: json['categoryId'],
      chineseShopName: json['chineseShopName'],
      id: json['id'],
      newShopMark: json['newShopMark'],
      operatingHours: operatingHours,
      rating: json['rating']?.toDouble(),
      shopLogo: json['shopLogo'],
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
