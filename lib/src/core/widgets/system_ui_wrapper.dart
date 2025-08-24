import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 系统UI包装组件
/// 
/// 用于统一管理页面的系统UI状态栏样式，确保在不同平台上的一致性
/// 特别解决Android设备上状态栏半透明遮盖的问题
class SystemUIWrapper extends StatelessWidget {
  final Widget child;
  final bool useAppBarTheme;
  final SystemUiOverlayStyle? customStyle;
  final Color? statusBarColor;
  final Brightness? statusBarIconBrightness;
  final Brightness? statusBarBrightness;

  const SystemUIWrapper({
    super.key,
    required this.child,
    this.useAppBarTheme = true,
    this.customStyle,
    this.statusBarColor,
    this.statusBarIconBrightness,
    this.statusBarBrightness,
  });

  @override
  Widget build(BuildContext context) {
    // 获取系统UI样式
    final systemUiOverlayStyle = _getSystemUiOverlayStyle(context);
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle,
      child: child,
    );
  }

  /// 获取系统UI覆盖样式
  SystemUiOverlayStyle _getSystemUiOverlayStyle(BuildContext context) {
    // 如果提供了自定义样式，优先使用
    if (customStyle != null) {
      return customStyle!;
    }

    // 如果指定了具体参数，使用参数构建样式
    if (statusBarColor != null || statusBarIconBrightness != null || statusBarBrightness != null) {
      return SystemUiOverlayStyle(
        statusBarColor: statusBarColor ?? Colors.transparent,
        statusBarIconBrightness: statusBarIconBrightness,
        statusBarBrightness: statusBarBrightness,
      );
    }

    // 如果使用AppBar主题，从主题中获取样式
    if (useAppBarTheme) {
      final theme = Theme.of(context);
      final appBarTheme = theme.appBarTheme;
      
      if (appBarTheme.systemOverlayStyle != null) {
        return appBarTheme.systemOverlayStyle!;
      }
      
      // 如果AppBar主题没有设置systemOverlayStyle，根据主题亮度自动设置
      final isDark = theme.brightness == Brightness.dark;
      return SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      );
    }

    // 默认样式：透明状态栏，根据主题自动调整图标亮度
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    );
  }
}

/// 认证页面专用的系统UI包装组件
/// 
/// 专门为认证相关页面设计，确保状态栏样式的一致性
class AuthPageWrapper extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const AuthPageWrapper({
    super.key,
    required this.child,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SystemUIWrapper(
      // 认证页面通常使用浅色主题，状态栏图标应该是深色
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      child: Scaffold(
        backgroundColor: backgroundColor ?? Colors.white,
        body: child,
      ),
    );
  }
}

/// 带渐变背景的认证页面包装组件
/// 
/// 专门为有装饰性背景的认证页面设计
class AuthGradientPageWrapper extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const AuthGradientPageWrapper({
    super.key,
    required this.child,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SystemUIWrapper(
      // 渐变背景页面通常使用浅色主题，状态栏图标应该是深色
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      child: Scaffold(
        backgroundColor: backgroundColor ?? const Color(0xFFF3F4F6),
        body: child,
      ),
    );
  }
}
