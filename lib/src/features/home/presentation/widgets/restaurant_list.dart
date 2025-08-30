import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/common_spacing.dart';
import 'restaurant_card.dart';

/// 餐厅列表组件 - Home模块专用
class RestaurantList extends StatelessWidget {
  final List<RestaurantData> restaurants;
  final Function(RestaurantData)? onRestaurantTap;
  final Function(RestaurantData)? onFavoriteTap;

  const RestaurantList({
    super.key,
    required this.restaurants,
    this.onRestaurantTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          ...restaurants.map((restaurant) => RestaurantCard(
                restaurant: restaurant,
                onTap: () => onRestaurantTap?.call(restaurant),
                onFavoriteTap: () => onFavoriteTap?.call(restaurant),
              )),
          CommonSpacing.height(20),
        ],
      ),
    );
  }
}
