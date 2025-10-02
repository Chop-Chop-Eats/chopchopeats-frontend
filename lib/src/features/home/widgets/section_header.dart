import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/widgets/common_spacing.dart';
import '../../../core/widgets/common_image.dart';

/// 区域标题组件 - Home模块专用
class SectionHeader extends StatelessWidget {
  final String title;
  final String? iconPath;
  final Widget? customIcon;
  final VoidCallback? onTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.iconPath,
    this.customIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 0,
        bottom: 16.h,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            CommonSpacing.width(4),
            if (customIcon != null)
              customIcon!
            else if (iconPath != null)
              CommonImage(imagePath: iconPath!, height: 20.h),
          ],
        ),
      ),
    );
  }
}
