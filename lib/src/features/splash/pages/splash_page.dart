import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/config/app_services.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/routing/navigate.dart';
import '../../../core/routing/routes.dart';
import '../../../core/widgets/logo.dart';
import '../../../core/widgets/common_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/services/auth_services.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> with WidgetsBindingObserver {
  bool _isInitialized = false;
  // 是否授权定位
  bool _isLocationPermission = false;
  // 是否正在检查权限（防止重复检查）
  bool _isCheckingPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Logger.info('SplashPage', '闪屏页面已初始化');
    // 延迟初始化，避免阻塞UI渲染
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _initializeApp();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 当应用从后台返回前台时，重新检查定位权限
    if (state == AppLifecycleState.resumed && 
        !_isLocationPermission && 
        !_isCheckingPermission) {
      Logger.info('SplashPage', '应用返回前台，重新检查定位权限');
      _recheckLocationPermission();
    }
  }

  /// 保存位置信息到全局配置
  void _saveLocationToSettings(Position position) {
    AppServices.appSettings.setLongitude(position.longitude);
    AppServices.appSettings.setLatitude(position.latitude);
    Logger.info('SplashPage', '✅ 已保存经纬度 - 经度=${AppServices.appSettings.longitude}, 纬度=${AppServices.appSettings.latitude}');
  }

  /// 重新检查定位权限（用户从设置返回后）
  Future<void> _recheckLocationPermission() async {
    if (_isCheckingPermission) {
      Logger.debug('SplashPage', '正在检查权限中，跳过本次检查');
      return;
    }
    
    _isCheckingPermission = true;
    
    try {
      // 只检查权限状态，不自动请求
      final permission = await Geolocator.checkPermission();
      Logger.info('SplashPage', '重新检查定位权限状态: $permission');
      
      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        // 权限已授予，尝试获取位置（此时不会再请求权限）
        final position = await _getPositionWithoutRequest();
        if (position != null && mounted) {
          // 保存经纬度到全局配置
          _saveLocationToSettings(position);
          setState(() {
            _isLocationPermission = true;
          });
          // 继续初始化流程
          _continueInitialization();
        }
      } else {
        Logger.info('SplashPage', '权限仍未授予，保持在引导页');
      }
    } finally {
      _isCheckingPermission = false;
    }
  }

  /// 获取位置（不请求权限，仅在已有权限时获取）
  Future<Position?> _getPositionWithoutRequest() async {
    try {
      // 先尝试获取最后已知位置
      final lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        return lastKnownPosition;
      }
      
      // 获取当前位置
      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 100,
        timeLimit: const Duration(seconds: 10),
      );
      
      final position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          Logger.warn('SplashPage', '获取当前位置超时');
          throw Exception('获取位置超时');
        },
      );

      return position;
    } catch (e) {
      Logger.error('SplashPage', '获取位置失败', error: e);
      return null;
    }
  }

  /// 继续应用初始化（在获得定位权限后）
  Future<void> _continueInitialization() async {
    try {
      // 缓存服务初始化
      Logger.info('SplashPage', '缓存服务初始化');
      final isLoggedIn = await AuthServices().isLoggedIn();
      if (mounted) {
        // 延迟一秒 
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            isLoggedIn ? _navigateToHome() : _navigateToLogin();
          }
        });
      }
    } catch (e) {
      Logger.error('SplashPage', '应用初始化异常', error: e);
      // 发生异常时，默认跳转到登录页
      if (mounted) {
        _navigateToLogin();
      }
    }
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
      // 先尝试获取最后已知位置
      final lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        Logger.info('SplashPage', '获取到最后已知位置: ${lastKnownPosition.latitude}, ${lastKnownPosition.longitude}');
        return lastKnownPosition;
      }
      
      Logger.info('SplashPage', '最后已知位置为空，开始获取当前位置');
      
      // 如果没有最后已知位置，则获取当前位置
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
        // 保存经纬度到全局配置
        _saveLocationToSettings(position);
        
        setState(() {
          _isLocationPermission = true;
        });
        // 继续初始化流程
        await _continueInitialization();
      } else {
        Logger.warn('SplashPage', '⚠️ 未能获取定位信息，停留在权限引导页');
        setState(() {
          _isLocationPermission = false;
        });
      }
    } catch (e) {
      Logger.error('SplashPage', '应用初始化异常', error: e);
      setState(() {
        _isLocationPermission = false;
      });
    }
  }

  /// 跳转到主页
  void _navigateToHome() {
    Logger.info('SplashPage', '准备跳转到主页');
    if (mounted) {
      Navigate.replace(context, Routes.home);
    }
  }

  /// 跳转到登录页
  void _navigateToLogin() {
    Logger.info('SplashPage', '准备跳转到登录页');
    if (mounted) {
      Navigate.replace(context, Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    Logger.info('SplashPage', '构建闪屏页面 UI');
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _buildLocationPermissionView(context),
      ),
    );
  }

  /// 定位权限引导视图（未授权定位）
  Widget _buildLocationPermissionView(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        children: [
          // 顶部 Logo
          CommonSpacing.height(60),
          const Center(child: Logo()),
          
          if(!_isLocationPermission)...[
            const Spacer(),
            // 位置图标
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_rounded,
                size: 32.sp,
                color: AppTheme.primaryOrange,
              ),
            ),
            
            CommonSpacing.extraLarge,
            
            // 标题
            Text(
              '需要位置权限',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            CommonSpacing.standard,
            
            Text(
              '为了给您提供更好的服务',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black45,
              ),
            ),
            
            CommonSpacing.extraLarge,

            _buildPermissionItem(
              icon: Icons.store_rounded,
              title: '发现附近商家',
              description: '准确展示您身边的餐厅和优惠',
            ),
            
            CommonSpacing.large,
            
            _buildPermissionItem(
              icon: Icons.local_shipping_rounded,
              title: '计算配送距离',
              description: '为您预估精准的配送费和送达时间',
            ),
            
            CommonSpacing.large,
            
            _buildPermissionItem(
              icon: Icons.route_rounded,
              title: '规划最佳路线',
              description: '帮助骑手更快地将美食送到您手中',
            ),
            
            const Spacer(),
            
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () async {
                  Logger.info('SplashPage', '用户点击前往设置开启定位');
                  await Geolocator.openAppSettings();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  '前往设置开启',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            CommonSpacing.standard,
            
            Text(
              '开启后请返回应用继续使用',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.black38,
              ),
            ),

            CommonSpacing.height(40),
          ]
        ],
      ),
    );
  }

  /// 构建权限说明项
  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 图标
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: AppTheme.primaryOrange.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            icon,
            size: 22.sp,
            color: AppTheme.primaryOrange,
          ),
        ),
        
        CommonSpacing.width(12),
        
        // 文字内容
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              CommonSpacing.small,
              Text(
                description,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
