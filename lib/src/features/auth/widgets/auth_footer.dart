import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/theme/app_theme.dart';

class AuthFooter extends StatelessWidget {
  const AuthFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 30.0.h),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(color: Colors.grey[500], fontSize: 12.sp),
          children: [
            const TextSpan(text: '继续使用即表示您同意chopchop的'),
            TextSpan(
              text: '用户须知使用\n协议',
              style: TextStyle(color: AppTheme.primaryOrange),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Logger.info("AuthFooter", "用户须知使用协议点击事件");
                  // TODO: 跳转到用户协议页面
                },
            ),
            const TextSpan(text: '和'),
            TextSpan(
              text: '隐私政策',
              style: TextStyle(color: AppTheme.primaryOrange),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Logger.info("AuthFooter", "隐私政策点击事件");
                  // TODO: 跳转到隐私政策页面
                },
            ),
          ],
        ),
      ),
    );
  }
}
