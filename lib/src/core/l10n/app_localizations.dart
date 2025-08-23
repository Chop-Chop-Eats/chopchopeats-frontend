import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// 定义所有需要国际化的文本
abstract class AppLocalizations {
  // 用于从 Widget 树中获取实例
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // 定义一个 Delegate
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // ============== App 文本 ==============
  String get appTitle;
  String get settings;
  String get language;
  String get theme;
  String get themeLight;
  String get themeDark;
  String get themeSystem;
  String get homePageTitle;
}

// Delegate 类，Flutter 会用它来加载对应的语言类
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  // 判断该 Delegate 是否支持给定的 Locale
  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  // 根据当前的 Locale，加载并返回一个 AppLocalizations 的实例
  @override
  Future<AppLocalizations> load(Locale locale) {
    // 使用 SynchronousFuture 是一个优化，因为我们的加载是同步的，不需要异步操作
    return SynchronousFuture<AppLocalizations>(
      locale.languageCode == 'zh' ? AppLocalizationsZh() : AppLocalizationsEn(),
    );
  }

  // 是否需要重新加载，通常返回 false
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
