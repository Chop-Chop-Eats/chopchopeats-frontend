import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/common_spacing.dart';
import 'category_item.dart';

/// 分类数据模型
class CategoryData {
  final String imagePath;
  final String title;
  final String subtitle;
  final bool imgToRight;

  const CategoryData({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    this.imgToRight = false,
  });
}

/// 分类网格组件 - Home模块专用
class CategoryGrid extends StatelessWidget {
  final List<CategoryData> topRowCategories;
  final List<CategoryData> bottomRowCategories;
  final Function(CategoryData)? onCategoryTap;

  const CategoryGrid({
    super.key,
    required this.topRowCategories,
    required this.bottomRowCategories,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Column(
        children: [
          // 第一行: 2个分类
          Row(
            children: topRowCategories.map((category) {
              final index = topRowCategories.indexOf(category);
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < topRowCategories.length - 1 ? 10.w : 0,
                  ),
                  child: CategoryItem(
                    imagePath: category.imagePath,
                    title: category.title,
                    subtitle: category.subtitle,
                    imgToRight: category.imgToRight,
                    onTap: () => onCategoryTap?.call(category),
                  ),
                ),
              );
            }).toList(),
          ),
          CommonSpacing.height(10),
          // 第二行: 4个分类
          Row(
            children: bottomRowCategories.map((category) {
              final index = bottomRowCategories.indexOf(category);
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < bottomRowCategories.length - 1 ? 10.w : 0,
                  ),
                  child: CategoryItem(
                    imagePath: category.imagePath,
                    title: category.title,
                    subtitle: category.subtitle,
                    imgToRight: category.imgToRight,
                    onTap: () => onCategoryTap?.call(category),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
