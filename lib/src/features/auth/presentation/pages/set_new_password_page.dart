import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/routing/navigate.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/logger/logger.dart';
import '../../../../core/widgets/system_ui_wrapper.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_title.dart';
import '../widgets/auth_password_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_hint_text.dart';

class SetNewPasswordPage extends ConsumerStatefulWidget {
  const SetNewPasswordPage({super.key});

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
                    const AuthTitle(title: '设置新密码'),
                    const SizedBox(height: 40),
                    
                    // 密码输入框
                    _buildPasswordInput(),
                    const SizedBox(height: 16),
                    
                    // 密码提示
                    const AuthHintText(
                      text: '密码至少8位,包含数字/字母',
                      padding: EdgeInsets.zero,
                    ),
                    
                    const SizedBox(height: 32),
                    // 保存按钮
                    _buildSaveButton(),
      
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordInput() {
    return AuthPasswordField(
      controller: _passwordController,
      hintText: '请输入新密码',
    );
  }

  Widget _buildSaveButton() {
    return AuthButton(
      text: '保存并登录',
      onPressed: () {
        Logger.info("SetNewPasswordPage", "保存新密码按钮点击事件");
        // TODO: Implement save password logic
        
        // 模拟保存成功后直接进入主页
        Logger.info("SetNewPasswordPage", "新密码保存成功，跳转到主页");
        Navigate.replace(context, Routes.home);
      },
    );
  }
}
