import 'package:chop_user/src/core/routing/navigate.dart';
import 'package:chop_user/src/core/utils/pop/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/routing/routes.dart';
import '../../../core/widgets/system_ui_wrapper.dart';
import '../../../core/widgets/common_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/enums/auth_enums.dart';
import 'verification_code_page.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_title.dart';
import '../widgets/auth_input_field.dart';
import '../widgets/auth_button.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController(text: '1162574925@qq.com');
  final _phoneController = TextEditingController(text: '6777804236');

  @override
  void initState() {
    super.initState();
    Logger.info('LoginPage', '登录页面已初始化');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthGradientPageWrapper(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // 装饰性圆形渐变背景光晕
            _buildDecorativeCircles(),
            // 主体内容
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 
                              MediaQuery.of(context).padding.top - 
                              MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildHeader(),
                        SizedBox(height: 60.h),
                        _buildLoginForm(context),
                        // 底部协议
                        SizedBox(height: 100.h),
                        const AuthFooter()
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 创建装饰性圆形渐变光晕
  Widget _buildDecorativeCircles() {
    return Stack(
      children: [
        // 紫色光晕 (左上)
        Positioned(
          top: -240.h,
          left: -330.w,
          child: _buildDecorativeCircle(
            color: const Color(0xFFDAC5FF),
            radius: 300.r,
          ),
        ),
        // 橙色光晕 (右侧)
        Positioned(
          top: -100.h,
          right: -300.w,
          child: _buildDecorativeCircle(
            color: const Color(0xFFFFDAC5),
            radius: 300.r,
          ),
        ),
      ],
    );
  }

  Widget _buildDecorativeCircle({required Color color, required double radius}) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withAlpha(0),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final textStyle = TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    return Padding(
      padding: EdgeInsets.only(top: 60.0.h, left: 16.0.w, right: 16.0.w),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'The taste of home',
                style: textStyle,
              ),
              Row(
                children: [
                  Text(
                    'without the ',
                    style: textStyle,
                  ),
                  Text(
                    'cooking',
                    style: textStyle.copyWith(color: AppTheme.primaryOrange),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: -50.h,
            right: 0,
            child: CommonImage(
              imagePath: 'assets/images/chef.png',
              height: 180.h,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0.w),
      child: Container(
        padding: EdgeInsets.all(24.0.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(10),
              spreadRadius: 5,
              blurRadius: 15,
              offset: Offset(0, 5.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthTitle(title: '登录ChopChop'),
            SizedBox(height: 8.h),
            Text(
              '未注册手机号我们将自动为您注册',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: Colors.grey[400]),
            ),
            SizedBox(height: 30.h),
            
            // 邮箱输入框
            _buildEmailInput(),
            SizedBox(height: 20.h),
            
            // 手机号输入框
            _buildPhoneInput(),
            SizedBox(height: 30.h),
            
            // 获取验证码按钮
            _buildGetCodeButton(),
            SizedBox(height: 20.h),
            
            // 密码登录选项
            _buildPasswordLoginOption(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailInput() {
    return AuthInputField(
      controller: _emailController,
      hintText: '请输入邮箱',
      keyboardType: TextInputType.emailAddress,
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
            '+',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            height: 20.h,
            width: 1.w,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildGetCodeButton() {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authNotifierProvider);
        
        return AuthButton(
          text: authState.isSendingSms ? '发送中...' : '获取验证码',
          isLoading: authState.isSendingSms,
          onPressed: authState.isSendingSms ? null : () async {
            Logger.info("LoginPage", "获取验证码按钮点击事件");
            
            // 验证手机号
            if (_phoneController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('请输入手机号')),
              );
              return;
            }
            
            // 发送验证码
            final success = await ref.read(authNotifierProvider.notifier).sendVerificationCode(_phoneController.text, SmsSceneEnum.login);
            
            if (!mounted) return;
            
            if (success) {
              // 发送成功，跳转到验证码页面
              Navigate.push(context, Routes.verificationCode, arguments: {
                'phoneNumber': _phoneController.text,
                'email': _emailController.text,
                'type': VerificationCodeType.login,
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

  Widget _buildPasswordLoginOption() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Logger.info("LoginPage", "密码登录选项点击事件");
          Navigate.push(context, Routes.passwordLogin, arguments: _phoneController.text);
        },
        child: Text(
          '密码登录',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }
}

// 用于实现文字渐变的辅助 Widget (保留，以备将来使用)
class GradientText extends StatelessWidget {
  const GradientText(
      this.text, {
        super.key,
        required this.gradient,
        this.style,
      });

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}
