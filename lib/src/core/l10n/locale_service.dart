import 'package:flutter/material.dart';

/// 语言服务
/// 提供全局的语言访问，用于 Model 层获取当前语言
class LocaleService {
  LocaleService._();

  /// 当前语言
  static Locale _currentLocale = const Locale('en');

  /// 更新当前语言
  static void updateLocale(Locale locale) {
    _currentLocale = locale;
  }

  /// 获取当前语言
  static Locale get currentLocale => _currentLocale;

  /// 判断当前是否为中文
  static bool get isZh => _currentLocale.languageCode == 'zh';

  /// 判断当前是否为英文
  static bool get isEn => _currentLocale.languageCode == 'en';

  /// 获取本地化文本（带兜底逻辑）
  /// 如果当前语言的文本为空，则使用另一个语言的文本作为兜底
  static String getLocalizedText(String? zhText, String? enText) {
    if (isZh) {
      // 当前是中文，优先返回中文，中文为空则返回英文兜底
      return zhText ?? enText ?? '';
    } else {
      // 当前是英文，优先返回英文，英文为空则返回中文兜底
      return enText ?? zhText ?? '';
    }
  }
}

