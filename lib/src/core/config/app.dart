import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../l10n/app_localizations.dart';
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
              themeMode: AppServices.appSettings.themeMode,
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
