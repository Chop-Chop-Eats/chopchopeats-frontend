import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/routing/navigate.dart';
import '../../../core/routing/routes.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/utils/pop/toast.dart';
import '../../../core/widgets/keyboard_aware_page.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_title.dart';
import '../widgets/auth_input_field.dart';
import '../widgets/auth_password_field.dart';
import '../widgets/auth_button.dart';
import 'verification_code_page.dart';

class PasswordLoginPage extends ConsumerStatefulWidget {
  final String? phoneNumber;
  const PasswordLoginPage({super.key, this.phoneNumber});

  @override
  ConsumerState<PasswordLoginPage> createState() => _PasswordLoginPageState();
}

class _PasswordLoginPageState extends ConsumerState<PasswordLoginPage> {
  late final TextEditingController _phoneController;
  final TextEditingController _passwordController = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.phoneNumber ?? '');
  }

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
            Navigate.push(context, Routes.forgotPassword , arguments: _phoneController.text);
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

  Future<void> _login() async {
    Logger.info("PasswordLoginPage", "密码登录按钮点击事件");
    
    // 输入验证
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    
    if (phone.isEmpty) {
      toast.warn("请输入手机号");
      return;
    }
    
    if (password.isEmpty) {
      toast.warn("请输入密码");
      return;
    }
    
    // 调用登录接口
    final success = await ref.read(authNotifierProvider.notifier)
        .loginWithPhoneAndPassword(phone, password);
    
    if (!mounted) return;
    
    if (success) {
      Logger.info("PasswordLoginPage", "密码登录成功，跳转到主页");
      toast.success("登录成功");
      Navigate.replace(context, Routes.home);
    } else {
      // 登录失败，显示错误信息
      final authState = ref.read(authNotifierProvider);
      if (authState.error != null) {
        toast.warn(authState.error!);
      } else {
        toast.warn("登录失败，请重试");
      }
    }
  }

  Widget _buildLoginButton() {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authNotifierProvider);
        
        return AuthButton(
          text: authState.isLoading ? '登录中...' : '登录',
          isLoading: authState.isLoading,
          onPressed: authState.isLoading ? null : _login,
        );
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
