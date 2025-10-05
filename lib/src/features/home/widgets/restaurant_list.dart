import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/widgets/common_spacing.dart';
import '../../../core/widgets/restaurant_card.dart';
import '../models/home_models.dart';

/// 餐厅列表组件 - Home模块专用
class RestaurantList extends StatelessWidget {
  final List<ChefItem> restaurants;
  final Function(ChefItem)? onRestaurantTap;
  final Function(ChefItem)? onFavoriteTap;

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
