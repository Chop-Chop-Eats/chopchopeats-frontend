import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'common_spacing.dart';

/// 餐厅数据模型
class RestaurantData {
  final String imagePath;
  final String name;
  final String tags;
  final String rating;
  final String deliveryTime;
  final String distance;

  const RestaurantData({
    required this.imagePath,
    required this.name,
    required this.tags,
    required this.rating,
    required this.deliveryTime,
    required this.distance,
  });
}

/// 餐厅卡片组件 - Home模块专用
class RestaurantCard extends StatelessWidget {
  final RestaurantData restaurant;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              spreadRadius: 3,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: Image.asset(
                restaurant.imagePath,
                width: 100.w,
                height: 100.h,
                fit: BoxFit.cover,
              ),
            ),
            CommonSpacing.width(12),
            Expanded(
              child: SizedBox(
                height: 100.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      restaurant.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      restaurant.tags,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    Row(
                      children: [
                        Image.asset("assets/images/star.png", height: 16.h),
                        CommonSpacing.width(4),
                        Text(
                          restaurant.rating,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                        CommonSpacing.width(8),
                        Image.asset("assets/images/clock.png", height: 16.h),
                        CommonSpacing.width(4),
                        Expanded(
                          child: Text(
                            restaurant.deliveryTime,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          restaurant.distance,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        GestureDetector(
                          onTap: onFavoriteTap,
                          child: Image.asset("assets/images/heart_s.png", width: 20.w, height: 20.h),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
