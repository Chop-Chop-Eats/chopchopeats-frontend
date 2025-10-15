
import 'package:flutter/material.dart';
import '../constants/app_constant.dart';
import '../utils/logger/logger.dart';
import 'app_services.dart';

class AppSettings extends ChangeNotifier {
  // 私有构造函数
  AppSettings._();

  // 主题模式
  late ThemeMode _themeMode;
  // 语言
  late Locale _locale;
  /// 经度
  late double _longitude = -71.4128;
  /// 纬度
  late double _latitude = 41.824;

  /// 页面大小
  late final int _pageSize = 10;

  // 访问主题模式
  ThemeMode get themeMode => _themeMode;
  // 访问语言
  Locale get locale => _locale;
  /// 访问经度
  double get longitude => _longitude;
  /// 访问纬度
  double get latitude => _latitude;
  /// 访问页面大小
  int get pageSize => _pageSize;

  /// 初始化 AppSettings
  /// 从缓存中加载用户偏好，如果不存在则使用默认值
  static Future<AppSettings> init() async {
    final settings = AppSettings._();

    // 加载主题设置
    final themeName = await AppServices.cache.get<String>(AppConstants.themeMode);
    settings._themeMode = ThemeMode.values.firstWhere((e) => e.name == themeName, orElse: () => ThemeMode.system, // 默认跟随系统
    );

    // 加载语言设置
    final langCode = await AppServices.cache.get<String>(AppConstants.languageCode);
    settings._locale = langCode != null ? Locale(langCode) : const Locale('en'); // 默认英文

    return settings;
  }

  /// 更新主题模式
  Future<void> updateThemeMode(ThemeMode newThemeMode) async {
    if (newThemeMode == _themeMode) return; // 如果没有变化，则不执行任何操作

    _themeMode = newThemeMode;
    Logger.info("AppSettings", "Theme mode updated to: ${_themeMode.name}");

    // 通知监听者 UI 需要更新
    notifyListeners();

    // 持久化到本地
    await AppServices.cache.set<String>(AppConstants.themeMode, _themeMode.name);
  }

  /// 更新语言
  Future<void> updateLocale(Locale newLocale) async {
    if (newLocale == _locale) return;

    _locale = newLocale;
    Logger.info("AppSettings", "Locale updated to: ${_locale.languageCode}");

    // 通知监听者 UI 需要更新
    notifyListeners();

    // 持久化到本地
    await AppServices.cache.set<String>(AppConstants.languageCode, _locale.languageCode);
  }

   /// 更新经度
  Future<void> setLongitude(double longitude) async {
    _longitude = longitude;
  }

  /// 更新纬度
  Future<void> setLatitude(double latitude) async {
    _latitude = latitude;
  }
}