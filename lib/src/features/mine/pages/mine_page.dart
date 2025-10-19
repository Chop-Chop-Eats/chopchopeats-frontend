import 'package:chop_user/src/core/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/routing/navigate.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_indicator.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/enums/language_mode.dart';
import '../../../core/config/app_services.dart';
import '../../auth/providers/auth_provider.dart';

class MinePage extends ConsumerStatefulWidget {
  const MinePage({super.key});

  @override
  ConsumerState<MinePage> createState() => _MinePageState();
}

class _MinePageState extends ConsumerState<MinePage> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final l10n = AppLocalizations.of(context)!;
    final currentLanguageMode = AppServices.appSettings.languageMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabMine),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 显示用户信息
            if (authState.isAuthenticated && authState.user != null) ...[
              const Text("欢迎回来！"),
              SizedBox(height: 8.h),
              Text("用户ID: ${authState.user!.userId}"),
              SizedBox(height: 20.h),
            ],
            
            // 语言设置区域
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.languageSettings,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // 跟随系统
                      RadioListTile<LanguageMode>(
                        title: Text(l10n.languageSystem),
                        value: LanguageMode.system,
                        groupValue: currentLanguageMode,
                        onChanged: (value) async {
                          if (value != null) {
                            await AppServices.appSettings.updateLanguageMode(value);
                            setState(() {});
                          }
                        },
                      ),
                      // 中文
                      RadioListTile<LanguageMode>(
                        title: Text(l10n.languageChinese),
                        value: LanguageMode.zh,
                        groupValue: currentLanguageMode,
                        onChanged: (value) async {
                          if (value != null) {
                            await AppServices.appSettings.updateLanguageMode(value);
                            setState(() {});
                          }
                        },
                      ),
                      // 英文
                      RadioListTile<LanguageMode>(
                        title: Text(l10n.languageEnglish),
                        value: LanguageMode.en,
                        groupValue: currentLanguageMode,
                        onChanged: (value) async {
                          if (value != null) {
                            await AppServices.appSettings.updateLanguageMode(value);
                            setState(() {});
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 20.h),
            
            // 登出按钮
            ElevatedButton(
              onPressed: authState.isLoading ? null : () async {
                Logger.info("MinePage", "开始登出流程");
                
                try {
                  await ref.read(authNotifierProvider.notifier).logout();
                  
                  if (!mounted) return;
                  
                  // 登出成功，跳转到登录页面
                  Logger.info("MinePage", "登出成功，跳转到登录页面");
                  Navigate.replace(context, Routes.login);
                } catch (e) {
                  Logger.error("MinePage", "登出失败", error: e);
                  if (!mounted) return;
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('登出失败: ${e.toString()}')),
                  );
                }
              },
              child: authState.isLoading ? SizedBox(
                width: 20.w,
                height: 20.h,
                child: const CommonIndicator(),
              ) : const Text("Log out"),
            ),
          ],
        ),
      ),
    );
  }
}