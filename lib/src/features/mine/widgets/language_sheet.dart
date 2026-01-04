import 'package:chop_user/src/core/utils/pop/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unified_popups/unified_popups.dart';

import '../../../core/config/app_services.dart';
import '../../../core/enums/language_mode.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../services/mine_services.dart';

class LanguageSheet extends StatelessWidget {
  final VoidCallback dismiss;
  const LanguageSheet({super.key, required this.dismiss});


  Widget _buildLanguageItem( AppLocalizations l10n, LanguageMode languageMode ) {
    final isSelected = languageMode == AppServices.appSettings.languageMode;
    return GestureDetector(
      onTap: () async {
        Pop.loading();
        final success = await MineServices().updateLanguage(languageMode == LanguageMode.zh ? 1 : 2);
        try {
          if (!success) {
            toast.success(l10n.updateLanguageFailed);
            return;
          }
          await AppServices.appSettings.updateLanguageMode(languageMode);
          toast.success(l10n.updateLanguageSuccess);
          dismiss();
        } catch (e) {
          toast.error(l10n.updateLanguageFailed);
        }finally {
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
        _buildLanguageItem(l10n, LanguageMode.zh),
        _buildLanguageItem(l10n, LanguageMode.en),
        // _buildLanguageItem(l10n, LanguageMode.system),
      ],
    );
  }
}
