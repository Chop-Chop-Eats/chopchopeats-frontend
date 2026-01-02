import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_theme.dart';
import '../../core/l10n/app_localizations.dart';
import 'common_image.dart';
import '../../features/message/providers/message_provider.dart';

class CustomBottomNavBar extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final unreadCount = ref.watch(unreadCountDataProvider);
    
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
            label: l10n.tabHome,
            index: 0,
            context: context,
          ),
          _buildNavItem(
            imagePath: currentIndex == 1 ? 'assets/images/heart_s.png':'assets/images/heart.png',
            label: l10n.tabHeart,
            index: 1,
            context: context,
          ),
          _buildNavItem(
            imagePath: currentIndex == 2 ? 'assets/images/order_s.png':'assets/images/order.png',
            label: l10n.tabOrder,
            index: 2,
            context: context,
          ),
          _buildNavItem(
            imagePath: currentIndex == 3 ? 'assets/images/message_s.png':'assets/images/message.png',
            label: l10n.tabMessage,
            index: 3,
            context: context,
            unreadCount: unreadCount,
          ),
          _buildNavItem(
            imagePath: currentIndex == 4 ? 'assets/images/mine_s.png':'assets/images/mine.png',
            label: l10n.tabMine,
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
    int unreadCount = 0,
  }) {
    final isSelected = currentIndex == index;
    final showBadge = index == 3 && unreadCount > 0; // 只在消息 Tab 显示红点
    
    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(20.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 4.0.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CommonImage(
                  imagePath: imagePath,
                  width: 24.w,
                  height: 24.h,
                ),
                // 未读消息数量红点
                if (showBadge)
                  Positioned(
                    right: -10.w,
                    top: -10.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.white, width: 1.w),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 14.w,
                        minHeight: 14.h,
                      ),
                      child: Center(
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
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
