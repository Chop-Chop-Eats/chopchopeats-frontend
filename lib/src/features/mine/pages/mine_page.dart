import 'package:chop_user/src/core/config/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unified_popups/unified_popups.dart';

import '../../../core/enums/language_mode.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/widgets/common_spacing.dart';
import '../widgets/language_sheet.dart';
import '../widgets/setting_item.dart';
import '../widgets/shop_enter.dart';
import '../widgets/userinfo_card.dart';

class MinePage extends ConsumerStatefulWidget {
  const MinePage({super.key});

  @override
  ConsumerState<MinePage> createState() => _MinePageState();
}

class _MinePageState extends ConsumerState<MinePage> {
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
                _buildSettingsList(l10n),              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsList(AppLocalizations l10n) {
    final settingsData = [
      {
        'title': l10n.profile,
        'icon': 'assets/images/setting_1.png',
        'onTap': () {
          Logger.info('MinePage', '点击个人资料');
          // TODO: 跳转到个人资料页面
        },
      },
      {
        'title': l10n.deliveryAddress,
        'icon': 'assets/images/setting_2.png',
        'onTap': () {
          Logger.info('MinePage', '点击收货地址');
          // TODO: 跳转到收货地址页面
        },
      },
      {
        'title': l10n.help,
        'icon': 'assets/images/setting_3.png',
        'onTap': () {
          Logger.info('MinePage', '点击获取帮助');
          // TODO: 跳转到帮助页面
        },
      },
      {
        'title': l10n.accountSettings,
        'icon': 'assets/images/setting_4.png',
        'onTap': () {
          Logger.info('MinePage', '点击账号设置');
          // TODO: 跳转到账号设置页面
        },
      },
      {
        'title': l10n.language,
        'icon': 'assets/images/setting_5.png',
        'tip': AppServices.appSettings.languageModeName,
        'onTap': () async {
          Logger.info('MinePage', '点击语言设置');
          await Pop.sheet(
            childBuilder: (dismiss) => LanguageSheet(dismiss: dismiss),
            title: l10n.selectLanguage,
            titlePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          );
        },
      },
      {
        'title': l10n.privacyPolicy,
        'icon': 'assets/images/setting_6.png',
        'onTap': () {
          Logger.info('MinePage', '点击隐私政策');
          // TODO: 跳转到隐私政策页面
        },
      },
      {
        'title': l10n.platformAgreement,
        'icon': 'assets/images/setting_7.png',
        'onTap': () {
          Logger.info('MinePage', '点击平台协议');
          // TODO: 跳转到平台协议页面
        },
      },
      {
        'title': l10n.logout,
        'icon': 'assets/images/setting_8.png',
        'onTap': () {
          Logger.info('MinePage', '点击退出登录');
        },
      },
    ];

    return Column(
      children: settingsData.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;
        
        return Column(
          children: [
            SettingItem(
              key: ValueKey('setting_$index'),
              title: data['title'] as String,
              icon: data['icon'] as String,
              tip: data['tip'] as String?,
              onTap: data['onTap'] as VoidCallback,
            ),
            if (index < settingsData.length - 1) CommonSpacing.medium,
          ],
        );
      }).toList(),
    );
  }
}
