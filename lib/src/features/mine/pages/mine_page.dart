import 'package:chop_user/src/core/config/app_services.dart';
import 'package:chop_user/src/core/routing/navigate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unified_popups/unified_popups.dart';

import '../../../core/routing/routes.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/utils/pop/confirm.dart';
import '../../../core/widgets/common_spacing.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/language_sheet.dart';
import '../widgets/setting_item.dart';
import '../widgets/shop_enter.dart';
import '../widgets/userinfo_card.dart';

class SettingItemData {
  final String title;
  final String icon;
  final String? tip;
  final VoidCallback onTap;
  SettingItemData({
    required this.title,
    required this.icon,
    this.tip,
    required this.onTap,
  });
}

class MinePage extends ConsumerStatefulWidget {
  const MinePage({super.key});

  @override
  ConsumerState<MinePage> createState() => _MinePageState();
}

class _MinePageState extends ConsumerState<MinePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: null,
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.5],
              colors: [Color(0xFFDAE4F0), Color(0xFFFFFFFF)],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 48.h, 16.w, 16.h),
            child: Column(
              children: [
                UserinfoCard(),
                CommonSpacing.large,
                ShopEnter(),
                CommonSpacing.large,
                _buildSettingsList(l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsList(AppLocalizations l10n) {
    final List<SettingItemData> settingsData = [
      SettingItemData(
        title: l10n.profile,
        icon: 'assets/images/setting_1.png',
        onTap: () {
          Navigate.push(context, Routes.profile);
        },
      ),
      SettingItemData(
        title: l10n.deliveryAddress,
        icon: 'assets/images/setting_2.png',
        onTap: () {
          Navigate.push(context, Routes.address);
        },
      ),
      SettingItemData(
        title: l10n.help,
        icon: 'assets/images/setting_3.png',
        onTap: () {
          Navigate.push(context, Routes.help);
        },
      ),
      SettingItemData(
        title: l10n.accountSettings,
        icon: 'assets/images/setting_4.png',
        onTap: () {
          Logger.info('MinePage', '点击账号设置');
          // TODO: 跳转到账号设置页面
        },
      ),
      SettingItemData(
        title: l10n.language,
        icon: 'assets/images/setting_5.png',
        tip: AppServices.appSettings.languageModeName,
        onTap: () async {
          Logger.info('MinePage', '点击语言设置');
          await Pop.sheet(
            childBuilder: (dismiss) => LanguageSheet(dismiss: dismiss),
            title: l10n.selectLanguage,
            titlePadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          );
        },
      ),
      SettingItemData(
        title: l10n.privacyPolicy,
        icon: 'assets/images/setting_6.png',
        onTap: () {
          Logger.info('MinePage', '点击隐私政策');
          // TODO: 跳转到隐私政策页面
        },
      ),
      SettingItemData(
        title: l10n.platformAgreement,
        icon: 'assets/images/setting_7.png',
        onTap: () {
          Logger.info('MinePage', '点击平台协议');
          // TODO: 跳转到平台协议页面
        },
      ),
      SettingItemData(
        title: l10n.logout,
        icon: 'assets/images/setting_8.png',
        onTap: () async {
          final res = await confirm(
            l10n.logoutConfirmMessage,
            confirmText: l10n.btnConfirm,
            cancelText: l10n.btnCancel,
          );
          if (res != null && res == true) {
            try {
              Pop.loading();
              await ref.read(authNotifierProvider.notifier).logout();
              if (!mounted) return;
              Pop.hideLoading();
              Logger.info("MinePage", "登出成功，跳转到登录页面");
              Navigate.replace(context, Routes.login);
            } catch (e) {
              Logger.error("MinePage", "登出失败", error: e);
              if (!mounted) return;
            }
          }
        },
      ),
    ];

    return Column(
      children:
          settingsData
              .map(
                (data) => SettingItem(
                  title: data.title,
                  icon: data.icon,
                  tip: data.tip,
                  onTap: data.onTap,
                ),
              )
              .toList(),
    );
  }
}
