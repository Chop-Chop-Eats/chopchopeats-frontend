import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/routing/navigate.dart';
import '../../../core/routing/routes.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/keyboard_aware_page.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/enums/auth_enums.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_title.dart';
import '../widgets/auth_button.dart';
import '../providers/auth_provider.dart';

enum VerificationCodeType {
  login,           // 登录
  setNewPassword,  // 设置新密码
}

class VerificationCodePage extends ConsumerStatefulWidget {
  final String phoneNumber;
  final VerificationCodeType type;
  final String email;
  const VerificationCodePage({
    super.key,
    required this.phoneNumber,
    required this.email,
    this.type = VerificationCodeType.login,
  });

  @override
  ConsumerState<VerificationCodePage> createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends ConsumerState<VerificationCodePage> {
  // 验证码位数：当前为4位，原为6位
  final List<TextEditingController> _codeControllers = List.generate(
    6, // 原为: 6
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6, 
    (index) => FocusNode(),
  );

  @override
  void initState() {
    super.initState();

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
                  AuthTitle(
                    title: widget.type == VerificationCodeType.login ? '输入验证码' : '验证身份',
                  ),
                  SizedBox(height: 16.h),
                  
                  // 提示信息
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                      children: [
                        const TextSpan(text: '已发送至手机号 '),
                        TextSpan(
                          text: widget.phoneNumber,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40.h),
                  
                  // 验证码输入框
                  _buildCodeInputs(),
                  SizedBox(height: 32.h),
                  
                  // 重新发送
                  _buildResendSection(),
                  SizedBox(height: 12.h),
                  // 操作按钮
                  _buildActionButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeInputs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return Container(
          width: 50.w,
          height: 50.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: index == 0 ? AppTheme.primaryOrange : Colors.grey.shade300,
              width: index == 0 ? 2.w : 1.w,
            ),
          ),
          child: TextFormField(
            controller: _codeControllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.sp,
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
              // 验证码位数：当前为4位，原为6位
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
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authNotifierProvider);
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              '未收到验证码?',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: authState.isSendingSms ? null : () async {
                Logger.info("VerificationCodePage", "重新发送验证码点击事件");
                
                final success = await ref.read(authNotifierProvider.notifier)
                    .sendVerificationCode(
                      widget.phoneNumber, 
                      widget.type == VerificationCodeType.login 
                          ? SmsSceneEnum.login 
                          : SmsSceneEnum.forgetPassword
                    );
                
                if (!mounted) return;
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('验证码已重新发送')),
                  );
                } else {
                  final error = authState.error;
                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error)),
                    );
                  }
                }
              },
              child: Text(
                authState.isSendingSms ? '发送中...' : '重新发送',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: authState.isSendingSms ? Colors.grey : AppTheme.primaryOrange,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton() {
    final buttonText = widget.type == VerificationCodeType.login ? '登录' : '设置新密码';
    
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authNotifierProvider);
        
        return AuthButton(
          text: authState.isLoading ? '处理中...' : buttonText,
          isLoading: authState.isLoading,
          onPressed: authState.isLoading ? null : () async {
            Logger.info("VerificationCodePage", "验证码验证成功，准备$buttonText");
            
            // 获取验证码
            final code = _codeControllers.map((controller) => controller.text).join('');
            
            // 验证码位数检查：当前为4位，原为6位
            if (code.length != 6) { 
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请输入完整的6位验证码')), 
                );
              }
              return;
            }
            
            if (widget.type == VerificationCodeType.login) {
              // 登录流程：调用登录接口
              final success = await ref.read(authNotifierProvider.notifier)
                  .loginWithSmsCode(widget.phoneNumber, code, widget.email);
              
              if (!mounted) return;
              
              if (success) {
                Logger.info("VerificationCodePage", "验证码登录成功，跳转到主页");
                Navigate.replace(context, Routes.home);
              } else {
                // 登录失败，显示错误信息
                final error = authState.error;
                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error)),
                  );
                }
              }
            } else {
              // 设置新密码流程：进入设置新密码页面
              Logger.info("VerificationCodePage", "身份验证成功，跳转到设置新密码页面");
              Navigate.replace(context, Routes.setNewPasswordPage);
            }
          },
        );
      },
    );
  }
}
