import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_theme.dart';
import 'common_indicator.dart';

class CommonButton extends StatefulWidget {
  final bool? isLoading;
  final String text;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? textColor;
  final VoidCallback onPressed;
  final double? width;
  const CommonButton({
    super.key,
    this.isLoading = false,
    required this.text,
    required this.onPressed,
    this.padding,
    this.borderRadius,
    this.textColor,
    this.width,
  });

  @override
  State<CommonButton> createState() => _CommonButtonState();
}

class _CommonButtonState extends State<CommonButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Container(
        width: widget.width,
        padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color:
              widget.isLoading ?? false
                  ? Colors.grey[400]
                  : AppTheme.primaryOrange,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(16.r),
        ),
        child:
            widget.isLoading ?? false
                ? CommonIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                  size: 14.w,
                )
                : Center(
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: widget.textColor ?? Colors.white,
                    ),
                  ),
                ),
      ),
    );
  }
}

