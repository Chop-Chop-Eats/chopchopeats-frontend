import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/navigate.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/logger/logger.dart';
import '../../../../core/widgets/keyboard_aware_page.dart';
import '../../../../core/theme/app_theme.dart';
import 'verification_code_page.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_title.dart';
import '../widgets/auth_input_field.dart';
import '../widgets/auth_button.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _phoneController = TextEditingController(text: '7185937697');

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthKeyboardAwarePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 导航头部
          const AuthHeader(),
          
          // 主要内容
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 60.h),
                  
                  // 标题
                  const AuthTitle(title: '找回密码'),
                  SizedBox(height: 40.h),
                  
                  // 手机号输入框
                  _buildPhoneInput(),
                  SizedBox(height: 40.h),
                  
                  // 获取验证码按钮
                  _buildGetCodeButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInput() {
    return AuthInputField(
      controller: _phoneController,
      hintText: '请输入手机号',
      keyboardType: TextInputType.phone,
      prefix: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '+1',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            width: 1.w,
            height: 24.h,
            color: AppTheme.primaryOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildGetCodeButton() {
    return AuthButton(
      text: '获取验证码',
      onPressed: () {
        Logger.info("ForgotPasswordPage", "获取验证码点击事件，准备验证身份");
        Navigate.push(context, Routes.verificationCode, arguments: {
          'phoneNumber': _phoneController.text,
          'type': VerificationCodeType.setNewPassword,
        });
      },
    );
  }
}
