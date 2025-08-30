import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 自定义SliverAppBar组件 - 项目级别通用组件
/// 可以被多个页面复用，支持位置栏和搜索栏的自定义配置
class CustomSliverAppBar extends StatelessWidget {
  final Color backgroundColor;
  final double expandedHeight;
  final bool pinned;
  final double elevation;
  final Widget? backgroundWidget;
  final Widget? locationWidget;
  final Widget? titleWidget;
  final EdgeInsetsGeometry? titlePadding;
  final EdgeInsetsGeometry? contentPadding;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backButtonColor;

  const CustomSliverAppBar({
    super.key,
    this.backgroundColor = const Color.fromARGB(255, 246, 247, 253),
    this.expandedHeight = 108.0,
    this.pinned = true,
    this.elevation = 0,
    this.backgroundWidget,
    this.locationWidget,
    this.titleWidget,
    this.titlePadding,
    this.contentPadding,
    this.showBackButton = false,
    this.onBackPressed,
    this.backButtonColor,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: backgroundColor,
      expandedHeight: expandedHeight,
      pinned: pinned,
      elevation: elevation,
      leading: showBackButton ? IconButton(
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        icon: Icon(
          Icons.arrow_back_ios_new,
          size: 20.sp,
          color: backButtonColor ?? Colors.black,
        ),
      ) : null,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // 自定义背景
            if (backgroundWidget != null) backgroundWidget!,
            // 内容区域
            SafeArea(
              child: Padding(
                padding: contentPadding ?? EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    if (locationWidget != null) locationWidget!,
                  ],
                ),
              ),
            ),
          ],
        ),
        // 固定在顶部的标题组件
        titlePadding: titlePadding ?? EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          bottom: 12.h,
        ),
        title: titleWidget,
      ),
    );
  }
}
