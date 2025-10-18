import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 通用AppBar组件 - 项目级别通用组件
/// 可以被多个页面复用，支持标题、返回按钮、右侧操作等
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? iconColor;
  final double? elevation;
  final Widget? leading;
  final bool centerTitle;
  final double? titleSpacing;
  final TextStyle? titleStyle;

  const CommonAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.backgroundColor,
    this.titleColor,
    this.iconColor,
    this.elevation,
    this.leading,
    this.centerTitle = true,
    this.titleSpacing,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: titleStyle ?? TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: titleColor ?? Colors.black,
        ),
      ),
      centerTitle: centerTitle,
      titleSpacing: titleSpacing,
      backgroundColor: backgroundColor ?? Colors.white,
      elevation: elevation ?? 0,
      leading: leading ?? (showBackButton ? _buildBackButton(context) : null),
      actions: actions,
      actionsPadding: EdgeInsets.only(right: 16.w),
      iconTheme: IconThemeData(
        color: iconColor ?? Colors.black,
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      icon: Icon(
        Icons.arrow_back_ios_new,
        size: 20.sp,
        color: iconColor ?? Colors.black,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

/// 搜索型AppBar - 带搜索框的AppBar
class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String hintText;
  final VoidCallback? onBackPressed;
  final VoidCallback? onSearchTap;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool autoFocus;

  const SearchAppBar({
    super.key,
    required this.hintText,
    this.onBackPressed,
    this.onSearchTap,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.actions,
    this.backgroundColor,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        icon: Icon(
          Icons.arrow_back_ios,
          size: 20.sp,
          color: Colors.black,
        ),
      ),
      title: Container(
        height: 36.h,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: TextField(
          controller: controller,
          autofocus: autoFocus,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          onTap: onSearchTap,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: 14.sp,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey[500],
              size: 20.sp,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 8.h,
            ),
          ),
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black,
          ),
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

/// 带标签的AppBar - 用于分类页面
class TabAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<String> tabs;
  final TabController? tabController;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? tabColor;
  final Color? indicatorColor;

  const TabAppBar({
    super.key,
    required this.title,
    required this.tabs,
    this.tabController,
    this.onBackPressed,
    this.actions,
    this.backgroundColor,
    this.titleColor,
    this.tabColor,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        icon: Icon(
          Icons.arrow_back_ios,
          size: 20.sp,
          color: Colors.black,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: titleColor ?? Colors.black,
        ),
      ),
      centerTitle: true,
      actions: actions,
      bottom: TabBar(
        controller: tabController,
        tabs: tabs.map((tab) => Tab(text: tab)).toList(),
        labelColor: tabColor ?? Colors.black,
        unselectedLabelColor: Colors.grey[500],
        indicatorColor: indicatorColor ?? Colors.orange,
        labelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + kTextTabBarHeight);
}
