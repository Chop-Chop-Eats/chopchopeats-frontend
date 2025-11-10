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
    return GestureDetector(
      onTap: onLocationTap,
      child: Row(
        children: [
          Icon(Icons.location_on, color: Colors.black, size: 20.sp),
          CommonSpacing.width(8),
          Expanded(
            child: Text(
              location,
              style: TextStyle(fontSize: 16.sp),
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
