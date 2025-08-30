/// 分类数据模型 - 全局数据模型
class CategoryModel {
  final String id;
  final String imagePath;
  final String title;
  final String subtitle;
  final String description;
  final bool imgToRight;
  final int sortOrder;
  final bool isActive;

  const CategoryModel({
    required this.id,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.description,
    this.imgToRight = false,
    this.sortOrder = 0,
    this.isActive = true,
  });

  /// 从 JSON 创建 CategoryModel
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      description: json['description'] as String? ?? '',
      imgToRight: json['imgToRight'] as bool? ?? false,
      sortOrder: json['sortOrder'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'imgToRight': imgToRight,
      'sortOrder': sortOrder,
      'isActive': isActive,
    };
  }

  /// 创建副本
  CategoryModel copyWith({
    String? id,
    String? imagePath,
    String? title,
    String? subtitle,
    String? description,
    bool? imgToRight,
    int? sortOrder,
    bool? isActive,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      imgToRight: imgToRight ?? this.imgToRight,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel &&
        other.id == id &&
        other.title == title;
  }

  @override
  int get hashCode => Object.hash(id, title);

  @override
  String toString() {
    return 'CategoryModel(id: $id, title: $title, subtitle: $subtitle)';
  }
}
