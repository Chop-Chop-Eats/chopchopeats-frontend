import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/navigate.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/logger/logger.dart';
import '../../../../core/widgets/system_ui_wrapper.dart';
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
    return AuthPageWrapper(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 导航头部
            const AuthHeader(),
            
            // 主要内容
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    
                    // 标题
                    const AuthTitle(title: '找回密码'),
                    const SizedBox(height: 40),
                    
                    // 手机号输入框
                    _buildPhoneInput(),
                    const SizedBox(height: 40),
                    
                    // 获取验证码按钮
                    _buildGetCodeButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
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
          const Text(
            '+1',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 1,
            height: 24,
            color: const Color(0xFFFF8A5B),
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
