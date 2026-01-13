import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/routing/navigate.dart';
import '../../../core/routing/routes.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/utils/pop/toast.dart';
import '../../../core/widgets/keyboard_aware_page.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/enums/auth_enums.dart';
import 'verification_code_page.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_title.dart';
import '../widgets/auth_input_field.dart';
import '../widgets/auth_button.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  final String? phoneNumber;
  const ForgotPasswordPage({super.key, this.phoneNumber});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                  AuthTitle(title: l10n.authForgotPasswordTitle),
                  SizedBox(height: 40.h),
                  
                  // 手机号输入框
                  _buildPhoneInput(l10n),
                  SizedBox(height: 40.h),
                  
                  // 获取验证码按钮
                  _buildGetCodeButton(l10n),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInput(AppLocalizations l10n) {
    return AuthInputField(
      controller: _phoneController,
      hintText: l10n.authPhoneHint,
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

  Widget _buildGetCodeButton(AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authNotifierProvider);
        
        return AuthButton(
          text: authState.isSendingSms ? l10n.authSendingCode : l10n.authGetVerificationCode,
          isLoading: authState.isSendingSms,
          onPressed: authState.isSendingSms ? null : () async {
            Logger.info("ForgotPasswordPage", "获取验证码点击事件，准备验证身份");
            
            // 验证手机号
            if (_phoneController.text.isEmpty) {
              toast.warn(l10n.authPhoneRequired);
              return;
            }
            
            // 发送验证码
            final success = await ref.read(authNotifierProvider.notifier)
                .sendVerificationCode(_phoneController.text, SmsSceneEnum.forgetPassword);
            
            if (!mounted) return;
            Logger.info("ForgotPasswordPage", "发送验证码结果: $success");
            Logger.info("ForgotPasswordPage", "手机号: $_phoneController.text");
            Logger.info("ForgotPasswordPage", "场景: SmsSceneEnum.forgetPassword");
            if (success) {
              // 发送成功，跳转到验证码页面
              Navigate.replace(context, Routes.verificationCode, arguments: {
                'phoneNumber': _phoneController.text,
                'type': VerificationCodeType.setNewPassword,
              });
            } else {
              // 发送失败，显示错误信息
              final error = authState.error;
              if (error != null) {
                toast.warn(error);
              }
            }
          },
        );
      },
    );
  }
}
