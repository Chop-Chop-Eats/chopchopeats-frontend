import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/logger/logger.dart';
import '../../../../core/routing/navigate.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/logo.dart';
import '../../../../core/providers/cache_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    Logger.info('SplashPage', '闪屏页面已初始化');
    _initializeApp();
  }

  /// 初始化应用
  Future<void> _initializeApp() async {
    Logger.info('SplashPage', '开始应用初始化');
    
    try {
      // 等待缓存服务初始化
      Logger.debug('SplashPage', '等待缓存服务初始化');
      await ref.read(cacheServiceProvider.future);
      
      // 模拟一些初始化延迟
      // await Future.delayed(const Duration(seconds: 2));
      
      Logger.debug('SplashPage', '初始化延迟完成，检查认证状态');
      
      // 等待认证仓库初始化
      final authRepository = await ref.read(authRepositoryProvider.future);
      
      // 检查认证状态
      final isLoggedIn = await authRepository.isLoggedIn();
      
      if (isLoggedIn) {
        Logger.info('SplashPage', '用户已登录，跳转到主页');
        _navigateToHome();
      } else {
        Logger.info('SplashPage', '用户未登录，跳转到登录页');
        _navigateToLogin();
      }
    } catch (e) {
      Logger.error('SplashPage', '应用初始化异常', error: e);
      // 发生异常时，默认跳转到登录页
      _navigateToLogin();
    }
  }

  /// 跳转到主页
  void _navigateToHome() {
    Logger.debug('SplashPage', '准备跳转到主页');
    if (mounted) {
      Navigate.replace(context, Routes.home);
    }
  }

  /// 跳转到登录页
  void _navigateToLogin() {
    Logger.debug('SplashPage', '准备跳转到登录页');
    if (mounted) {
       Navigate.replace(context, Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    Logger.debug('SplashPage', '构建闪屏页面 UI');
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            const Logo(),
            SizedBox(height: 32.h),
            
            // 加载指示器
            SizedBox(
              height: 24.h,
              width: 24.w,
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
