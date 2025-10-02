import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_theme.dart';
import 'common_image.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 0.w, right: 0.w, top: 0.h, bottom: 0.h),
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            imagePath: currentIndex == 0 ? 'assets/images/home_s.png':'assets/images/home.png' ,
            label: '首页',
            index: 0,
            context: context,
          ),
          _buildNavItem(
            imagePath: currentIndex == 1 ? 'assets/images/heart_s.png':'assets/images/heart.png',
            label: '收藏',
            index: 1,
            context: context,
          ),
          _buildNavItem(
            imagePath: currentIndex == 2 ? 'assets/images/order_s.png':'assets/images/order.png',
            label: '订单',
            index: 2,
            context: context,
          ),
          _buildNavItem(
            imagePath: currentIndex == 3 ? 'assets/images/message_s.png':'assets/images/message.png',
            label: '消息',
            index: 3,
            context: context,
          ),
          _buildNavItem(
            imagePath: currentIndex == 4 ? 'assets/images/mine_s.png':'assets/images/mine.png',
            label: '我的',
            index: 4,
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String imagePath,
    required String label,
    required int index,
    required BuildContext context,
  }) {
    final isSelected = currentIndex == index;
    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(20.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 4.0.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonImage(
              imagePath: imagePath,
              width: 24.w,
              height: 24.h,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: !isSelected ? Colors.black : AppTheme.primaryOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
