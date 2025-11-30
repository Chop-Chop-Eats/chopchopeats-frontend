import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../common_image.dart';
import '../common_spacing.dart';

class OperatingHours extends StatelessWidget {
  final String operatingHours;
  const OperatingHours({super.key, required this.operatingHours});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CommonImage(imagePath: "assets/images/clock.png", height: 16.h),
        CommonSpacing.width(4.w),
        Text(
          operatingHours,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
        ),
        CommonSpacing.width(6.w),
      ],
    );
  }
}
