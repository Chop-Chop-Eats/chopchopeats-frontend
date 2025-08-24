import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routing/navigate.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/logger/logger.dart';
import '../../../../core/widgets/system_ui_wrapper.dart';
import '../../../../core/theme/app_theme.dart';
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
          onTap: () {
            Logger.info("VerificationCodePage", "重新发送验证码点击事件");
            // TODO: Implement resend verification code logic
          },
          child: Text(
            '重新发送',
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
