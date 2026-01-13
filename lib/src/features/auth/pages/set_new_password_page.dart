import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/routing/navigate.dart';
import '../../../core/routing/routes.dart';
import '../../../core/utils/pop/toast.dart';
import '../../../core/widgets/keyboard_aware_page.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_title.dart';
import '../widgets/auth_password_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_hint_text.dart';

class SetNewPasswordPage extends ConsumerStatefulWidget {
  final String code;
  final String phoneNumber;
  const SetNewPasswordPage({super.key, required this.code, required this.phoneNumber});

  @override
  ConsumerState<SetNewPasswordPage> createState() => _SetNewPasswordPageState();
}

class _SetNewPasswordPageState extends ConsumerState<SetNewPasswordPage> {
  final _passwordController = TextEditingController(text: '123456');

  @override
  void dispose() {
    _passwordController.dispose();
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
                  AuthTitle(title: l10n.authSetNewPassword),
                  SizedBox(height: 40.h),
                  
                  // 密码输入框
                  _buildPasswordInput(l10n),
                  SizedBox(height: 16.h),
                  
                  // 密码提示
                  AuthHintText(
                    text: l10n.authPasswordRequirementHint,
                    padding: EdgeInsets.zero,
                  ),
                  
                  SizedBox(height: 32.h),
                  // 保存按钮
                  _buildSaveButton(l10n),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordInput(AppLocalizations l10n) {
    return AuthPasswordField(
      controller: _passwordController,
      hintText: l10n.authNewPasswordHint,
    );
  }

  Future<void> _savePassword() async {
    final l10n = AppLocalizations.of(context)!;
    
    final success = await ref.read(authNotifierProvider.notifier).setNewPassword(widget.code, _passwordController.text, widget.phoneNumber);
    if (success) {
      toast.success(l10n.authSetPasswordSuccess);
      // 立刻调用密码登录
      final success = await ref.read(authNotifierProvider.notifier).loginWithPhoneAndPassword(widget.phoneNumber, _passwordController.text);
      if (success) {
        toast.success(l10n.authSetPasswordSuccess);
        Navigate.replace(context, Routes.home);
      } else {
        toast.warn(l10n.authSetPasswordFailed);
      }
    } else {
      final authState = ref.read(authNotifierProvider);
      if (authState.error != null) {
        toast.warn(authState.error!);
      } else {
        toast.warn(l10n.authSetPasswordFailed);
      }

    }
  }

  Widget _buildSaveButton(AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authNotifierProvider);
        return AuthButton(
          text: authState.isLoading ? l10n.btnSaving : l10n.authSaveAndLogin,
          onPressed: authState.isLoading ? null : _savePassword,
        );
      },
    );
  }
}
