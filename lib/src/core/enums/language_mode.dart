/// 语言模式枚举
/// 支持三种模式：跟随系统、强制中文、强制英文
enum LanguageMode {
  /// 跟随系统语言
  system,
  
  /// 强制使用中文
  zh,
  
  /// 强制使用英文
  en;

  /// 从字符串转换为枚举
  static LanguageMode fromString(String? value) {
    if (value == null) return LanguageMode.system;
    return LanguageMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LanguageMode.system,
    );
  }

  /// 获取显示名称（用于UI展示）
  String get displayName {
    switch (this) {
      case LanguageMode.system:
        return '跟随系统 / System';
      case LanguageMode.zh:
        return '中文 / Chinese';
      case LanguageMode.en:
        return '英文 / English';
    }
  }
}

