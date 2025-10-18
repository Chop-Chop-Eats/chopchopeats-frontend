import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../common_image.dart';
import '../common_spacing.dart';

class Rating extends StatelessWidget {
  final String rating;
  const Rating({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CommonImage(imagePath: "assets/images/star.png", height: 16.h),
        CommonSpacing.width(4),
        Text(
          rating,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
        ),
      ],
    );
  }
}
