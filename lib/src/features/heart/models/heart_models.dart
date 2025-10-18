import '../../../core/utils/json_utils.dart';
import '../../home/models/home_models.dart';

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

  /// 转换为 ChefItem（用于 RestaurantList 显示）
  ChefItem toChefItem() {
    return ChefItem(
      id: shopId,
      chineseShopName: shopName,
      categoryChineseName: categoryName,
      categoryEnglishName: categoryEnglishName,
      distance: distance,
      operatingHours: operatingHours,
      shopLogo: shopLogo,
      favorite: true, // 收藏列表中的都是已收藏的
      favoriteId: id, // 使用收藏ID作为 favoriteId
    );
  }
}
