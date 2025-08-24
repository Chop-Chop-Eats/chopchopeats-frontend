import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 导入 services 包

class AppTheme {
  // 主体橙色
  static const Color primaryOrange = Color(0xFFFE5100);
  // Loading 状态按钮颜色
  static const Color loadingButtonColor = Color(0xFFFF9473);

  // 亮色主题
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: Colors.orange,
    scaffoldBackgroundColor: Colors.grey[100],
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryOrange,
      foregroundColor: Colors.white,
      //  添加 systemOverlayStyle
      systemOverlayStyle: SystemUiOverlayStyle(
        // 设置状态栏为透明
        statusBarColor: Colors.transparent,
        // 设置状态栏图标为深色
        statusBarIconBrightness: Brightness.dark,
        // 设置 Android 状态栏图标为深色（一些旧版本Android需要）
        statusBarBrightness: Brightness.light,
      ),
    ),
    fontFamily: 'PingFang SC',
  );

  // 暗色主题
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primarySwatch: Colors.orange,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      foregroundColor: primaryOrange,
      // 有appbar的页面设置 无appbar页面使用 AnnotatedRegion<SystemUiOverlayStyle>
      //  添加 systemOverlayStyle
      systemOverlayStyle: const SystemUiOverlayStyle(
        // 设置状态栏为透明
        statusBarColor: Colors.transparent,
        // 设置状态栏图标为浅色
        statusBarIconBrightness: Brightness.light,
        // 设置 Android 状态栏图标为浅色（一些旧版本Android需要）
        statusBarBrightness: Brightness.dark,
      ),
    ),
    fontFamily: 'PingFang SC',
  );
}
