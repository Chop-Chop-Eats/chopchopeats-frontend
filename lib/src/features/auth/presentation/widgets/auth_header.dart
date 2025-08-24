import 'package:chop_user/src/core/routing/navigate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthHeader extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final EdgeInsetsGeometry? padding;

  const AuthHeader({
    super.key,
    this.onBackPressed,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.only(top: 24.0.h, left: 24.0.w),
      child: Row(
        children: [
          IconButton(
            onPressed: onBackPressed ?? () => Navigate.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 24.w,
            ),
          ),
        ],
      ),
    );
  }
}
