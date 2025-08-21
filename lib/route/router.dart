import 'package:flutter/material.dart';
import '../modules/error_page.dart';
import '../modules/login/views/login_page.dart';
import '../modules/main_screen.dart';
import '../modules/splash_page.dart';
import 'routes.dart';

class AppRouter {
  // 定义一个私有的、静态的路由处理程序 Map
  // Key: String (路由名)
  // Value: Widget Function(RouteSettings) (一个根据设置为我们构建 Widget 的函数)
  static final Map<String, Widget Function(RouteSettings)> _routeHandlers = {
    // === 无需参数的页面 ===
    Routes.home: (settings) => const MainScreen(),
    Routes.login: (settings) => const LoginPage(),

    // === 需要参数的页面 ===
    // Routes.detail: (settings) {
    //   if (settings.arguments is Map<String, dynamic>) {
    //     final args = settings.arguments as Map<String, dynamic>;
    //     final List<TaskItemModel> items = args["items"];
    //     final int initialIndex = args["initialIndex"];
    //     final int initialTabIndex = args["initialTabIndex"] ?? 0;
    //     return DetailPage(
    //       items: items,
    //       initialIndex: initialIndex,
    //       initialTabIndex: initialTabIndex,
    //     );
    //   }
    //   return const ErrorPage(message: "参数错误或缺失");
    // },
  };

  /// 创建路由方法
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // 查找与路由名称匹配的处理程序
    final handler = _routeHandlers[settings.name];

    Widget page;
    if (handler != null) {
      // 如果找到，就用它来构建页面
      page = handler(settings);
    } else {
      // 如果没找到，默认显示错误页面
      page = const ErrorPage(message: "路由处理程序未定义");
    }

    // 根据路由名称决定使用哪种转场动画
    // 这样动画逻辑和页面构建逻辑也分开了
    if (settings.name == Routes.splash) {
      return FadePageRoute<dynamic>(
        builder: (_) => const SplashPage(), // Splash 页面通常无参数，单独处理
        settings: settings,
      );
    }

    // 默认使用你的自定义滑动动画
    return CustomPagePeterRoute<dynamic>(
      builder: (_) => page,
      settings: settings,
    );
  }

  // unknownRoute 保持不变，作为最终的兜底
  static Route<dynamic> unknownRoute(RouteSettings settings) {
    return CustomPagePeterRoute(
      builder: (_) => const ErrorPage(message: "未知路由"),
      settings: settings,
    );
  }
}



/// 自定义路由类 实现滑动动画 替换默认的MaterialPageRoute
class CustomPagePeterRoute<T> extends PageRouteBuilder<T> {
  final WidgetBuilder builder;
  @override
  final RouteSettings settings;

  CustomPagePeterRoute({required this.builder, required this.settings})
    : super(
        settings: settings,
        pageBuilder:
            (context, animation, secondaryAnimation) => builder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // 新页面从右侧开始
          const end = Offset.zero; // 滑动到屏幕中央
          const curve = Curves.easeInOut; // 缓入缓出曲线

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300), // 动画时长 300ms
      );
}


// 淡入淡出动画
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final WidgetBuilder builder;

  FadePageRoute({required this.builder, super.settings})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}
