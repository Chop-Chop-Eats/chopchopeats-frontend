
import 'package:flutter/material.dart';

import '../constants/app_constant.dart';
import '../enums/language_mode.dart';
import '../l10n/locale_service.dart';
import '../utils/logger/logger.dart';
import 'app_services.dart';

class AppSettings extends ChangeNotifier {
  // 私有构造函数
  AppSettings._();

  // 主题模式
  late ThemeMode _themeMode;
  // 语言模式
  late LanguageMode _languageMode;
  /// 经度
  double _longitude = -71.4128;

  /// 纬度
  double _latitude = 41.824;

  /// 当前选定位置的展示文案
  String _locationLabel = 'Northwalk Rd, Toronto';

  /// 页面大小
  final int _pageSize = 10;

  // 访问主题模式
  ThemeMode get themeMode => _themeMode;
  // 访问语言模式
  LanguageMode get languageMode => _languageMode;

  // 访问语言模式名称
  String get languageModeName {
    switch (_languageMode) {
      case LanguageMode.zh:
        return '中文';
      case LanguageMode.en:
        return 'English';
      case LanguageMode.system:
        return '系统';
    }
  }

  // 获取实际的 Locale（根据语言模式）
  Locale? get locale {
    switch (_languageMode) {
      case LanguageMode.zh:
        return const Locale('zh');
      case LanguageMode.en:
        return const Locale('en');
      case LanguageMode.system:
        return null; // null 表示跟随系统
    }
  }
  /// 访问经度
  double get longitude => _longitude;
  /// 访问纬度
  double get latitude => _latitude;
  /// 访问页面大小
  int get pageSize => _pageSize;
  /// 访问位置标题
  String get locationLabel => _locationLabel;

  /// 初始化 AppSettings
  /// 从缓存中加载用户偏好，如果不存在则使用默认值
  static Future<AppSettings> init() async {
    final settings = AppSettings._();

    // 加载主题设置
    final themeName = await AppServices.cache.get<String>(AppConstants.themeMode);
    settings._themeMode = ThemeMode.values.firstWhere((e) => e.name == themeName, orElse: () => ThemeMode.system, // 默认跟随系统
    );

    // 加载语言设置
    final languageModeStr = await AppServices.cache.get<String>(AppConstants.languageMode);
    settings._languageMode = LanguageMode.fromString(languageModeStr); // 默认跟随系统
    
    // 加载位置坐标
    final cachedLongitude = await AppServices.cache.get<double>(AppConstants.longitude);
    final cachedLatitude = await AppServices.cache.get<double>(AppConstants.latitude);
    final cachedLabel = await AppServices.cache.get<String>(AppConstants.locationLabel);

    if (cachedLongitude != null) {
      settings._longitude = cachedLongitude;
    }
    if (cachedLatitude != null) {
      settings._latitude = cachedLatitude;
    }
    if (cachedLabel != null && cachedLabel.isNotEmpty) {
      settings._locationLabel = cachedLabel;
    }

    // 初始化 LocaleService（使用系统默认语言或设置的语言）
    final initialLocale = settings.locale ?? const Locale('zh'); // 如果跟随系统，先用中文初始化
    LocaleService.updateLocale(initialLocale);

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

  /// 更新语言模式
  Future<void> updateLanguageMode(LanguageMode newMode) async {
    if (newMode == _languageMode) return;

    _languageMode = newMode;
    Logger.info("AppSettings", "Language mode updated to: ${_languageMode.name}");

    // 更新 LocaleService（用于 Model 层访问）
    final newLocale = locale ?? const Locale('zh'); // 如果是system模式，默认使用中文
    LocaleService.updateLocale(newLocale);

    // 通知监听者 UI 需要更新
    notifyListeners();

    // 持久化到本地
    await AppServices.cache.set<String>(AppConstants.languageMode, _languageMode.name);
  }

  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final labelValue = label?.trim();
    var hasLabelUpdate = false;
    if (labelValue != null && labelValue.isNotEmpty && labelValue != _locationLabel) {
      _locationLabel = labelValue;
      hasLabelUpdate = true;
    }

    final hasPositionUpdate = _latitude != latitude || _longitude != longitude;
    _latitude = latitude;
    _longitude = longitude;

    if (hasPositionUpdate || hasLabelUpdate) {
      notifyListeners();
    }

    await AppServices.cache.set<double>(AppConstants.latitude, _latitude);
    await AppServices.cache.set<double>(AppConstants.longitude, _longitude);
    if (hasLabelUpdate) {
      await AppServices.cache.set<String>(AppConstants.locationLabel, _locationLabel);
    }
  }

  Future<void> updateLocationLabel(String label) async {
    final value = label.trim();
    if (value.isEmpty || value == _locationLabel) return;
    _locationLabel = value;
    notifyListeners();
    await AppServices.cache.set<String>(AppConstants.locationLabel, _locationLabel);
  }

  /// 更新经度
  Future<void> setLongitude(double longitude) {
    return updateLocation(latitude: _latitude, longitude: longitude);
  }

  /// 更新纬度
  Future<void> setLatitude(double latitude) {
    return updateLocation(latitude: latitude, longitude: _longitude);
  }
}