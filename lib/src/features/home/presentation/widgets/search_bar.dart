import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 搜索栏组件 - Home模块专用
class HomeSearchBar extends StatelessWidget {
  final String hintText;
  final VoidCallback? onTap;

  const HomeSearchBar({
    super.key,
    required this.hintText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Icon(Icons.search, color: Colors.grey, size: 16.sp),
          ),
          Text(
            hintText,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}
