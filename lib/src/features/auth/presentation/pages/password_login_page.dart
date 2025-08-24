import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/navigate.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/logger/logger.dart';
import '../../../../core/widgets/keyboard_aware_page.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_title.dart';
import '../widgets/auth_input_field.dart';
import '../widgets/auth_password_field.dart';
import '../widgets/auth_button.dart';
import 'verification_code_page.dart';

class PasswordLoginPage extends ConsumerStatefulWidget {
  const PasswordLoginPage({super.key});

  @override
  ConsumerState<PasswordLoginPage> createState() => _PasswordLoginPageState();
}

class _PasswordLoginPageState extends ConsumerState<PasswordLoginPage> {
  final _phoneController = TextEditingController(text: '7185937697');
  final _passwordController = TextEditingController(text: '123456');

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
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
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 60.h),
                      // 标题
                      const AuthTitle(
                        title: '密码登录',
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 40.h),
                      
                      // 手机号输入框
                      _buildPhoneInput(),
                      SizedBox(height: 32.h),
                      
                      // 密码输入框
                      _buildPasswordInput(),
                      SizedBox(height: 24.h),
                      
                      // 忘记密码
                      _buildForgotPassword(),
                      SizedBox(height: 24.h),
                      
                      // 登录按钮
                      _buildLoginButton(),
                      SizedBox(height: 24.h),
                      
                      // 验证码登录
                      _buildVerificationCodeLogin(),
                      SizedBox(height: 40.h),
                    ],
                  ),
                  
                  // 底部协议
                  const AuthFooter(),
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
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordInput() {
    return AuthPasswordField(
      controller: _passwordController,
      hintText: '请输入密码',
    );
  }

  Widget _buildForgotPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '忘记密码?',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: () {
            Logger.info("PasswordLoginPage", "忘记密码点击事件");
            Navigate.push(context, Routes.forgotPassword);
          },
          child: Text(
            '立即找回',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.primaryOrange,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return AuthButton(
      text: '登录',
      onPressed: () {
        Logger.info("PasswordLoginPage", "密码登录按钮点击事件");
        // TODO: Implement password login logic
        
        // 模拟登录成功后直接进入主页
        Logger.info("PasswordLoginPage", "密码登录成功，跳转到主页");
        Navigate.replace(context, Routes.home);
      },
    );
  }

  Widget _buildVerificationCodeLogin() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Logger.info("PasswordLoginPage", "验证码登录选项点击事件");
          Navigate.push(context, Routes.verificationCode, arguments: {
            'phoneNumber': _phoneController.text,
            'type': VerificationCodeType.login,
          });
        },
        child: Text(
          '验证码登录',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }
}
