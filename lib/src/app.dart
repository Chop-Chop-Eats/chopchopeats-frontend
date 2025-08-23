import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/l10n/app_localizations.dart';
import 'core/routing/router.dart';
import 'core/routing/routes.dart';
import 'core/theme/app_theme.dart';
import 'app_services.dart';

class App extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const App({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppServices.appSettings,
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: "Collect Record",
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
  }
}
