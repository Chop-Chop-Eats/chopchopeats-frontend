import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/widgets/common_image.dart';
import '../../../core/widgets/common_spacing.dart';

class SettingItem extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback onTap;
  final String? tip;
  const SettingItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.tip,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CommonImage(imagePath: icon, width: 24.w, height: 24.h),
                CommonSpacing.width(16.w),
                Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
              ],
            ),
            Row(
              children: [
                if(tip != null) ...[
                  CommonSpacing.width(12.w),
                  Text(tip!, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                ],
                CommonSpacing.width(4.w),
                Icon(Icons.arrow_forward_ios, size: 12.sp, color: Colors.grey.shade600),
              ],
            )
          ],
        ),
      ),
    );
  }
}
