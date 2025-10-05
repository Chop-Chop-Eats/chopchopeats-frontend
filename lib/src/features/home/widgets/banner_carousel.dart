import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/widgets/common_image.dart';

/// 横幅轮播组件 - Home模块专用
class BannerCarousel extends StatelessWidget {
  final List<String> bannerImages;
  final Function(int)? onBannerTap;

  const BannerCarousel({
    super.key,
    required this.bannerImages,
    this.onBannerTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: bannerImages.asMap().entries.map((entry) {
          final index = entry.key;
          final imagePath = entry.value;
          return Padding(
            padding: EdgeInsets.only(left: 16.w),
            child: GestureDetector(
              onTap: () => onBannerTap?.call(index),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.r),
                child: CommonImage(
                  imagePath: imagePath,
                  width: 343.w,
                  height: 120.h,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
