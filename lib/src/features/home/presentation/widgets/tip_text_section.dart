import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';

/// 提示文本区域组件 - Home模块专用
class TipTextSection extends StatelessWidget {
  final String topText;
  final String highlightText;
  final String normalText;
  final String bottomText;

  const TipTextSection({
    super.key,
    required this.topText,
    required this.highlightText,
    required this.normalText,
    required this.bottomText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            topText,
            style: TextStyle(
              color: const Color.fromARGB(255, 229, 230, 236),
              fontSize: 24.sp,
              fontWeight: FontWeight.w300,
              height: 1.0,
            ),
          ),
          Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w300,
                height: 1.0,
              ),
              children: [
                TextSpan(
                  text: normalText,
                  style: const TextStyle(color: Colors.black),
                ),
                TextSpan(
                  text: highlightText,
                  style: const TextStyle(color: AppTheme.primaryOrange),
                ),
              ],
            ),
          ),
          Text(
            bottomText,
            style: TextStyle(
              color: const Color.fromARGB(255, 229, 230, 236),
              fontSize: 24.sp,
              fontWeight: FontWeight.w300,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
