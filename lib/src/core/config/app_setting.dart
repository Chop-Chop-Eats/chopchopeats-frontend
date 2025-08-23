
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/cache_constant.dart';
import '../utils/logger/logger.dart';
import '../../app_services.dart';

class AppSettings extends ChangeNotifier {
  // 私有构造函数
  AppSettings._();

  // 内部状态
  late ThemeMode _themeMode;
  late Locale _locale;

  // 外部只读访问器
  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  /// 初始化 AppSettings
  /// 从缓存中加载用户偏好，如果不存在则使用默认值
  static Future<AppSettings> init() async {
    final settings = AppSettings._();

    // 加载主题设置
    final themeName = await AppServices.cache.get<String>(CacheConstant.themeMode);
    settings._themeMode = ThemeMode.values.firstWhere((e) => e.name == themeName, orElse: () => ThemeMode.system, // 默认跟随系统
    );

    // 加载语言设置
    final langCode = await AppServices.cache.get<String>(CacheConstant.languageCode);
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
    await AppServices.cache.set<String>(CacheConstant.themeMode, _themeMode.name);
  }

  /// 更新语言
  Future<void> updateLocale(Locale newLocale) async {
    if (newLocale == _locale) return;

    _locale = newLocale;
    Logger.info("AppSettings", "Locale updated to: ${_locale.languageCode}");

    // 通知监听者 UI 需要更新
    notifyListeners();

    // 持久化到本地
    await AppServices.cache.set<String>(CacheConstant.languageCode, _locale.languageCode);
  }
}