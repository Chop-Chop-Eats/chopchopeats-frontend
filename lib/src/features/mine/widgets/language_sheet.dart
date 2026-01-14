import 'package:chop_user/src/core/utils/pop/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unified_popups/unified_popups.dart';

import '../../../core/constants/app_constant.dart';
import '../../../core/config/app_services.dart';
import '../../../core/enums/language_mode.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/l10n/locale_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger/logger.dart';
import '../services/mine_services.dart';

class LanguageSheet extends StatefulWidget {
  final VoidCallback dismiss;
  const LanguageSheet({super.key, required this.dismiss});

  @override
  State<LanguageSheet> createState() => _LanguageSheetState();
}

class _LanguageSheetState extends State<LanguageSheet> {
  @override
  void initState() {
    super.initState();
    _syncLanguageOnFirstOpen();
  }

  // 首次进入语言设置页时，同步当前语言到云端
  Future<void> _syncLanguageOnFirstOpen() async {
    final hasSynced = await AppServices.cache.get<bool>(
      AppConstants.languageSettingSynced,
    );
    final languageSetting = _resolveLanguageSetting(
      AppServices.appSettings.languageMode,
    );
    final cachedValue = await AppServices.cache.get<int>(
      AppConstants.languageSettingSyncedValue,
    );
    if (hasSynced == true && cachedValue == languageSetting) return;

    try {
      final success = await MineServices().updateLanguage(languageSetting);
      if (success) {
        await AppServices.cache.set<bool>(
          AppConstants.languageSettingSynced,
          true,
        );
        await AppServices.cache.set<int>(
          AppConstants.languageSettingSyncedValue,
          languageSetting,
        );
      }
    } catch (e) {
      Logger.error('LanguageSheet', '首次同步语言设置失败: $e');
    }
  }

  int _resolveLanguageSetting(LanguageMode languageMode) {
    switch (languageMode) {
      case LanguageMode.zh:
        return 1;
      case LanguageMode.en:
        return 2;
      case LanguageMode.system:
        final locale = AppServices.appSettings.locale ?? LocaleService.currentLocale;
        return locale.languageCode == 'zh' ? 1 : 2;
    }
  }

  Widget _buildLanguageItem(AppLocalizations l10n, LanguageMode languageMode) {
    final isSelected = languageMode == AppServices.appSettings.languageMode;
    return GestureDetector(
      onTap: () async {
        Pop.loading();
        final success = await MineServices().updateLanguage(
          _resolveLanguageSetting(languageMode),
        );
        try {
          if (!success) {
            toast.success(l10n.updateLanguageFailed);
            return;
          }
          await AppServices.appSettings.updateLanguageMode(languageMode);
          await AppServices.cache.set<bool>(
            AppConstants.languageSettingSynced,
            true,
          );
          await AppServices.cache.set<int>(
            AppConstants.languageSettingSyncedValue,
            _resolveLanguageSetting(languageMode),
          );
          toast.success(l10n.updateLanguageSuccess);
          widget.dismiss();
        } catch (e) {
          toast.error(l10n.updateLanguageFailed);
        } finally {
          Pop.hideLoading();
        }
        
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryOrange.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(languageMode.displayName, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.black),),
            if (isSelected)
              Icon(Icons.check, color: AppTheme.primaryOrange),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLanguageItem(l10n, LanguageMode.en),
        _buildLanguageItem(l10n, LanguageMode.zh),
        // _buildLanguageItem(l10n, LanguageMode.system),
      ],
    );
  }
}
