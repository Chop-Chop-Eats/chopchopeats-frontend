import '../../core/utils/json_utils.dart';

/// 餐厅数据模型 - 全局数据模型
class RestaurantModel {
  final String id;
  final String imagePath;
  final String name;
  final String tags;
  final String description;
  final double rating;
  final String deliveryTime;
  final String distance;
  final String address;
  final bool isOpen;
  final bool isFavorite;
  final List<String> categoryIds;
  final double deliveryFee;
  final double minOrder;

  const RestaurantModel({
    required this.id,
    required this.imagePath,
    required this.name,
    required this.tags,
    required this.description,
    required this.rating,
    required this.deliveryTime,
    required this.distance,
    required this.address,
    this.isOpen = true,
    this.isFavorite = false,
    this.categoryIds = const [],
    this.deliveryFee = 0.0,
    this.minOrder = 0.0,
  });

  /// 从 JSON 创建 RestaurantModel
  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    // 处理categoryIds字段的类型转换
    List<String> categoryIds = [];
    final categoryIdsData = json['categoryIds'];
    if (categoryIdsData is List) {
      categoryIds = categoryIdsData.map((e) => e.toString()).toList();
    }

    return RestaurantModel(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      name: json['name'] as String,
      tags: json['tags'] as String,
      description: json['description'] as String? ?? '',
      rating: JsonUtils.parseDouble(json, 'rating') ?? 0.0,
      deliveryTime: json['deliveryTime'] as String,
      distance: json['distance'] as String,
      address: json['address'] as String? ?? '',
      isOpen: JsonUtils.parseBool(json, 'isOpen') ?? true,
      isFavorite: JsonUtils.parseBool(json, 'isFavorite') ?? false,
      categoryIds: categoryIds,
      deliveryFee: JsonUtils.parseDouble(json, 'deliveryFee') ?? 0.0,
      minOrder: JsonUtils.parseDouble(json, 'minOrder') ?? 0.0,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'name': name,
      'tags': tags,
      'description': description,
      'rating': rating,
      'deliveryTime': deliveryTime,
      'distance': distance,
      'address': address,
      'isOpen': isOpen,
      'isFavorite': isFavorite,
      'categoryIds': categoryIds,
      'deliveryFee': deliveryFee,
      'minOrder': minOrder,
    };
  }

  /// 创建副本
  RestaurantModel copyWith({
    String? id,
    String? imagePath,
    String? name,
    String? tags,
    String? description,
    double? rating,
    String? deliveryTime,
    String? distance,
    String? address,
    bool? isOpen,
    bool? isFavorite,
    List<String>? categoryIds,
    double? deliveryFee,
    double? minOrder,
  }) {
    return RestaurantModel(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      name: name ?? this.name,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      distance: distance ?? this.distance,
      address: address ?? this.address,
      isOpen: isOpen ?? this.isOpen,
      isFavorite: isFavorite ?? this.isFavorite,
      categoryIds: categoryIds ?? this.categoryIds,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      minOrder: minOrder ?? this.minOrder,
    );
  }

  /// 格式化评分显示
  String get formattedRating => rating.toStringAsFixed(1);

  /// 格式化配送费显示
  String get formattedDeliveryFee => 
      deliveryFee == 0 ? '免配送费' : '配送费 ¥${deliveryFee.toStringAsFixed(1)}';

  /// 格式化最低订单金额显示
  String get formattedMinOrder => 
      minOrder == 0 ? '无起送费' : '起送 ¥${minOrder.toStringAsFixed(0)}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RestaurantModel &&
        other.id == id &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() {
    return 'RestaurantModel(id: $id, name: $name, rating: $rating)';
  }

  /// 转换为 ChefItem 用于兼容新的 RestaurantCard
  /// 注意：这是一个临时的适配方法，建议后续统一数据模型
  Map<String, dynamic> toSelectedChefResponse() {
    return {
      'id': id,
      'chineseShopName': name,
      'shopLogo': imagePath,
      'categoryChineseName': tags,
      'rating': rating,
      'distance': double.tryParse(distance.replaceAll('km', '').replaceAll('km', '')) ?? 0.0,
      'operatingHours': [
        {
          'time': deliveryTime,
          'remark': '',
          'sort': 1,
        }
      ],
    };
  }
}
