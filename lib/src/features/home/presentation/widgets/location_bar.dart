import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/common_spacing.dart';

/// 位置选择栏组件 - Home模块专用
class LocationBar extends StatelessWidget {
  final String location;
  final VoidCallback? onLocationTap;

  const LocationBar({
    super.key,
    required this.location,
    this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.location_on, color: Colors.black54, size: 20.sp),
        CommonSpacing.width(8),
        Text(
          location,
          style: TextStyle(fontSize: 16.sp),
        ),
        Icon(Icons.arrow_drop_down, color: Colors.black54, size: 20.sp),
      ],
    );
  }
}
