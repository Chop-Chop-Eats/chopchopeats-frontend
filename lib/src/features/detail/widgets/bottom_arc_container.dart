import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomArcContainer extends StatelessWidget {
  final double? height;
  final Widget child;
  const BottomArcContainer({super.key, required this.child, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 80.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 0.5.w),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 4.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: 16.h),
      child: child,
    );
  }
}

