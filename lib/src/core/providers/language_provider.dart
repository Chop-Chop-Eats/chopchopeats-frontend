import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_services.dart';
import '../enums/language_mode.dart';

/// 语言模式状态管理
class LanguageNotifier extends StateNotifier<LanguageMode> {
  LanguageNotifier() : super(AppServices.appSettings.languageMode);

  /// 切换语言模式
  Future<void> changeLanguage(LanguageMode mode) async {
    if (state == mode) return;
    
    state = mode;
    await AppServices.appSettings.updateLanguageMode(mode);
  }
}

/// 语言模式 Provider
final languageProvider = StateNotifierProvider<LanguageNotifier, LanguageMode>((ref) {
  return LanguageNotifier();
});

