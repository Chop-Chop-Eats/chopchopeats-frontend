import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../l10n/app_localizations.dart';
import '../l10n/locale_service.dart';
import '../routing/router.dart';
import '../routing/routes.dart';
import '../theme/app_theme.dart';
import 'app_services.dart';

class App extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const App({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppServices.appSettings,
      builder: (context, child) {
        return ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              navigatorKey: navigatorKey,
              title: "Chop Chop",
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              // themeMode: AppServices.appSettings.themeMode,
              themeMode: ThemeMode.light,
              locale: AppServices.appSettings.locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', ''), // English
                Locale('zh', ''), // Chinese
              ],
              // 处理语言解析逻辑
              localeResolutionCallback: (deviceLocale, supportedLocales) {
                final settingsLocale = AppServices.appSettings.locale;
                // 如果是强制模式（zh/en），使用设置的语言
                if (settingsLocale != null) {
                  LocaleService.updateLocale(settingsLocale);
                  return settingsLocale;
                }
                // 如果是跟随系统模式，使用设备语言
                if (deviceLocale != null) {
                  // 检查设备语言是否在支持列表中
                  for (var locale in supportedLocales) {
                    if (locale.languageCode == deviceLocale.languageCode) {
                      LocaleService.updateLocale(locale);
                      return locale;
                    }
                  }
                }
                // 默认使用中文
                const defaultLocale = Locale('zh', '');
                LocaleService.updateLocale(defaultLocale);
                return defaultLocale;
              },
              initialRoute: Routes.splash,
              onGenerateRoute: AppRouter.generateRoute,
              onUnknownRoute: AppRouter.unknownRoute,
            );
          },
        );
      },
    );
  }
}
