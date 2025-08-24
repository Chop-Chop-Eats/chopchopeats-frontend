import 'package:chop_user/src/core/routing/navigate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger/logger.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/system_ui_wrapper.dart';
import 'verification_code_page.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_title.dart';
import '../widgets/auth_input_field.dart';
import '../widgets/auth_button.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController(text: '123456789@gmail.com');
  final _phoneController = TextEditingController(text: '7185937697');

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
      child: Stack(
        children: [
          // 装饰性圆形渐变背景光晕
          _buildDecorativeCircles(),
          // 主体内容
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 60),
                  _buildLoginForm(context),
                  // 底部协议
                  const SizedBox(height: 100),
                  const AuthFooter()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 创建装饰性圆形渐变光晕
  Widget _buildDecorativeCircles() {
    return Stack(
      children: [
        // 紫色光晕 (左上)
        Positioned(
          top: -240,
          left: -330,
          child: _buildDecorativeCircle(
            color: const Color(0xFFDAC5FF),
            radius: 300,
          ),
        ),
        // 橙色光晕 (右侧)
        Positioned(
          top: -100,
          right: -300,
          child: _buildDecorativeCircle(
            color: const Color(0xFFFFDAC5),
            radius: 300,
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
            color.withOpacity(0),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    const textStyle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 60.0, left: 16.0, right: 16.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'The taste of home',
                style: textStyle,
              ),
              Row(
                children: [
                  const Text(
                    'without the ',
                    style: textStyle,
                  ),
                  Text(
                    'cooking',
                    style: textStyle.copyWith(color: const Color(0xFFFF8A5B)),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: -50,
            right: 0,
            child: Image.asset(
              'assets/images/chef.png',
              height: 180,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(10),
              spreadRadius: 5,
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthTitle(title: '登录ChopChop'),
            const SizedBox(height: 8),
            Text(
              '未注册手机号我们将自动为您注册',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            
            // 邮箱输入框
            _buildEmailInput(),
            const SizedBox(height: 20),
            
            // 手机号输入框
            _buildPhoneInput(),
            const SizedBox(height: 30),
            
            // 获取验证码按钮
            _buildGetCodeButton(),
            const SizedBox(height: 20),
            
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
          const Text(
            '+1',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 20,
            width: 1,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildGetCodeButton() {
    return AuthButton(
      text: '获取验证码',
      onPressed: () {
        Logger.info("LoginPage", "获取验证码按钮点击事件");
        Navigate.push(context, Routes.verificationCode, arguments: {
          'phoneNumber': _phoneController.text,
          'type': VerificationCodeType.login,
        });
      },
    );
  }

  Widget _buildPasswordLoginOption() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Logger.info("LoginPage", "密码登录选项点击事件");
          Navigate.push(context, Routes.passwordLogin);
        },
        child: Text(
          '密码登录',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
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
