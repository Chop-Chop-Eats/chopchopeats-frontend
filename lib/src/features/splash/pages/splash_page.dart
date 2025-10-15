import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/routing/navigate.dart';
import '../../../core/routing/routes.dart';
import '../../../core/widgets/logo.dart';
import '../../auth/services/auth_services.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    Logger.info('SplashPage', '闪屏页面已初始化');
    // 延迟初始化，避免阻塞UI渲染
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        // 延迟执行
        Future.delayed(const Duration(seconds: 1), () { 
          _initializeApp();
        });
      }
    });
  }


  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    Logger.info('SplashPage', '定位服务是否开启: $serviceEnabled');
    if (!serviceEnabled) {
      Logger.warn('SplashPage', '定位服务未开启');
      return null;
    }

    permission = await Geolocator.checkPermission();
    Logger.info('SplashPage', '定位权限: $permission');
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      Logger.info('SplashPage', '请求定位权限结果: $permission');
      if (permission == LocationPermission.denied) {
        Logger.warn('SplashPage', '用户拒绝了定位权限');
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      Logger.warn('SplashPage', '定位权限被永久拒绝');
      return null;
    } 

    Logger.info('SplashPage', '开始获取当前位置...');
    
    try {
      // 先尝试获取最后已知位置（速度快）
      final lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        Logger.info('SplashPage', '获取到最后已知位置: ${lastKnownPosition.latitude}, ${lastKnownPosition.longitude}');
        return lastKnownPosition;
      }
      
      Logger.info('SplashPage', '最后已知位置为空，开始获取当前位置');
      
      // 如果没有最后已知位置，则获取当前位置（添加超时）
      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.medium, // 改为中等精度，更快
        distanceFilter: 100,
        timeLimit: const Duration(seconds: 10), // 添加10秒超时
      );
      
      final position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      ).timeout(
        const Duration(seconds: 15), // 额外的超时保护
        onTimeout: () {
          Logger.warn('SplashPage', '获取当前位置超时');
          throw Exception('获取位置超时');
        },
      );
      
      Logger.info('SplashPage', '成功获取当前位置: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      Logger.error('SplashPage', '获取位置失败', error: e);
      return null;
    }
  }

  /// 初始化应用
  Future<void> _initializeApp() async {
    if (_isInitialized) return; // 防止重复初始化
    
    Logger.info('SplashPage', '开始应用初始化');
    _isInitialized = true;
    
    try {
      // 获取定位信息
      final position = await _determinePosition();
      
      if (position != null) {
        Logger.info('SplashPage', '✅ 定位成功: 纬度=${position.latitude}, 经度=${position.longitude}');
      } else {
        Logger.warn('SplashPage', '⚠️ 未能获取定位信息，继续后续流程');
      }

      // 缓存服务初始化
      Logger.debug('SplashPage', '缓存服务初始化');
  
      final isLoggedIn = await AuthServices().isLoggedIn();
      
      if (mounted) {
        if (isLoggedIn) {
          Logger.info('SplashPage', '用户已登录，跳转到主页');
          _navigateToHome();
        } else {
          Logger.info('SplashPage', '用户未登录，跳转到登录页');
          _navigateToLogin();
        }
      }
    } catch (e) {
      Logger.error('SplashPage', '应用初始化异常', error: e);
      // 发生异常时，默认跳转到登录页
      if (mounted) {
        _navigateToLogin();
      }
    }
  }

  /// 跳转到主页
  void _navigateToHome() {
    Logger.debug('SplashPage', '准备跳转到主页');
    if (mounted) {
      // Navigate.replace(context, Routes.home);
    }
  }

  /// 跳转到登录页
  void _navigateToLogin() {
    Logger.debug('SplashPage', '准备跳转到登录页');
    if (mounted) {
      //  Navigate.replace(context, Routes.login);
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
            const Logo(),
          ],
        ),
      ),
    );
  }
}
