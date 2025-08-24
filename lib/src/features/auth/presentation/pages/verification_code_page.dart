import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/routing/navigate.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/logger/logger.dart';
import '../../../../core/widgets/system_ui_wrapper.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_title.dart';
import '../widgets/auth_button.dart';

enum VerificationCodeType {
  login,           // 登录
  setNewPassword,  // 设置新密码
}

class VerificationCodePage extends ConsumerStatefulWidget {
  final String phoneNumber;
  final VerificationCodeType type;
  
  const VerificationCodePage({
    super.key,
    required this.phoneNumber,
    this.type = VerificationCodeType.login,
  });

  @override
  ConsumerState<VerificationCodePage> createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends ConsumerState<VerificationCodePage> {
  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  @override
  void initState() {
    super.initState();
    // 设置默认验证码
    _codeControllers[0].text = '1';
    _codeControllers[1].text = '2';
    _codeControllers[2].text = '9';
    _codeControllers[3].text = '0';
    _codeControllers[4].text = '1';
    _codeControllers[5].text = '2';
  }

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
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
                    AuthTitle(
                      title: widget.type == VerificationCodeType.login ? '输入验证码' : '验证身份',
                    ),
                    const SizedBox(height: 16),
                    
                    // 提示信息
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                        children: [
                          const TextSpan(text: '已发送至手机号 '),
                          TextSpan(
                            text: widget.phoneNumber,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // 验证码输入框
                    _buildCodeInputs(),
                    const SizedBox(height: 32),
                    
                    // 重新发送
                    _buildResendSection(),
                    const SizedBox(height: 12),
                    // 操作按钮
                    _buildActionButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeInputs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: index == 0 ? const Color(0xFFFF8A5B) : Colors.grey.shade300,
              width: index == 0 ? 2 : 1,
            ),
          ),
          child: TextFormField(
            controller: _codeControllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: '',
            ),
            keyboardType: TextInputType.number,
            maxLength: 1,
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                _focusNodes[index + 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildResendSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '未收到验证码?',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            Logger.info("VerificationCodePage", "重新发送验证码点击事件");
            // TODO: Implement resend verification code logic
          },
          child: const Text(
            '重新发送',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFFFF8A5B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    final buttonText = widget.type == VerificationCodeType.login ? '登录' : '设置新密码';
    
    return AuthButton(
      text: buttonText,
      onPressed: () {
        Logger.info("VerificationCodePage", "验证码验证成功，准备${buttonText}");
        
        if (widget.type == VerificationCodeType.login) {
          // 登录流程：直接进入主页
          Logger.info("VerificationCodePage", "验证码登录成功，跳转到主页");
          Navigate.replace(context, Routes.home);
        } else {
          // 设置新密码流程：进入设置新密码页面
          Logger.info("VerificationCodePage", "身份验证成功，跳转到设置新密码页面");
          Navigate.replace(context, Routes.setNewPasswordPage);
        }
      },
    );
  }
}
