import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/widgets/common_spacing.dart';

/// 分类项目组件 - Home模块专用
class CategoryItem extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final bool imgToRight;
  final VoidCallback? onTap;

  const CategoryItem({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    this.imgToRight = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: imgToRight ? 16.sp : 12.sp,
                fontFamily: "Alibaba",
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey[500],
              ),
              overflow: TextOverflow.ellipsis,
            ),
            CommonSpacing.height(8),
            if (imgToRight) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox.shrink(),
                  Image.asset(imagePath, height: 50.h),
                ],
              ),
            ] else
              Image.asset(imagePath, height: 45.h),
          ],
        ),
      ),
    );
  }
}
