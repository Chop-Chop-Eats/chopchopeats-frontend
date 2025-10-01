import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/routing/navigate.dart';
import '../../../core/routing/routes.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/utils/pop/toast.dart';
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
  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6, 
    (index) => FocusNode(),
  );
  // 使用 ValueNotifier 来管理每个输入框的状态，避免整个页面重建
  final List<ValueNotifier<bool>> _hasContentNotifiers = List.generate(
    6,
    (index) => ValueNotifier<bool>(false),
  );

  @override
  void initState() {
    super.initState();
    // 监听每个输入框的内容变化
    for (int i = 0; i < _codeControllers.length; i++) {
      _codeControllers[i].addListener(() {
        _hasContentNotifiers[i].value = _codeControllers[i].text.isNotEmpty;
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var notifier in _hasContentNotifiers) {
      notifier.dispose();
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
        return ValueListenableBuilder<bool>(
          valueListenable: _hasContentNotifiers[index],
          builder: (context, hasContent, child) {
            return Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: hasContent ? AppTheme.primaryOrange : Colors.grey.shade300,
                  width: hasContent ? 2.w : 1.w,
                ),
              ),
              child: Focus(
                onKeyEvent: (node, event) {
                  // 监听退格键（删除键）
                  if (event is KeyDownEvent && 
                      event.logicalKey == LogicalKeyboardKey.backspace) {
                    Logger.info("VerificationCodePage", "检测到退格键按下，当前输入框索引: $index");
                    
                    // 如果当前输入框为空，删除上一个输入框的内容
                    if (_codeControllers[index].text.isEmpty && index > 0) {
                      Logger.info("VerificationCodePage", "当前输入框为空，删除上一个输入框内容并跳转");
                      _codeControllers[index - 1].clear();
                      _focusNodes[index - 1].requestFocus();
                      return KeyEventResult.handled; // 阻止默认行为
                    }
                  }
                  return KeyEventResult.ignored; // 允许其他键正常处理
                },
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
                    if (value.isNotEmpty) {
                      Logger.info("VerificationCodePage", "输入框内容不为空，自动跳转到下一个输入框");
                      // 输入内容后，自动跳转到下一个输入框
                      if (index < 5) {
                        _focusNodes[index + 1].requestFocus();
                      }
                    }
                  },
                ),
              ),
            );
          },
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
                  toast.success("验证码已重新发送");
                } else {
                  final error = authState.error;
                  if (error != null) {
                    toast.warn(error);
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
                toast.warn("请输入完整的6位验证码");
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
                  toast.warn(error);
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
