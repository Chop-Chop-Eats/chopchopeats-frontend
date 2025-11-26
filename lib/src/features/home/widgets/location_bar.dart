import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/widgets/common_spacing.dart';

/// 位置选择栏组件 - Home模块专用
class LocationBar extends StatelessWidget {
  final String location;
  final VoidCallback onLocationTap;

  const LocationBar({
    super.key,
    required this.location,
    required this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    // 解析 locationLabel，格式为 "primaryText · secondaryText"
    final parts = location.split(' · ');
    final primaryText = parts.isNotEmpty ? parts[0] : location;
    final secondaryText = parts.length > 1 ? parts[1] : null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onLocationTap,
      child: Row(
        children: [
          Icon(Icons.location_on, color: Colors.black, size: 20.sp),
          CommonSpacing.width(8),
          Expanded(
            child: secondaryText != null && secondaryText.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        primaryText,
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        secondaryText,
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  )
                : Text(
                    location,
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          CommonSpacing.width(4),
          Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 20.sp),
        ],
      ),
    );
  }
}
